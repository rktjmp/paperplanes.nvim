(local {:format fmt} string)

;; resolve require late
(local [create update delete get-config-option]
  (let [keys [:create :update :delete :get-config-option]]
    (icollect [_ name (ipairs keys)]
      (fn [...]
        ((. (require :paperplanes) name) ...)))))

(fn provider-syntax? [x]
  (vim.startswith x "@"))

(fn run-command [{:fargs argv :range range-enum}]
  ;; Use range instead of line1,line2, as those do not have column data.
  ;; 0 = no range given, full buffer
  ;; 2 = range specified, use marks.
  (fn create-text-range [buf-id use-marks?]
    (case use-marks?
      true (let [[start-row start-col] (vim.api.nvim_buf_get_mark buf-id "<")
                 [end-row end-col] (vim.api.nvim_buf_get_mark buf-id ">")
                 ;; Marks are "1-based lines, 0 based columns",
                 ;; get_text columns are end-exclusive.
                 start-row (- start-row 1)
                 end-row (- end-row 1)
                 end-col (+ end-col 1)]
             [[start-row start-col]
              [end-row end-col]])
      false (let [line-count (vim.api.nvim_buf_line_count buf-id)]
              ;; 2147483648 is vims default max-col
              [[0 0] [(- line-count 1) 2147483648]])))

  (fn parse-argv [argv]
    (case argv
      [nil]
      {:provider-name nil
       :provider-options []
       :action :create}
      (where [provider-name nil] (provider-syntax? provider-name))
      {:provider-name (string.sub provider-name 2)
       :provider-options []
       :action :create}
      (where [provider-name action & args] (provider-syntax? provider-name))
      {:provider-name (string.sub provider-name 2)
       :provider-options args
       :action action}
      [action & args]
      {:provider-name nil
       :provider-options args
       :action action}))

  (fn parse-provider-options [raw-options]
    (collect [_ key-val (ipairs raw-options)]
      (case (string.match key-val "([^=]+)=([^=]+)")
        (key value) (values key value)
        _ (error (fmt "provider options must be given as key=value, got %q"
                      key-val)))))

  (fn handle-create-result [url err]
    ;; print url, or print register and url or raise error
    ;; TODO: would rather pass wrapped type.
    (case [url err]
      [nil err] (error (fmt "paperplanes got no url back from provider: %s" err))
      [url _] (let [reg (get-config-option :register)
                    notify (get-config-option :notifier)
                    msg-prefix (if reg (fmt "\"%s = " reg) "")
                    msg (fmt "%s%s" msg-prefix url)]
                (if reg (vim.fn.setreg reg url))
                (notify msg))))

  (fn handle-delete-result [url err]
    ;; print url, or print register and url or raise error
    ;; TODO: would rather pass wrapped type.
    (case [url err]
      [nil err] (error (fmt "paperplanes got an error from provider: %s" err))
      [url _] (let [notify (get-config-option :notifier)
                    msg (fmt "deleted %s" url)]
                (notify msg))))

  (let [buf-id (vim.api.nvim_get_current_buf)
        unique-id (.. "buffer-" buf-id)
        use-marks? (= range-enum 2)
        [[start-row start-col] [end-row end-col]] (create-text-range buf-id use-marks?)
        content-string (-> (vim.api.nvim_buf_get_text buf-id
                                                      start-row start-col
                                                      end-row end-col
                                                      {})
                           (table.concat "\n"))
        content-meta (vim.api.nvim_buf_call buf-id #{:path (vim.fn.expand "%:p")
                                                     :filename (vim.fn.expand "%:t")
                                                     :extension (vim.fn.expand "%:e")
                                                     :filetype vim.bo.filetype})
        {: provider-name : provider-options : action} (parse-argv argv)
        provider-options (let [parsed-options (parse-provider-options provider-options)
                               default-provider (get-config-option :provider)
                               default-options (get-config-option :provider_options)]
                           ;; dont bleed default options between providers.
                           (if (= provider-name default-provider)
                             (vim.tbl_extend :force default-options parsed-options)
                             parsed-options))]
    (case action
      :create (create unique-id
                      content-string content-meta
                      handle-create-result
                      provider-name provider-options)
      :update (update unique-id
                      content-string content-meta
                      handle-create-result
                      provider-name provider-options)
      :delete (delete unique-id
                      handle-delete-result
                      provider-name provider-options)
      _ (error (fmt "Action must be create, update or delete, got %q" action)))))

(fn complete [arg-lead cmd-line cursor-pos]
  (fn filter [options prefix do-not-return-default-all?]
    ;; filter to options that match prefix, but if nothing matches return all
    ;; options as suggestions.
    (let [filtered (vim.tbl_filter #(vim.startswith $1 prefix) options)]
      (case (length filtered)
        0 (if do-not-return-default-all? [] options)
        _ filtered)))

  (fn get-provider [provider-name]
    (let [providers (require :paperplanes.providers)
          provider-name (or (and provider-name
                                 ;; strip leading "@"
                                 (string.sub provider-name 2))
                            (get-config-option :provider))]
      (. providers provider-name)))

  (fn complete-provider [arg-lead]
    (-> (icollect [name _ (pairs (require :paperplanes.providers))]
          (.. "@" name))
        (filter arg-lead)))

  (fn complete-action [provider-name arg-lead]
    (case-try
      (get-provider provider-name) {: completions}
      (-> (completions)
          (vim.tbl_keys)
          (filter arg-lead))
      (catch
        _ [])))

  (fn complete-provider-arguments [provider-name action _arguments arg-lead]
    (case-try
      (get-provider provider-name) {: completions}
      (. (completions) action) action-completions
      (filter action-completions arg-lead)
      (catch
        _ [])))

  ;; Colapse repeated whitespace so we can still retain the "trailing empty
  ;; start" of a new argument, else "PP @x <tab>" looks the same as "PP @x<tab>".
  ;; but without the collase "PP @x     <tab>" would try to complete provider
  ;; arguments not action.
  (let [arguments (-> (string.gsub cmd-line "%s+" " ")
                      (vim.split " " {:trimempty false}))]
    ;; PP <@provider> <create|update|delete> <argument=value ...>
    (case arguments
      (where [_PP provider nil] (provider-syntax? provider))
      (complete-provider provider)
      [_PP action nil]
      (complete-action nil action)
      (where [_PP provider action nil] (provider-syntax? provider))
      (complete-action provider action)
      (where [_PP provider action & arguments] (provider-syntax? provider))
      (complete-provider-arguments provider action arguments arg-lead)
      [_PP action & arguments]
      (complete-provider-arguments nil action arguments arg-lead)
      _ [])))

(vim.api.nvim_create_user_command
  :PP
  run-command
  {:force true
   :range "%"
   :complete complete
   :nargs "*"
   :desc "Pastebin selected text or entire buffer via paperplanes.nvim, see :h paperplanes-command."})
