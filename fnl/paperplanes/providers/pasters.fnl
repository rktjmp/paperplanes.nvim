(local {: set-field} (require :paperplanes.util.providers))

(fn make [content-arg meta]
  (local args (doto []
                    (table.insert :--data-binary)
                    (table.insert content-arg)
                    (table.insert "https://paste.rs")))

  (fn after [response status]
    (match status
      ;;returns url as "url\n" so we need to strip the new line
      201 (string.match response "^(https?://.*)\n")
      _ (values nil response)))

  (values args after))

(fn post-string [string meta]
  (make (.. string) meta))

(fn post-file [file meta]
  (make (.. "@" file) meta))

{: post-string
 : post-file}
