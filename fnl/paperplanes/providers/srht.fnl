(local fmt string.format)

(fn make [content-arg meta opts]
  (assert opts.token
    "You must set provider_options.token to your sr.ht token")
  (local args [:--header
               (fmt "Authorization:token %s" opts.token)
               :--header
               "Content-Type:application/json"
               "https://paste.sr.ht/api/pastes"
               :--data-binary
               (fmt "%s"
                    (vim.json.encode
                      {:visibility (or opts.visibility :unlisted)
                       :files [{:filename (vim.fn.expand "%:t")
                                :contents content-arg}]}))])


  (fn after [response status]
    (match status
      201 (let [response (vim.json.decode response)]
            (fmt "https://paste.sr.ht/%s/%s"
                 response.user.canonical_name
                 response.sha))
      _ (values nil response)))

  (values args after))

(fn post-string [string meta opts]
  (make string meta opts))

{: post-string}
