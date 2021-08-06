(local {: set-field} (require :paperplanes.util.providers))

(fn make [content-arg meta]
  (local args (doto []
                    (set-field :f:1 content-arg)
                    (set-field :name:1 meta.filename)
                    (set-field :ext:1 meta.extension)
                    (table.insert "http://ix.io")))

  (fn after [response status]
    (match status
      ;;returns url as "url\n" so we need to strip the new line
      200 (string.match response "(http://.*)\n")
      _ (values nil response)))

  (values args after))

(fn post-string [string meta]
  (make (.. string) meta))

(fn post-file [file meta]
  (make (.. "<" file) meta))

{: post-string
 : post-file}