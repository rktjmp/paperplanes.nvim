;; (local {: compile-dir} ...)

(local watch {:fnl :build})

(fn build []
  (compile-dir "fnl" "lua"))

(fn clean []
  (clean-dir "lua"))

{: watch
 : build
 : clean}
