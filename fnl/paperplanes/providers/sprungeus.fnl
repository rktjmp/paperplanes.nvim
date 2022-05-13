(fn provide [content metadata opts on-complete]
  (assert (= true opts.insecure)
          "sprunge.us support is disabled as it does not support https. You must set the provider option insecure = true")
  (let [curl (require :paperplanes.curl)
        args [:-F (.. :sprunge= content) :http://sprunge.us]
        resp-handler (fn [response status]
                       (match status
                         ;;returns url as "url\n" so we need to strip the new line
                         200 (on-complete (string.match response "^(http://.*)\n"))
                         _ (on-complete nil response)))]
    (curl args resp-handler)))

(values provide)
