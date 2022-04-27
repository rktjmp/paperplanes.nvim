(local {:format fmt} string)
(local {:loop uv} vim)

(lambda execute-request [cmd args on-exit]
  (let [io {:stdout (uv.new_pipe false)
            :stderr (uv.new_pipe false)
            :output []
            :errput []}
        save-io (fn [into err data]
                  (assert (not err) err)
                  (table.insert into data))
        opts  {: args :stdio [nil io.stdout io.stderr]}
        exit (vim.schedule_wrap (fn [exit-code]
                                  (uv.close io.stdout)
                                  (uv.close io.stderr)
                                  (let [errors (table.concat io.errput)
                                        output (table.concat io.output)]
                                    (on-exit exit-code output errors))))]
    (uv.spawn cmd opts exit)
    (uv.read_start io.stderr (partial save-io io.errput))
    (uv.read_start io.stdout (partial save-io io.output))))

(lambda curl [cmd request-args provider-cb final-cb]
  (assert (= (vim.fn.executable cmd) 1)
          (fmt "paperplanes.nvim could not find %q executable" cmd))
  ;; cmd -> curl compatible exe
  ;; request-args -> curl args that actually post to the provider
  ;; provider-cb -> should extract url from provider response or nil
  ;; final-cb -> finally pass url or nil to original caller
  ;;
  ;; we always set some default options for curl:
  ;; --silent: no progress meter on strerr
  ;; --show-error: still render runtime errors on strerr
  ;; --write-out: always write the http response code after response
  ;; it's semi-important we always put these options ahead of those given to
  ;; us.
  (let [args (vim.tbl_flatten ["--silent"
                               "--show-error"
                               "--write-out" "\n%{response_code}"
                               request-args])
        on-exit (fn [exit-code output errors]
                  ;; enforce that we can acually handle the response we got back
                  (assert (= "" errors) (fmt "paperplanes encountered an internal error: %q" errors))
                  (assert (= 0 exit-code) (fmt "curl exited with non-zero status: %q" exit-code))
                  ;; extract status code, which will always be the last line because of
                  ;; our --write-out flag, pass the response back to the provider which
                  ;; should return url or nil, err
                  (let [(response status) (string.match output "(.*)\n(%d+)$")
                        status (tonumber status)
                        (url err) (provider-cb response status)]
                    ;; pass the provider response to caller to do whatever
                    (final-cb url err)))]
    (execute-request cmd args on-exit)))

(values curl)
