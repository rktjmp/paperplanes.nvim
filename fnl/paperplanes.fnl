(local {:format fmt} string)

;; default configuration to be clobbered by setup
(local configuration {:register :+
                      :provider "0x0.st"
                      :provider_options {}
                      :notifier (or vim.notify print)
                      :save_history true})

(λ setup [opts]
  (each [k v (pairs opts)]
    (tset configuration k v)))

(fn get-config-option [key]
  (vim.deepcopy (. configuration key)))

(fn save-to-history [...]
  (if (get-config-option :save_history)
    ((. (require :paperplanes.history) :append) ...)))

;; Maintain per-neovim-instance mapping of unique-id (buffer-id by command) to
;; meta data for update & delete actions. The saved url and data is passed back
;; for update/delete functions.
(local known-instance-data {})

(fn get-known-instance-data [provider-name buffer-id]
  (?. known-instance-data provider-name buffer-id))

(fn set-known-instance-data [provider-name buffer-id url data]
  (let [pdata (or (. known-instance-data provider-name) {})]
    (tset pdata buffer-id [url data])
    (tset known-instance-data provider-name pdata)
    nil))

(fn unset-known-instance-data [provider-name buffer-id url data]
  (let [pdata (or (. known-instance-data provider-name) {})]
    nil (tset pdata buffer-id nil)
    (tset known-instance-data provider-name pdata)
    nil))

(fn resolve-provider-context [?provider-name ?provider-options action]
  (let [default-provider-name (get-config-option :provider)
        provider-name (or ?provider-name default-provider-name)
        provider-options (or ?provider-options
                             (if (= provider-name default-provider-name)
                               ;; only use default options if provider matches
                               ;; default.
                               (get-config-option :provider_options)
                               {}))
        providers (require :paperplanes.providers)
        provider (. providers provider-name)
        action-fn (?. provider action)]
    (case (values provider action-fn)
      (nil _) (error (fmt "paperplanes doesn't know provider: %q" provider-name))
      (_ nil) (error (fmt "paperplanes provider %s does not support action: %q"
                          provider-name action))
      _ {:name provider-name :action action-fn :options provider-options})))

(fn clean-content-metadata [metadata]
  ;; simplify downstream checks against nil vs ""
  ;; we're assuming the user isn't evil and only sends strings.
  (collect [k v (pairs metadata)]
    (case v
      "" (values k nil)
      other (values k v))))

(λ create [unique-id content-string content-metadata on-complete ?provider-name ?provider-options]
  (let [provider (resolve-provider-context ?provider-name ?provider-options :create)
        content-metadata (clean-content-metadata content-metadata)
        on-complete (fn [url meta]
                      (case (values url meta)
                        (url meta) (do
                                     (save-to-history provider.name :create url meta)
                                     (set-known-instance-data provider.name unique-id url meta)
                                     (on-complete url meta))
                        (nil err) (on-complete nil err)))]
    (provider.action content-string content-metadata provider.options on-complete)))

(λ update [unique-id content-string content-metadata on-complete ?provider-name ?provider-options]
  (let [provider (resolve-provider-context ?provider-name ?provider-options :update)
        content-metadata (clean-content-metadata content-metadata)
        on-complete (fn [url meta]
                      (case (values url meta)
                        (url meta) (do
                                     (save-to-history provider.name :update url meta)
                                     (set-known-instance-data provider.name unique-id url meta)
                                     (on-complete url))
                        (nil err) (on-complete nil err)))]
    (case (get-known-instance-data provider.name unique-id)
      context (provider.action context content-string content-metadata provider.options on-complete)
      nil (error (fmt "Unable to update, no known data for %s in this neovim instance" unique-id)))))

(λ delete [unique-id on-complete ?provider-name ?provider-options]
  (let [provider (resolve-provider-context ?provider-name ?provider-options :delete)
        on-complete (fn [url meta]
                      (case (values url meta)
                        (url meta) (do
                                     (save-to-history provider.name :delete url meta)
                                     (unset-known-instance-data provider.name unique-id)
                                     (on-complete url))
                        (nil err) (on-complete nil err)))]
    (case (get-known-instance-data provider.name unique-id)
      context (provider.action context provider.options on-complete)
      nil (error (fmt "Unable to delete, no known data for %s in this neovim instance" unique-id)))))

(fn history-path []
  ((. (require :paperplanes.history) :path)))

{: setup
 : get-config-option

 : create
 : update
 : delete

 : history-path
 :history_path history-path}
