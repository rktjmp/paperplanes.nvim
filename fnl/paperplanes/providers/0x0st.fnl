(local {:format fmt} string)

(fn completions []
  {:create [:expires=hours :expires=epochms
            :secret=true]
   ;; note you can POST expires=new_date but you can't actually *update*
   ;; content, so we'll preference the user flatout deleteing and reposting.
   :delete [:token=key]})

(fn create [content _content-metadata options on-complete]
  ;; 0x0.st only accepts a file upload, write content to temp file then attach
  ;; then remove after post finish, this may leave files around if post fails
  ;; but they're in a temp dir so ...
  (let [curl (require :paperplanes.curl)
        filename (vim.fn.tempname)
        args (accumulate [a [:-F (.. "file=@" filename)]
                          key val (pairs options)]
               (doto a
                 (table.insert :-F)
                 (table.insert (.. key "=" val))))
        response-handler (fn [{: response : status : headers}]
                           (vim.loop.fs_unlink filename)
                           (case status
                             ;; 0x0st returns url as "url\n" so we need to strip the new line
                             200 (let [url (string.match response "(https://.*)\n")
                                       {:x-token token :x-expires expires} headers
                                       ;; headers are returned as a list
                                       ;; and token may not always be present
                                       ;; if content matched existing content.
                                       token (?. token 1)
                                       expires (?. expires 1)]
                                   (on-complete url {: token : expires}))
                             _ (on-complete nil response)))]
    (with-open [outfile (io.open filename :w)]
               (outfile:write content))
    (curl :https://0x0.st args response-handler)))

(fn delete [context _options on-complete]
  (let [[url {: token}] context]
    (case token
      token (let [curl (require :paperplanes.curl)
                  args [:-F (.. "token=" token) :-F "delete=true" url]
                  response-handler (fn [{: response : status : headers}]
                                     (case status
                                       200 (on-complete url {})
                                       _ (on-complete nil response)))]
              (curl url args response-handler))
      nil (let [msg (-> ["No token recorded for %s, unable to delete."
                         "(The paste may have matched an existing hash and no token was returned)"]
                        (table.concat "\n")
                        (fmt url))]
            (on-complete nil msg)))))

{: create
 : delete
 : completions}
