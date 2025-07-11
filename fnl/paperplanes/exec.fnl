(local uv (or vim.uv vim.loop))

(λ exec [cmd args on-exit ?on-spawn]
  (let [process {:stdout (uv.new_pipe false)
                 :stderr (uv.new_pipe false)
                 :stdin (uv.new_pipe false)
                 :output []
                 :errput []
                 :handle nil}
        save-io (fn [into err data]
                  (assert (not err) err)
                  (table.insert into data))
        opts  {: args :stdio [process.stdin process.stdout process.stderr]}
        exit (vim.schedule_wrap (fn [exit-code]
                                  (uv.close process.stdin)
                                  (uv.close process.stdout)
                                  (uv.close process.stderr)
                                  (uv.close process.handle)
                                  (let [errors (table.concat process.errput)
                                        output (table.concat process.output)]
                                    (on-exit exit-code output errors))))
        (handle _pid) (uv.spawn cmd opts exit)]
    (set process.handle handle)
    (uv.read_start process.stdout (partial save-io process.output))
    (uv.read_start process.stderr (partial save-io process.errput))
    (when ?on-spawn
      (?on-spawn process)
      (uv.shutdown process.stdin))))

{: exec}
