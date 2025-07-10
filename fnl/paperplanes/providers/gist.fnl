(local fmt string.format)

(fn via-gh [content metadata opts on-complete]
  (assert (= (vim.fn.executable :gh) 1)
          (fmt "paperplanes.nvim could not find %q executable" :gh))
  (let [{: exec} (require :paperplanes.exec)
        temp-filename (string.format "%s-%s.%s"
                                     (vim.fn.tempname)
                                     (or metadata.filename :paste)
                                     (or metadata.extension :txt))
        _ (with-open [outfile (io.open temp-filename :w)]
            (outfile:write content))
        on-exit (fn [exit-code output errors]
                    (vim.loop.fs_unlink temp-filename)
                    (case exit-code
                      0 (on-complete output)
                      ;; Not sure what might be returned or how...
                      _ (on-complete nil (.. output " " errors))))]
    ;; --filename only applicable when passing data via stdin which
    ;; we do not currently support via exec.
    (exec :gh [:gist :create :--public temp-filename] on-exit)))

(fn via-curl [content metadata opts on-complete]
  (assert opts.token "You must set provider_options.token to your github gist token")
  (let [curl (require :paperplanes.curl)
        encoded (-> {:public true :files {metadata.filename {:content content}}}
                    (vim.json.encode))
        token (case (type opts.token)
                :function (opts.token)
                :string opts.token
                t (error (fmt "unsupported token type: %s, must be string or function returning string" t)))
        args [:-L
              :-X :POST
              :--header (fmt "Authorization: Bearer %s" token)
              :--header "Accept: application/vnd.github+json"
              :--header "X-Github-Api-Version: 2022-11-28"
              "https://api.github.com/gists"
              :--data-binary encoded]
        resp-handler (fn [response status]
                       (print response status)
                       (match status
                         201 (let [response (vim.json.decode response)
                                   url response.html_url]
                               (on-complete url))
                         _ (on-complete nil response)))]
    (curl args resp-handler)))

(fn provide [content metadata opts on-complete]
  (case opts.command
    :gh (via-gh content metadata opts on-complete)
    (where (or :curl _)) (via-curl content metadata opts on-complete)))

(fn get-token [{: token}]
  (case (type token)
    :function (case (token)
                (where token (= :string (type token))) token
                bad (let [msg "Auth token function must return string, got %s"]
                      (error (fmt msg (type bad)))))
    :string token
    t (let [msg (-> ["Unsupported auth token type: %s"
                     "Must be string or function returning string"]
                    (table.concat "\n"))]
        (error (fmt msg t)))))

(fn completions []
  {:create [:description= :public=true :token=]
   :update [:description= :token=]
   :delete [:token=]})

(fn curl-create [content metadata options on-complete]
  (let [curl (require :paperplanes.curl)
        token (get-token options)
        payload {:files {metadata.filename {:content content}}
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
                                   (on-complete html_url {: id}))
                             _ (on-complete nil response)))]
    (curl :https://api.github.com/gists args response-handler)))

(fn curl-update [context content metadata options on-complete]
  (let [[original-url {: id}] context]
    (if id
      (let [curl (require :paperplanes.curl)
            token (get-token options)
            payload {:files {metadata.filename {:content content}}
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
                                       (on-complete html_url {: id}))
                                 _ (on-complete nil response)))]
        (curl url args response-handler))
      (let [msg (fmt "No id recorded for %s, unable to update." original-url)]
        (on-complete nil msg)))))

(fn curl-delete [context options on-complete]
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


(fn create [content metadata options on-complete]
  (case options.command
    (where (or :curl _)) (curl-create content metadata options on-complete)))

(fn update [context content metadata options on-complete]
  (case options.command
    (where (or :curl _)) (curl-update context content metadata options on-complete)))

(fn delete [context options on-complete]
  (case options.command
    (where (or :curl _)) (curl-delete context options on-complete)))

{: completions
 : create
 : update
 : delete}
