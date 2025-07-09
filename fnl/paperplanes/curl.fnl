(local {:format fmt} string)
(local {:loop uv} vim)
(local {: exec} (require :paperplanes.exec))

;; Wrap HTTP requests via exec curl to collect status code, headers and
;; response.

(λ clean-up [status-path header-path]
  (os.remove status-path)
  (os.remove header-path))

(λ process-return [status-path header-path response-body]
  (with-open [status-file (io.open status-path :r)
              header-file (io.open header-path :r)]
    (let [status (status-file:read :*n) ;; live dangerously, cast to number
          headers (-> (header-file:read :*a)
                      (vim.json.decode))]
      {: status : headers :response response-body})))

(fn curl [url request-args response-handler]
  (assert (= (vim.fn.executable :curl) 1)
         (fmt "paperplanes.nvim could not find %q executable" :curl))
  ;; request-args -> provider specific arguments
  ;; response-handler -> function to recieve {status (number), response (string), headers (table)}
  ;; we always set some default options for curl
  ;; --silent: no progress meter on strerr
  ;; --show-error: still render runtime errors on strerr
  ;; --write-out: explicitly collect status code and all headrs for provider
  (let [status-path (vim.fn.tempname)
        header-path (vim.fn.tempname)
        output-format (string.format
                        "%%output{%s}%%{response_code}%%output{%s}%%{header_json}"
                        status-path
                        header-path)
        args (-> (vim.iter [:--silent
                            :--show-error
                            :--write-out output-format
                            request-args
                            url])
                 (: :flatten)
                 (: :totable))
        on-exit (fn [exit-code output errors]
                  (case (values exit-code errors)
                    (0 "") (-> (process-return status-path header-path output)
                               (response-handler))
                    _ (let [msg "curl encounted an error:\nexit-code: %s\nerror message: %s"]
                        (clean-up status-path header-path)
                        (vim.notify (string.format msg exit-code errors) vim.log.levels.ERROR))))]
    (exec :curl args on-exit)))

(values curl)
