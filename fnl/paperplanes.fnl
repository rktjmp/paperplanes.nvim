(local uv vim.loop)
(local {: get-range
        : get-selection
        : get-buf} (require :paperplanes.util.get_text))
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

(fn get-buffer-meta [buffer]
  ;; try to get any metadata from the buffer, this includes:
  ;; path, filename, extension, filetype
  (vim.api.nvim_buf_call buffer #(values {:path (vim.fn.expand "%:p")
                                          :filename (vim.fn.expand "%:t")
                                          :extension (vim.fn.expand "%:e")
                                          :filetype vim.bo.filetype})))

(fn execute-request [post-args provider-cb final-cb]
  ;; post-args -> curl args that actually post to the provider
  ;; provider-cb -> should extract url from provider response or nil
  ;; final-cb -> finnaly pass url or nil to original caller
  (assert final-cb "paperplanes provided no final cb")
  (let [stdout (uv.new_pipe false)
        stderr (uv.new_pipe false)
        cmd (get-option :cmd)
        _ (assert (= (vim.fn.executable cmd) 1)
                  (fmt "paperplanes.nvim could not find %q executable" cmd))
        ;; we always set some default options for curl:
        ;; --silent: no progress meter on strerr
        ;; --show-error: still render runtime errors on strerr
        ;; --write-out: always write the http response code after response
        args (vim.tbl_flatten ["--silent"
                               "--show-error"
                               "--write-out" "\n%{response_code}"
                               post-args])
        ;; we will collect stdout and strerr into these buckets then
        ;; return the entire string once curl is finished.
        output []
        errput []]

    (fn on-exit [code sig]
      (uv.close stdout)
      (uv.close stderr)
      (let [errors (table.concat errput)
            raw (table.concat output)]
        ;; enforce that we can acually handle the response we got back
        (assert (= "" errors) (fmt "paperplanes encountered an internal error: %q" errors))
        (assert (= 0 code) (fmt "curl exited with non-zero status: %q" code))
        ;; extract status code, which will always be the last line because of
        ;; our --write-out flag, pass the response back to the provider which
        ;; should return url or nil, err
        (let [(response status) (string.match raw "(.*)\n(%d+)$")
              status (tonumber status)
              (url err) (provider-cb response status)]
          ;; pass the provider response to paperplanes to present to user
          (final-cb url err))))

    ;; alert the user that we're doing *something*, vim.notify probably didn't
    ;; exist in 0.5? try to use it if its around.
    (let [msg (fmt "%s'ing..." (get-option :provider))]
      (if vim.notify (vim.notify msg) (print msg))) 

    (uv.spawn cmd
              {: args :stdio [nil stdout stderr]}
              (vim.schedule_wrap on-exit))

    (uv.read_start stderr (fn [err data]
                            (assert (not err) err)
                            (if data (table.insert errput data))))
    (uv.read_start stdout (fn [err data]
                            (assert (not err) err)
                            (if data (table.insert output data))))))

(fn post-string [content meta cb]
  (let [provider (get-provider (get-option :provider))
        provider-opts (get-option :provider_options)
        (args after) (provider.post-string content meta provider-opts)]
    (execute-request args after cb)))

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
      [url _] (let [reg (get-option :register)]
                (if reg
                  (do
                    (vim.fn.setreg reg url)
                    (print (string.format "\"%s = %s" reg url)))
                  (print url)))))
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
