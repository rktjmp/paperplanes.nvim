(fn provide [content metadata opts on-complete]
  (let [curl (require :paperplanes.curl)
        args [:--data-binary content :https://paste.rs]
        resp-handler (fn [response status]
                       (match status
                         ;;returns url as "url\n" so we need to strip the new line
                         201 (on-complete (string.match response "^(https?://.*)\n"))
                         _ (on-complete nil response)))]
    (curl args resp-handler)))

(values provide)
