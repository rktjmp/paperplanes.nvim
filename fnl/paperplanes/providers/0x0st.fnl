(local {: set-field} (require :paperplanes.util.providers))

(fn post-file [filename meta maybe-cleanup]
  (local args (doto []
                    ;; file=@filename
                    (set-field :file (.. "@" filename))
                    (table.insert "http://0x0.st")))
  (print (vim.inspect args))

  (fn after [response status]
    (if maybe-cleanup (maybe-cleanup))
    (match status
      ;; 0x0st returns url as "url\n" so we need to strip the new line
      200 (string.match response "(http://.*)\n")
      _ (values nil response)))
      
  (values args after))

(fn post-string [string meta]
  ;; 0x0.st only accepts a file upload, write content to temp file
  (let [filename (vim.fn.tempname)]
    (with-open [outfile (io.open filename :w)]
               (outfile:write string))

    ;; remove temp file afterwards
    (fn cleanup []
      (vim.loop.fs_unlink filename))

    ;; handle as normal file post
    (post-file filename meta cleanup)))

{: post-string
 : post-file}
