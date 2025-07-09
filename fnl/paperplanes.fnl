(local {:format fmt} string)

;; default configuration to be clobbered by setup
(local configuration {:register :+
                      :provider "0x0.st"
                      :provider_options {}
                      :notifier (or vim.notify print)})

(fn get-config-option [key]
  (vim.deepcopy (. configuration key)))

;; Maintain per-neovim-instance mapping of buffers to meta data for update &
;; delete actions. The saved url and data is passed back for update/delete
;; functions.
(local known-instance-data {})

(fn get-known-instance-data [provider-name buffer-id]
  (?. known-instance-data provider-name buffer-id))

(fn set-known-instance-data [provider-name buffer-id url data]
  (let [pdata (or (. known-instance-data provider-name) {})]
    (tset pdata buffer-id {: url :meta data})
    (tset known-instance-data provider-name pdata)
    nil))

(fn unset-known-instance-data [provider-name buffer-id url data]
  (let [pdata (or (. known-instance-data provider-name) {})]
    nil (tset pdata buffer-id nil)
    (tset known-instance-data provider-name pdata)
    nil))

(λ execute-action [provider-action
                   unique-id
                   content-string content-metadata
                   on-complete
                   ?provider-name ?provider-options]
  (let [providers (require :paperplanes.providers)
        provider-name (or ?provider-name (get-config-option :provider))
        provider-options (or ?provider-options (get-config-option :provider_options))
        provider (or (. providers provider-name)
                     (error (fmt "paperplanes doesn't know provider: %q" provider-name)))
        action-fn (or (. provider provider-action)
                      (error (fmt "paperplanes provider %s does not support action: %q"
                                  provider-name provider-action)))
        record-history (fn [url meta]
                         (let [history (require :paperplanes.history)]
                           (history.append provider-name provider-action url meta)
                           (case provider-action
                             (where (or :create :update))
                             (set-known-instance-data provider-name unique-id url meta)
                             :delete
                             (unset-known-instance-data provider-name unique-id))))
        on-complete (fn [url meta]
                      ;; url meta may be nil, err
                      (if url (record-history url meta))
                      (on-complete url meta))
         action-meta (get-known-instance-data provider-name unique-id)]
    (case provider-action
      (where (or :update :delete))
      (if (not action-meta)
        (error (fmt "Unable to %s, no recorded data for buffer %s in this neovim instance"
                    provider-action unique-id))))
    (case provider-action
      :create
      (action-fn content-string content-metadata provider-options on-complete)
      :update
      (action-fn content-string content-metadata action-meta provider-options on-complete)
      :delete
      (action-fn action-meta provider-options on-complete))))

(λ create [unique-id content-string content-metadata on-complete ?provider-name ?provider-options]
  (execute-action :create
                  unique-id
                  content-string content-metadata
                  on-complete
                  ?provider-name ?provider-options))

(λ update [unique-id content-string content-metadata on-complete ?provider-name ?provider-options]
  (execute-action :update
                  unique-id
                  content-string content-metadata
                  on-complete
                  ?provider-name ?provider-options))

(λ delete [unique-id on-complete ?provider-name ?provider-options]
  (execute-action :delete
                  unique-id
                  on-complete
                  ?provider-name ?provider-options))

(λ setup [opts]
  (each [k v (pairs opts)]
    (tset configuration k v)))

{: setup
 : create
 : update
 : delete
 : get-config-option
 :__known-instance-data (fn [] known-instance-data)}
