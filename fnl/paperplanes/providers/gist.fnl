(local fmt string.format)

(fn get-token [options]
  ;; If given a token directly, use that, otherwise try to get one from `gh` exec.

  (fn try-provided-token [{:token provided-token}]
    (case (values provided-token (type provided-token))
      (nil _) nil ;; fall out to try gh-cli
      (raw-token :string) raw-token
      (token-function :function) (try-provided-token (token-function))
      (_ t) (let [msg (-> ["Unsupported auth token type: %s"
                           "Must be string or function returning string"]
                          (table.concat "\n"))]
              (error (fmt msg t)))))

  (fn try-gh-cli []
    (case (vim.fn.executable :gh)
      1 (case (: (vim.system [:gh :auth :token]) :wait)
          {:code 0 : stdout} (case (string.match stdout "(.+)\n")
                               token token
                               nil (error "`gh auth token` returned output but was incorrectly formatted."))
          {:code n :stderr err} (-> ["`gh auth token` returned an error: \n\n"
                                     err "\n"
                                     "Either provide an auth token directly via the token option or"
                                     " correct the issue with the github cli."]
                                    (table.concat "")
                                    (error)))
      _ nil))

  (case-try
    (try-provided-token options) nil
    (try-gh-cli) nil
    ;; should actually error in try-gh-cli and not get here
    (-> ["No auth token found, either provide one directly via the `token` option"
         "or ensure that the github cli is installed and authenticated."]
        (table.concat " ")
        (error))
    (catch
      token token)))

(fn completions []
  {:create [:description= :public=true :token=]
   :update [:description= :token=]
   :delete [:token=]})

(fn create [content metadata options on-complete]
  (let [curl (require :paperplanes.curl)
        token (get-token options)
        filename (or metadata.filename :paste.txt)
        payload {:files {filename {:content content}}
                 :description options.description
                 :public (case options.public
                           nil false
                           val val)}
        args [:-L
              :-X :POST
              :--header (fmt "Authorization: Bearer %s" token)
              :--header "Accept: application/vnd.github+json"
              :--header "X-Github-Api-Version: 2022-11-28"
              :--data-binary (vim.json.encode payload)]
        response-handler (fn [{: response : status : headers}]
                           (case status
                             201 (let [{: html_url : id} (vim.json.decode response)]
                                   ;; save filename for update operations
                                   (on-complete html_url {: id : filename}))
                             _ (on-complete nil response)))]
    (curl :https://api.github.com/gists args response-handler)))

(fn update [context content metadata options on-complete]
  (let [[original-url {: id : filename}] context]
    (if id
      (let [curl (require :paperplanes.curl)
            token (get-token options)
            payload {:files {filename {:content content}}
                     :description options.description}
            args [:-L
                  :-X :PATCH
                  :--header (fmt "Authorization: Bearer %s" token)
                  :--header "Accept: application/vnd.github+json"
                  :--header "X-Github-Api-Version: 2022-11-28"
                  :--data-binary (vim.json.encode payload)]
            url (fmt :https://api.github.com/gists/%s id)
            response-handler (fn [{: response : status : headers}]
                               (case status
                                 200 (let [{: html_url : id} (vim.json.decode response)]
                                       (on-complete html_url {: id : filename}))
                                 _ (on-complete nil response)))]
        (curl url args response-handler))
      (let [msg (fmt "No id recorded for %s, unable to update." original-url)]
        (on-complete nil msg)))))

(fn delete [context options on-complete]
  (let [[original-url {: id}] context]
    (if id
      (let [curl (require :paperplanes.curl)
            token (get-token options)
            args [:-L
                  :-X :DELETE
                  :--header (fmt "Authorization: Bearer %s" token)
                  :--header "Accept: application/vnd.github+json"
                  :--header "X-Github-Api-Version: 2022-11-28"]
            url (fmt :https://api.github.com/gists/%s id)
            response-handler (fn [{: response : status : headers}]
                               (case status
                                 204 (on-complete original-url {})
                                 _ (on-complete nil response)))]
        (curl url args response-handler))
      (let [msg (fmt "No id recorded for %s, unable to delete." original-url)]
        (on-complete nil msg)))))

{: completions
 : create
 : update
 : delete}
