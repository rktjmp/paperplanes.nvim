(local {: reduce : list-put : list-append : map-put} (require :paperplanes.fn))

(fn provide [content _metadata opts on-complete]
  ;; 0x0.st only accepts a file upload, write content to temp file then attach
  ;; then remove after post finish, this may leave files around if post fails
  ;; but they're in a temp dir so ...
  (let [curl (require :paperplanes.curl)
        filename (vim.fn.tempname)
        ;; 0x0.st accepts no options
        args [:-F (.. "file=@" filename) :https://0x0.st/]
        response-handler (fn [response status]
                           (vim.loop.fs_unlink filename)
                           (match status
                             ;; 0x0st returns url as "url\n" so we need to strip the new line
                             200 (on-complete (string.match response "(https://.*)\n"))
                             _ (on-complete nil response)))]
    (with-open [outfile (io.open filename :w)]
               (outfile:write content))
    (curl args response-handler)))

(values provide)
