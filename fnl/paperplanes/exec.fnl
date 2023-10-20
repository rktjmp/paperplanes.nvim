(local {:loop uv} vim)

(lambda exec [cmd args on-exit]
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

{: exec}
