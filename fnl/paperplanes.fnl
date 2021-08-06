(local uv vim.loop)
(local {: get-range
        : get-selection
        : get-buf} (require :paperplanes.util.get_text))

(local options {:register :+
                :provider "0x0.st"})

(fn assert-curl []
  (assert (= (vim.fn.executable :curl) 1)
          "paperplanes.nvim could not find curl executable"))

(fn get-option [name]
  (. options name))

(fn get-provider [provider]
  (match (. (require :paperplanes.providers) provider)
    any any
    nil (error (.. "paperplanes doesn't known provider: " provider))))

(fn get-buffer-info [buffer]
  ;; try to get any metadata from the buffer, this includes:
  ;; path, filename, extension, filetype
  (local api vim.api)
  (api.nvim_buf_call buffer (fn []
                              {:path (vim.fn.expand "%:p")
                               :filename (vim.fn.expand "%:t")
                               :extension (vim.fn.expand "%:e")
                               :filetype vim.bo.filetype})))
                            
(fn make-post [post-args provider-cb final-cb]
  ;; post-args -> curl args that actually post to the provider
  ;; provider-cb -> should extract url from provider response or nil
  ;; final-cb -> finnaly pass url or nil to original caller
  (assert-curl)
  (assert final-cb "paperplanes provided no final cb")
  (let [stdout (uv.new_pipe false)
        stderr (uv.new_pipe false)
        register (get-option :register)
        cmd "curl"
        args (vim.tbl_flatten ["--silent" ;; disable progress meter on stderr
                               "--show-error" ;; still render actual errors to stderr
                               ;; instead of parsing -i we just write out the code
                               "--write-out" "\n%{response_code}" 
                               post-args])
        output []
        errput []]

    (fn on-exit [code sig]
      (uv.close stdout)
      (uv.close stderr)
      (let [errors (table.concat errput)
            raw (table.concat output)]

        ;; maybe give up
        (if (not (= "" errors))
          (error (.. "paperplanes encountered an internal error: " errors)))
        ;; probably never get here because of stderr check
        (if (not (= code 0))
          (error (.. "curl exited with non-zero status: " code)))

        ;; extract status code, which will always be the last line because of
        ;; our --write-out flag
        (local (response status) (string.match raw "(.*)\n(%d+)$"))
        ;; cb should return url or nil, err
        (local (url err) (provider-cb response (tonumber status)))
        (final-cb url err)))

    (print (string.format "%s'ing..." (get-option :provider)))

    (uv.spawn cmd
              {: args :stdio [nil stdout stderr]}
              (vim.schedule_wrap on-exit))

    (uv.read_start stderr (fn [err data]
                            (assert (not err) err)
                            (if data (table.insert errput data))))
    (uv.read_start stdout (fn [err data]
                            (assert (not err) err)
                            (if data (table.insert output data))))))

;; do we ever post a file, really?
;;(fn post-file [file]
;;  (local provider (get-provider (get-option :provider)))
;;  (local (args after) (provider.post-file file))
;;  (make-post args after))

(fn post-string [content meta cb]
  (local provider (get-provider (get-option :provider)))
  (local (args after) (provider.post-string content meta))
  (make-post args after cb))

(fn post-range [buf start stop cb]
  (-> (get-range buf start stop)
      (post-string (get-buffer-info buf) cb)))

(fn post-selection [cb]
  (-> (get-selection)
      (post-string (get-buffer-info 0) cb)))

(fn post-buffer [buffer cb]
  (assert buffer "paperplanes post-buffer: must provide buffer")
  (-> (get-buf buffer)
      (post-string (get-buffer-info buffer) cb)))

(fn cmd [start stop]
  (fn maybe-set-and-print [url err]
    ;; print url, or print register and url or raise error
    (match [url err]
      [nil err] (error (.. "paperplanes got no url back from provider: " err))
      [url _] (let [reg (get-option :register)]
                (if reg
                  (do
                    (vim.fn.setreg reg url)
                    (print (string.format "\"%s = %s" reg url)))
                  (print url)))))
  (post-range 0 start stop maybe-set-and-print))

(fn setup [opts]
  (assert-curl)
  ;; options:
  ;;  register : register name | false (do not store)
  ;;  provider : :0x0.st :ix.io :dpaste.org
  (each [k v (pairs opts)]
    (tset options k v)))

{: setup
 ;; : post-file
 : post-string
 : post-range
 : post-selection
 : post-buffer
 ;; :post_file post-file
 :post_string post-string
 :post_range post-range
 :post_selection post-selection
 :post_buffer post-buffer
 : cmd}
