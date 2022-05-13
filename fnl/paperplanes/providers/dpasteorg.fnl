(local {: reduce : list-put : list-append : map-put} (require :paperplanes.fn))

(fn provide [content metadata opts on-complete]
  ;; dpaste accepts a lexer option, but will 400 error if it doesn't recognise
  ;; it so we will instead rely on the filename sniffer, which falls back to
  ;; text if doesn't recognise the extension.
  (let [curl (require :paperplanes.curl)
        defaults {:format :default
                  :content content
                  :filename metadata.filename}
        args (-> (reduce opts defaults #(map-put $3 $1 $2))
                 (reduce [] #(list-append $3 [:-F (.. $1 := $2)]))
                 (list-put "https://dpaste.org/api/"))
        resp-handler (fn [response status]
                       (match status
                         200 (on-complete (string.match response "\"(.*)\""))
                         _ (on-complete nil response)))]
    (curl args resp-handler)))

(values provide)
