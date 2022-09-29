(let [{: view} (require :hotpot.fennel)
      {: build : check} (require :hotpot.api.make)
      (oks errs) (build "./fnl" {:force? true :verbosity 1}
                        "./fnl/(.+)" (fn [p {: join-path}] (join-path :./lua p)))]
  (values ""))
