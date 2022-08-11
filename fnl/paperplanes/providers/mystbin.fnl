(local fmt string.format)

(fn body [ content filename]
  (vim.json.encode {
    :files [ {
      :content content
      :filename filename
  }]}))

(fn provide [content metadata opts on-complete]
  (let [curl (require :paperplanes.curl)
        args [ 
          :--request "PUT"
          :--header "Content-Type: application/json"
          :--data (body content (or (and (string.len metadata.filename) metadata.filename) "untitled"))
          :https://api.mystb.in/paste]
        resp-handler (fn [response status]
                       (match status
                         200 (let [response (vim.json.decode response)
                                url (fmt "https://mystb.in/%s/" response.id )]
                               (on-complete url ))
                         429 (on-complete nil "ratelimit reached, please try again later")
                         _ (on-complete nil response)))]
   (curl args resp-handler)))

(values provide)
