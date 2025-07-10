(local fmt string.format)

(fn assert-hut []
  (assert (= (vim.fn.executable :hut) 1)
          (fmt "paperplanes.nvim could not find %q executable" :hut)))

(fn completions []
  {:create [:visibility=unlisted :visibility=public :visibility=private]
   :delete []})

(fn create [content metadata options on-complete]
  (assert-hut)
  (let [{: exec} (require :paperplanes.exec)
        paste-visiblity (or options.visibility :unlisted)
        ;; we cant specify a filename, so our new file should
        ;; inherit the correct name if possible, and we need
        ;; a clean dir to dump it into.
        temp-dir (-> (vim.fs.joinpath (vim.fn.stdpath "run") "paperplanes_hut_XXXXXX")
                     (vim.uv.fs_mkdtemp))
        temp-filename (or metadata.filename :paste.txt)
         temp-path (vim.fs.joinpath temp-dir temp-filename)
        _ (with-open [outfile (io.open temp-path :w)]
            (outfile:write content))
        on-exit (fn [exit-code stdout stderr]
                  (vim.loop.fs_unlink temp-path)
                  (case exit-code
                    0 (let [url (string.match stdout "(.+)\n")
                            id (string.match url ".+/(.+)")]
                        (on-complete url {: id}))
                    _ (on-complete nil stderr)))]
    (exec :hut [:paste :create :--visibility paste-visiblity temp-path] on-exit)))

(fn delete [context options on-complete]
  (assert-hut)
  (let [[url {: id}] context]
    (if id
      (let [{: exec} (require :paperplanes.exec)
            on-exit (fn [status stdout stderr]
                      (case status
                        0 (on-complete url {})
                        _ (on-complete nil stderr)))]
        (exec :hut [:paste :delete id] on-exit))
      (let [msg (fmt "No id recorded for %s, unable to delete." url)]
        (on-complete nil msg)))))

{: create
 : delete
 : completions}
