(local {: reduce : list-put : list-append : map-put} (require :paperplanes.fn))
(local fmt string.format)

(fn filetype->lexer [filetype]
  ;; list got by posting an unknown lexer to dpaste, returns list of supported types
  ;; yes, typ_o_script (???)
  (let [known-filetypes ["applescript" "arduino" "bash" "bat" "c" "clojure"
                         "cmake" "coffee-script" "common-lisp" "console" "cpp"
                         "cpp-objdump" "csharp" "css" "cuda" "d" "dart,
                         delphi" "diff" "django" "docker" "elixir" "erlang"
                         "go" "handlebars" "haskell" "html" "html+django"
                         "ini" "ipythonconsole" "irc" "java" "js" "json" "jsx"
                         "kotlin" "less" "lua" "make" "matlab" "nginx" "numpy"
                         "objective-c" "perl" "php" "postgresql" "python" "rb"
                         "rst" "rust" "sass" "scss" "sol" "sql" "swift" "tex"
                         "typoscript" "vim" "xml" "xslt" "yaml"]]
    (accumulate [matched nil
                 _ kt (ipairs known-filetypes)
                 :until (~= nil matched)]
                (if (= kt filetype) kt))))

(fn provide [content metadata opts on-complete]
  ;; dpaste accepts a lexer option, but will 400 error if it doesn't recognise
  ;; it so we will instead rely on the filename sniffer, which falls back to
  ;; text if doesn't recognise the extension.
  (let [curl (require :paperplanes.curl)
        temp-filename (vim.fn.tempname)
        defaults {:format :default
                  :lexer (filetype->lexer metadata.filetype)
                  :filename metadata.filename}
        args (-> (reduce opts defaults #(map-put $3 $1 $2))
                 (reduce [] #(list-append $3 [:--data-urlencode (fmt "%s=%s" $1 $2)]))
                 (list-append [:--data-urlencode (fmt "content@%s" temp-filename)])
                 (list-put "https://dpaste.org/api/"))
        _ (print (vim.inspect defaults))
        resp-handler (fn [response status]
                       (vim.loop.fs_unlink temp-filename)
                       (match status
                         200 (on-complete (string.match response "\"(.*)\""))
                         _ (on-complete nil response)))]
    (with-open [outfile (io.open temp-filename :w)]
               (outfile:write content))
    (curl args resp-handler)))

(values provide)

