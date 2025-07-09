(local {:format fmt} string)
(local history
  (setmetatable {}
                {:__index (fn [t k]
                            (tset t k (. (require :paperplanes.history) k))
                            (. t k))}))

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
  (let [provider-name (or ?provider-name (get-config-option :provider))
        provider-options (or ?provider-options (get-config-option :provider_options))
        providers (require :paperplanes.providers)
        provider (. providers provider-name)
        action-fn (?. provider action)]
    (case (values provider action-fn)
      (nil _) (error (fmt "paperplanes doesn't know provider: %q" provider-name))
      (_ nil) (error (fmt "paperplanes provider %s does not support action: %q"
                          provider-name action))
      _ (values provider-name action-fn provider-options))))

(λ create [unique-id content-string content-metadata on-complete ?provider-name ?provider-options]
  (let [(provider-name create-fn provider-options) (resolve-provider-context ?provider-name
                                                                             ?provider-options
                                                                             :create)
        on-complete (fn [url meta]
                      (when url
                        (if (get-config-option :save_history)
                          (history.append provider-name :create url meta))
                        (set-known-instance-data provider-name unique-id url meta))
                      (on-complete url meta))]
    (create-fn content-string content-metadata provider-options on-complete)))


(λ delete [unique-id on-complete ?provider-name ?provider-options]
  (let [(provider-name delete-fn provider-options) (resolve-provider-context ?provider-name
                                                                             ?provider-options
                                                                             :delete)
        on-complete (fn [url meta]
                      (when url
                        (if (get-config-option :save_history)
                          (history.append provider-name :delete url meta))
                        (unset-known-instance-data provider-name unique-id))
                      (on-complete url meta))]
    (case (get-known-instance-data provider-name unique-id)
      context (delete-fn context provider-options on-complete)
      nil (error (fmt "Unable to delete, no known data for %s in this neovim instance" unique-id)))))

; (λ update [unique-id content-string content-metadata on-complete ?provider-name ?provider-options]
;   (execute-action :update
;                   unique-id
;                   content-string content-metadata
;                   on-complete
;                   ?provider-name ?provider-options))
 
{: setup
 : create
 ; : update
 : delete
 : get-config-option
 :__known-instance-data (fn [] known-instance-data)}
