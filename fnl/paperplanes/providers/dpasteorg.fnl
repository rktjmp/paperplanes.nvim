(local {: set-field} (require :paperplanes.util.providers))

(fn make [content-arg meta]
  (local args (doto []
                    (set-field :format :default)
                    (set-field :content content-arg)
                    (set-field :filename meta.filename)
                    (table.insert "https://dpaste.org/api/")))

  ;; dpaste acceps a lexer, but will 400 error if it doesn't recognise it
  ;; so we will instead rely on the filename sniffer, which falls back to
  ;; text if doesn't recognise the extension.

  (fn after [response status]
    (print response status)
    (match status
      200 (string.match response "\"(.*)\"")
      _ (values nil response)))
    
  (values args after))

(fn post-string [string meta]
  (make string meta))

(fn post-file [file meta]
  ;; dpaste only accepts a string but curl can inject contents
  (make (.. "<" file) meta))

{: post-string
 : post-file}
