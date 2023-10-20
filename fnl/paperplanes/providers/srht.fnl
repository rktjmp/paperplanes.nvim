(local fmt string.format)

(fn via-hut [content metadata opts on-complete]
  (assert (= (vim.fn.executable :hut) 1)
          (fmt "paperplanes.nvim could not find %q executable" :hut))
  (let [{: exec} (require :paperplanes.exec)
        temp-filename (string.format "%s-%s.%s"
                                     (vim.fn.tempname)
                                     (or metadata.filename :paste)
                                     (or metadata.extension :txt))
        _ (with-open [outfile (io.open temp-filename :w)]
            (outfile:write content))
        on-exit (fn [exit-code output errors]
                    (vim.loop.fs_unlink temp-filename)
                    (case exit-code
                      0 (on-complete output)
                      ;; Not sure what might be returned or how...
                      _ (on-complete nil (.. output " " errors))))]
    (exec :hut [:paste :create temp-filename] on-exit)))

(fn via-curl [content metadata opts on-complete]
  (assert opts.token "You must set provider_options.token to your sr.ht token")
  (let [curl (require :paperplanes.curl)
        auth-header (fmt "Authorization:token %s" opts.token)
        encoded (-> {:visibility (or opts.visibility :unlisted)
                     :files [{:filename metadata.filename
                              :contents content}]}
                    (vim.json.encode))
        args [:--header auth-header
              :--header "Content-Type:application/json"
              "https://paste.sr.ht/api/pastes"
              :--data-binary encoded]
        resp-handler (fn [response status]
                       (match status
                         201 (let [response (vim.json.decode response)
                                   url (fmt "https://paste.sr.ht/%s/%s"
                                            response.user.canonical_name
                                            response.sha)]
                               (on-complete url))
                         _ (on-complete nil response)))]
    (curl args resp-handler)))

(fn provide [content metadata opts on-complete]
  (case opts.command
    :hut (via-hut content metadata opts on-complete)
    (where (or :curl _)) (via-curl content metadata opts on-complete)))

(values provide)
