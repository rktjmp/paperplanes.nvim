(macro assert-arguments [fn-name ...]
  (let [asserts (icollect [_ check-var (ipairs [...]) :into `(do)]
                          `(assert
                             (~= nil ,check-var)
                             (string.format "paperplanes.%s requires %s argument" ,fn-name ,(tostring check-var))))]
    `(do ,asserts)))

(local uv vim.loop)
(local {: get-range
        : get-selection
        : get-buf} (require :paperplanes.get_text))
(local {:format fmt} string)

;; default options to be clobbered by setup
(local options {:register :+
                :provider "0x0.st"
                :provider_options {}
                :notifier (or vim.notify print)})

(fn get-option [name]
  (. options name))

(fn get-provider [name]
  (let [providers (require :paperplanes.providers)
        provider (. providers name)]
    (or provider (error (fmt "paperplanes doesn't know provider: %q" name)))))

(fn notify [string]
  ((get-option :notifier) string))

(fn get-buffer-meta [buffer]
  ;; try to get any metadata from the buffer, this includes:
  ;; path, filename, extension, filetype
  (vim.api.nvim_buf_call buffer #(values {:path (vim.fn.expand "%:p")
                                          :filename (vim.fn.expand "%:t")
                                          :extension (vim.fn.expand "%:e")
                                          :filetype vim.bo.filetype})))

(fn post-string [content file-meta callback ?provider-name ?provider-options]
  (assert-arguments :post-string content file-meta callback)
  (let [default-name (get-option :provider)
        default-opts (get-option :provider_options)
        [provider-name provider-options] (match ?provider-name
                                           ;; no provider given, use default configuration
                                           nil [default-name default-opts]
                                           ;; given provider matches default, maybe use default options
                                           default-name [default-name (or ?provider-options default-opts)]
                                           ;; otherwise use the given provider and given options if they exist
                                           _ [?provider-name (or ?provider-options {})])
        provider (get-provider provider-name)]
    (provider content file-meta provider-options callback)))

(fn post-range [buffer start stop cb ?provider-name ?provider-options]
  (assert-arguments :post-range buffer start stop)
  (let [content (get-range buffer start stop)
        buffer-meta (get-buffer-meta buffer)]
    (post-string content buffer-meta cb ?provider-name ?provider-options)))

(fn post-selection [callback ?provider-name ?provider-options]
  (assert-arguments :post-selection callback)
  (let [content (get-selection)
        buffer-meta (get-buffer-meta 0)]
    (post-string content buffer-meta callback ?provider-name ?provider-options)))

(fn post-buffer [buffer callback ?provider-name ?provider-options]
  (assert-arguments :post-buffer buffer callback)
  (let [content (get-buf buffer)
        buffer-meta (get-buffer-meta buffer)]
    (post-string content buffer-meta callback ?provider-name ?provider-options)))

(fn cmd [start stop]
  "cmd is only intended for use from the :PP vim command"
  (assert-arguments :cmd start stop)
  (fn maybe-set-and-print [url err]
    ;; print url, or print register and url or raise error
    (match [url err]
      [nil err] (error (fmt "paperplanes got no url back from provider: %s" err))
      [url _] (let [reg (get-option :register)
                    msg-prefix (if reg (fmt "\"%s = " reg) "")
                    msg (fmt "%s%s" msg-prefix url)]
                (if reg (vim.fn.setreg reg url))
                (notify msg))))
  (let [provider-name (get-option :provider)
        provider-options (get-option :provider_options)]
    (notify (fmt "%s'ing..." provider-name))
    (post-range 0 start stop maybe-set-and-print provider-name provider-options)))

(fn setup [opts]
  (assert-arguments :setup opts)
  ;; options:
  ;;  register : register name | false (do not store)
  ;;  provider : :0x0.st :ix.io :dpaste.org
  (each [k v (pairs opts)]
    (tset options k v)))

{: setup
 : post-string
 : post-range
 : post-selection
 : post-buffer
 :post_string post-string
 :post_range post-range
 :post_selection post-selection
 :post_buffer post-buffer
 : cmd}
