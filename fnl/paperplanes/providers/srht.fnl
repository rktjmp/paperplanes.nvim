(local fmt string.format)
(local uv (or vim.uv vim.loop))

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
        filename (or metadata.filename :paste.txt)
        on-exit (fn [exit-code stdout stderr]
                  (case exit-code
                    0 (let [url (string.match stdout "(.+)\n")
                            id (string.match url ".+/(.+)")]
                        (on-complete url {: id}))
                    _ (on-complete nil stderr)))
        on-spawn (fn [{: stdin}]
                   (uv.write stdin content))]
    (exec :hut [:paste :create
                :--visibility paste-visiblity
                :--name filename]
          on-exit on-spawn)))

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
