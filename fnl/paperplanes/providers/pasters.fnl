(fn provide [content metadata opts on-complete]
  (let [curl (require :paperplanes.curl)
        args [:--data-binary content :https://paste.rs]
        resp-handler (fn [response status]
                       (match status
                         201 (on-complete response)
                         _ (on-complete nil response)))]
    (curl args resp-handler)))

(values provide)
