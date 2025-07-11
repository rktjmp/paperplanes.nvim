(local {:format fmt} string)
(local uv (or vim.uv vim.loop))

(fn completions []
  {:create [:command=nc :host= :port=]})

(fn find-command [options]
  (fn find-installed-netcat []
    (accumulate [command nil
                 _ test (ipairs [:nc :ncat :netcat])
                 &until command]
      (case (vim.fn.executable test)
        1 test)))

  (case-try
    options.command nil
    (find-installed-netcat) nil
    (-> ["Could not find executable `nc`, `ncat` or `netcat`, "
         "and no `command` provider option was set.\n"
         "Please install a netcat compatible tool or set `command`."]
        (table.concat "")
        (error))
    (catch
      command command)))

(fn create [content _content-metadata options on-complete]
  (let [{: exec} (require :paperplanes.exec)
        command (find-command options)
        host (or options.host :termbin.com)
        port (or options.port :9999)
        filename (vim.fn.tempname)
        on-exit (fn [exit-code output errors]
                  (uv.fs_unlink filename)
                  (case exit-code
                    0 (case (string.match output "(.+)\n.*")
                        url (on-complete url {})
                        nil (on-complete nil (fmt "Could not match url from output: %s" 
                                                  (vim.json.encode output))))
                    _ (on-complete nil (fmt "exit: %s, errors: %s" exit-code errors))))
        on-spawn (fn [process]
                   (let [{: stdin} process]
                     (each [line (io.lines filename)]
                       (uv.write stdin (.. line "\n")))))]
    (with-open [outfile (io.open filename :w)]
               (outfile:write content))
    (exec command [host port] on-exit on-spawn)))

{: create
 : completions}
