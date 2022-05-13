(local fmt string.format)

(fn provide [content metadata opts on-complete]
  (assert opts.token "You must set provider_options.token to your sr.ht token")
  (let [curl (require :paperplanes.curl)
        auth-header (fmt "Authorization:token %s" opts.token)
        encoded (-> {:visibility (or opts.visibility :unlisted)
                     :files [{:filename metadata.filename
                              :contents content}]}
                    (vim.json.encode))
        args [:--header auth-header
              :--header "Content-Type:application/json"
              "https://paste.sr.ht/api/pastes"
              :--data-binary encoded]
        resp-handler (fn [response status]
                       (match status
                         201 (let [response (vim.json.decode response)
                                   url (fmt "https://paste.sr.ht/%s/%s"
                                            response.user.canonical_name
                                            response.sha)]
                               (on-complete url))
                         _ (on-complete nil response)))]
    (curl args resp-handler)))

(values provide)
