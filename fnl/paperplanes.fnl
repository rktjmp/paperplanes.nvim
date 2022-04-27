(local uv vim.loop)
(local {: get-range
        : get-selection
        : get-buf} (require :paperplanes.get_text))
(local {:format fmt} string)

;; default options to be clobbered by setup
(local options {:register :+
                :provider "0x0.st"
                :provider_options {}
                :cmd :curl})

(fn get-option [name]
  (. options name))

(fn get-provider [name]
  (let [providers (require :paperplanes.providers)
        provider (. providers name)]
    (or provider (error (fmt "paperplanes doesn't know provider: %q" name)))))

(fn execute-request [post-args provider-cb final-cb]
  ;; post-args -> curl args that actually post to the provider
  ;; provider-cb -> should extract url from provider response or nil
  ;; final-cb -> finnaly pass url or nil to original caller
  (assert final-cb "paperplanes provided no final cb")
  (let [cmd (get-option :cmd)
        request-handler (require :paperplanes.curl)
        ;; alert the user that we're doing *something*, vim.notify probably didn't
        ;; exist in 0.5? try to use it if its around.
        notify-attempt #(let [msg (fmt "%s'ing..." (get-option :provider))
                              show (or vim.notify print)]
                          (show msg))]
    (notify-attempt)
    (request-handler cmd post-args provider-cb final-cb)))

(fn get-buffer-meta [buffer]
  ;; try to get any metadata from the buffer, this includes:
  ;; path, filename, extension, filetype
  (vim.api.nvim_buf_call buffer #(values {:path (vim.fn.expand "%:p")
                                          :filename (vim.fn.expand "%:t")
                                          :extension (vim.fn.expand "%:e")
                                          :filetype vim.bo.filetype})))

(fn post-string [content meta cb]
  (let [provider (get-provider (get-option :provider))
        provider-opts (get-option :provider_options)
        (args resp-handler) (provider content meta provider-opts)]
    (execute-request args resp-handler cb)))

(fn post-range [buf start stop cb]
  (let [content (get-range buf start stop)
        buffer-meta (get-buffer-meta buf)]
    (post-string content buffer-meta cb)))

(fn post-selection [cb]
  (let [content (get-selection)
        buffer-meta (get-buffer-meta 0)]
    (post-string content buffer-meta cb)))

(fn post-buffer [buffer cb]
  (assert buffer "paperplanes post-buffer: must provide buffer")
  (let [content (get-buf buffer)
        buffer-meta (get-buffer-meta buffer)]
    (post-string content buffer-meta cb)))

(fn cmd [start stop]
  (fn maybe-set-and-print [url err]
    ;; print url, or print register and url or raise error
    (match [url err]
      [nil err] (error (.. "paperplanes got no url back from provider: " err))
      [url _] (let [reg (get-option :register)
                    set-reg #(and $1 (vim.fn.setreg $1 $2))
                    ;; not great ...
                    notify #(let [extra (if $2 (fmt "\"%s = " $2) "")
                                  msg (fmt "%s%s" extra $1)
                                  via (or vim.notify print)]
                              (via msg))]
                (set-reg reg url)
                (notify url reg))))
  (post-range 0 start stop maybe-set-and-print))

(fn setup [opts]
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
