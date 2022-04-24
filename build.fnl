(local fennel ((. (require :hotpot.api.fennel) :latest)))
(local uv vim.loop)

;;(tset package.loaded :fennel fennel)

(fn compile-file [in-path out-path]
  (with-open [f-in (io.open in-path :r)
              f-out (io.open out-path :w)]
             (print :compile-file in-path :-> out-path)
             (local lines (fennel.compile-string (f-in:read "*a") {:collate true}))
             (f-out:write lines)))

(fn compile-dir [in-dir out-dir]
  (print :compile-dir in-dir :=> out-dir)
  (let [scanner (uv.fs_scandir in-dir)]
    (var ok true)
    (each [name type #(uv.fs_scandir_next scanner) :until (not ok)]
      (match type
        "directory" (do
                      (local out-down (.. out-dir :/ name))
                      (local in-down (.. in-dir :/ name))
                      (vim.fn.mkdir out-down :p)
                      (compile-dir in-down out-down))
        "file" (let [out-file (.. out-dir :/ (string.gsub name ".fnl$" ".lua"))
                     in-file  (.. in-dir :/ name)]
                 (compile-file in-file out-file))))))


(fn copy-file [from to]
  (print from to))

(fn make-env-proxy []
  ;; Creates an env table containing our own functions,
  ;; but also proxies out to the real _G env.
  ;; We don't want to just insert the functions as globals because they will
  ;; leak outside the build module.
  (local env {: compile-dir
              : compile-file
              : copy-file})
  (setmetatable env {:__index (fn [table key]
                                (or (. _G key) nil))}))

(local spec (fennel.dofile "hotpotfile.fnl" {:env (make-env-proxy)}))

(spec.build)
