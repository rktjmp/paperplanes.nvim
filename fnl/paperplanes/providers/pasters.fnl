(fn provide [content metadata opts]
  (let [args [:--data-binary content :https://paste.rs]
        resp-handler (fn [response status]
                       (match status
                         ;;returns url as "url\n" so we need to strip the new line
                         201 (string.match response "^(https?://.*)\n")
                         _ (values nil response)))]
    (values args resp-handler)))

(values provide)
