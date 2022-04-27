(fn provide [content metadata opts]
  (assert (= true opts.insecure)
          "sprunge.us support is disabled as it does not support https. You must set the provider option insecure = true")
  (let [args [:-F (.. :sprunge= content) :http://sprunge.us]
        resp-handler (fn [response status]
                       (match status
                         ;;returns url as "url\n" so we need to strip the new line
                         200 (string.match response "^(http://.*)\n")
                         _ (values nil response)))]
    (values args resp-handler)))

(values provide)
