(local fmt string.format)

(fn provide [content metadata opts on-complete]
  (assert (= true opts.insecure)
          "sprunge.us support is disabled as it does not support https. You must set the provider option insecure = true")
  (let [curl (require :paperplanes.curl)
        temp-filename (vim.fn.tempname)
        args [:--data-urlencode (fmt "sprunge@%s" temp-filename)
              :http://sprunge.us]
        resp-handler (fn [response status]
                       (vim.loop.fs_unlink temp-filename)
                       (match status
                         ;;returns url as "url\n" so we need to strip the new line
                         200 (on-complete (string.match response "^(http://.*)\n"))
                         _ (on-complete nil response)))]
    (with-open [outfile (io.open temp-filename :w)]
               (outfile:write content))
    (curl args resp-handler)))

(values provide)
