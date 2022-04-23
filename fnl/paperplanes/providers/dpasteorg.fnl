(local {: set-field : opts-to-fields} (require :paperplanes.util.providers))

(fn make [content-arg meta opts]
  (local args (doto (opts-to-fields opts)
                    (set-field :format :default)
                    (set-field :content content-arg)
                    (set-field :filename meta.filename)
                    (table.insert "https://dpaste.org/api/")))

  ;; dpaste acceps a lexer, but will 400 error if it doesn't recognise it
  ;; so we will instead rely on the filename sniffer, which falls back to
  ;; text if doesn't recognise the extension.

  (fn after [response status]
    (match status
      200 (string.match response "\"(.*)\"")
      _ (values nil response)))

  (values args after))

(fn post-string [string meta opts]
  (make string meta opts))

(fn post-file [file meta opts]
  ;; dpaste only accepts a string but curl can inject contents
  (make (.. "<" file) meta opts))

{: post-string
 : post-file}
