(local {:format fmt} string)
(local {:loop uv} vim)
(local {: exec} (require :paperplanes.exec))

(fn curl [request-args response-handler]
  (assert (= (vim.fn.executable :curl) 1)
         (fmt "paperplanes.nvim could not find %q executable" :curl))
  ;; request-args -> curl args that actually post to the provider
  ;; response-handler -> should extract url from provider response or nil
  ;;
  ;; we always set some default options for curl:
  ;; --silent: no progress meter on strerr
  ;; --show-error: still render runtime errors on strerr
  ;; --write-out: always write the http response code after response
  (let [args (vim.tbl_flatten ["--silent"
                               "--show-error"
                               "--write-out" "\n%{response_code}"
                               request-args])
        on-exit (fn [exit-code output errors]
                  ;; enforce that we can acually handle the response we got back
                  (assert (= "" errors)
                          (fmt "paperplanes encountered an internal error: %q" errors))
                  (assert (= 0 exit-code)
                          (fmt "curl exited with non-zero status: %q" exit-code))
                  ;; extract status code, which will always be the last line because of
                  ;; our --write-out flag, pass the response back to the provider which
                  ;; should return url or nil, err
                  (let [(response status) (string.match output "(.*)\n(%d+)$")
                        status (tonumber status)]
                    (response-handler response status)))]
    (exec :curl args on-exit)))

(values curl)
