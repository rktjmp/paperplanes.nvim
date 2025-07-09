(local {:format fmt} string)

(fn completions []
  {:create []
   :delete []})

(fn create [content metadata _options on-complete]
  (let [curl (require :paperplanes.curl)
        filename (vim.fn.tempname)
        args [:--data-binary (.. "@" filename)]
        response-handler (fn [{: response : status : headers}]
                           (vim.loop.fs_unlink filename)
                           (case status
                             ;; 206 is technically "payload exceeded max upload
                             ;; size" but we dont have a great way to communicate
                             ;; that back and its probably unlikely in vim usage?
                             (where (or 201 206))
                             (let [url (case metadata.extension
                                         ext (.. response "." ext)
                                         _ response)]
                               (on-complete url {}))
                             _
                             (on-complete nil response)))]
    (with-open [outfile (io.open filename :w)]
               (outfile:write content))
    (curl :https://paste.rs args response-handler)))

(fn delete [context _options on-complete]
  (let [[url _] context
        curl (require :paperplanes.curl)
        args [:-X :DELETE]
        response-handler (fn [{: response : status : headers}]
                           (case status
                             200 (on-complete url {})
                             _ (on-complete nil response)))]
    (curl url args response-handler)))

{: create
 : delete
 : completions}
