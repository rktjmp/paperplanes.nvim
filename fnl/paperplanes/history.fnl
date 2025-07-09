;;; Maintain history of paperplanes usage for user.
;;;
;;; Records provider used, action, resulting url and any associated meta data
;;;

(λ path []
  ;;cache        String  Cache directory: arbitrary temporary
  ;;                     storage for plugins, etc.
  ;;config       String  User configuration directory. |init.vim|
  ;;                     is stored here.
  ;;config_dirs  List    Other configuration directories.
  ;;data         String  User data directory.
  ;;data_dirs    List    Other data directories.
  ;;log          String  Logs directory (for use by plugins too).
  ;;run          String  Run directory: temporary, local storage
  ;;                     for sockets, named pipes, etc.
  ;;state        String  Session state directory: storage for file
  ;;                     drafts, swap, undo, |shada|.
  (vim.fs.joinpath
    (vim.fn.stdpath :data)
    :paperplanes_history.json))

(λ read []
  (λ open-or-create-file []
    (case-try
      (io.open (path)) file
      (values file)
      (catch
        _ (do
            (let [file (io.open (path) :w)]
              (file:write "[]")
              (file:close))
            (open-or-create-file)))))

  (-> (open-or-create-file)
      (: :read :*a)
      (vim.json.decode)))

(λ append [provider-name action url paste-data]
  (let [new-event {:provider provider-name
                   :action action
                   :url url
                   :meta paste-data
                   :at (os.date "!%Y-%m-%dT%H:%M:%SZ")}
        data (read)
        _ (table.insert data new-event)
        updated-history (vim.json.encode data)]
    (with-open [f (io.open (path) :w+)]
      (f:write updated-history))
    true))

{: append : read : path}
