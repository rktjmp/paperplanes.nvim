(local fmt string.format)

(fn completions []
  {:create [:expires=string :password=string]
   :delete []})

(fn create [content metadata options on-complete]
  (let [curl (require :paperplanes.curl)
        payload {:password options.password
                 :expires options.expires
                 :files [{:content content
                          :filename metadata.filename}]}
        args [:--request "POST"
              :--header "Content-Type: application/json"
              :--data (vim.json.encode payload)]
        resp-handler (fn [{: response : status : headers}]
                       (match status
                         200 (let [{: id : safety} (vim.json.decode response)
                                   url (fmt "https://mystb.in/%s/" id)]
                               (on-complete url {: safety}))
                         _ (on-complete nil response)))]
   (curl :https://mystb.in/api/paste args resp-handler)))

(fn delete [context options on-complete]
  (let [[original-url {: safety}] context]
    (case safety
      safety (let [curl (require :paperplanes.curl)
                   url (fmt :https://mystb.in/api/security/delete/%s safety)
                   response-handler (fn [{: response : status : headers}]
                                      (case status
                                        200 (on-complete original-url {})
                                        _ (on-complete nil response)))]
               (curl url [] response-handler))
      nil (let [msg (fmt "No token recorded for %s, unable to delete." original-url)]
            (on-complete nil msg)))))

{: create
 : delete
 : completions}
