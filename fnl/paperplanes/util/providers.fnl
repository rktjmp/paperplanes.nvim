(fn set-field [t key value]
  ;; set form field if it has a value to take
  (when (and value (~= "" value))
    (table.insert t :-F)
    (table.insert t (.. key "=" value)))
  t)

{: set-field}
