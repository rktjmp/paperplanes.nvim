(fn set-field [t key value]
  ;; set form field if it has a value to take
  (when (and value (~= "" value))
    (table.insert t :-F)
    (table.insert t (.. key "=" value)))
  (values t))

(fn opts-to-fields [opts]
  (let [fields []]
    (each [key value (pairs opts)]
      (set-field fields key value))
    (values fields)))

{: set-field
 : opts-to-fields}
