(local {: reduce : list-put : list-append : map-put} (require :paperplanes.fn))
(local fmt string.format)

(fn provide [content metadata opts on-complete]
  (assert (= true opts.insecure)
          "ix.io support is disabled as it does not support https. You must set the provider option insecure = true")
  (let [curl (require :paperplanes.curl)
        temp-filename (vim.fn.tempname)
        defaults {:name:1 metadata.filename
                  :ext:1 metadata.extension}
        args (-> (reduce opts defaults #(map-put $3 $1 $2))
                 (#(doto $1 (map-put :insecure nil)))
                 (reduce [] #(list-append $3 [:--data-urlencode (fmt "%s=%s" $1 $2)]))
                 (list-append [:--data-urlencode (fmt "f:1@%s" temp-filename)])
                 (list-put "http://ix.io/"))
        resp-handler (fn [response status]
                       (vim.loop.fs_unlink temp-filename)
                       (match status
                         ;;returns url as "url\n" so we need to strip the new line
                         200 (on-complete (string.match response "(http://.*)\n"))
                         _ (on-complete nil response)))]
    (with-open [outfile (io.open temp-filename :w)]
               (outfile:write content))
    (curl args resp-handler)))

(values provide)
