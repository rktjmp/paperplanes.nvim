(local {: reduce : list-put : list-append : map-put} (require :paperplanes.fn))
(local fmt string.format)

(fn guess-syntax [{: filetype : extension}]
  ;; yes, typ/o/script (???)
  (let [known-filetypes ["abap" "abnf" "actionscript" "actionscript3" "ada"
                         "adl" "agda" "aheui" "alloy" "ambienttalk" "amdgpu"
                         "ampl" "ansys" "antlr" "antlr-actionscript"
                         "antlr-cpp" "antlr-csharp" "antlr-java" "antlr-objc"
                         "antlr-perl" "antlr-python" "antlr-ruby" "apacheconf"
                         "apl" "applescript" "arduino" "arrow" "arturo" "asc"
                         "asn1" "aspectj" "aspx-cs" "aspx-vb" "asymptote"
                         "augeas" "autohotkey" "autoit" "awk" "bare" "basemake"
                         "bash" "batch" "bbcbasic" "bbcode" "bc" "bdd"
                         "befunge" "berry" "bibtex" "blitzbasic" "blitzmax"
                         "blueprint" "bnf" "boa" "boo" "boogie" "bqn"
                         "brainfuck" "bst" "bugs" "c" "c-objdump" "ca65" "cadl"
                         "camkes" "capdl" "capnp" "carbon" "cbmbas" "cddl"
                         "ceylon" "cfc" "cfengine3" "cfm" "cfs" "chaiscript"
                         "chapel" "charmci" "cheetah" "cirru" "clay" "clean"
                         "clojure" "clojurescript" "cmake" "cobol" "cobolfree"
                         "coffeescript" "comal" "common-lisp" "componentpascal"
                         "console" "coq" "cplint" "cpp" "cpp-objdump" "cpsa"
                         "cr" "crmsh" "croc" "cryptol" "csharp" "csound"
                         "csound-document" "csound-score" "css" "css+django"
                         "css+genshitext" "css+lasso" "css+mako"
                         "css+mozpreproc" "css+myghty" "css+php" "css+ruby"
                         "css+smarty" "css+ul4" "cuda" "cypher" "cython" "d"
                         "d-objdump" "dart" "dasm16" "dax" "debcontrol"
                         "debsources" "delphi" "desktop" "devicetree" "dg"
                         "diff" "django" "docker" "doscon" "dpatch" "dtd"
                         "duel" "dylan" "dylan-console" "dylan-lid" "earl-grey"
                         "easytrieve" "ebnf" "ec" "ecl" "eiffel" "elixir" "elm"
                         "elpi" "emacs-lisp" "email" "erb" "erl" "erlang"
                         "evoque" "execline" "extempore" "ezhil" "factor" "fan"
                         "fancy" "felix" "fennel" "fift" "fish" "flatline"
                         "floscript" "forth" "fortran" "fortranfixed" "foxpro"
                         "freefem" "fsharp" "fstar" "func" "futhark" "gap"
                         "gap-console" "gas" "gcode" "gdscript" "genshi"
                         "genshitext" "gherkin" "glsl" "gnuplot" "go" "golo"
                         "gooddata-cl" "gosu" "graphql" "graphviz" "groff"
                         "groovy" "gsql" "gst" "haml" "handlebars" "haskell"
                         "haxe" "haxeml" "hexdump" "hlsl" "hsail" "hspec"
                         "html" "html+cheetah" "html+django" "html+evoque"
                         "html+genshi" "html+handlebars" "html+lasso"
                         "html+mako" "html+myghty" "html+ng2" "html+php"
                         "html+smarty" "html+twig" "html+ul4" "html+velocity"
                         "http" "hybris" "hylang" "i6t" "icon" "idl" "idris"
                         "iex" "igor" "inform6" "inform7" "ini" "io" "ioke"
                         "irc" "isabelle" "j" "jags" "jasmin" "java"
                         "javascript+cheetah" "javascript+django"
                         "javascript+lasso" "javascript+mako"
                         "javascript+mozpreproc" "javascript+myghty"
                         "javascript+php" "javascript+ruby" "javascript+smarty"
                         "jcl" "jlcon" "jmespath" "js" "js+genshitext" "js+ul4"
                         "jsgf" "jslt" "json" "jsonld" "jsonnet" "jsp" "jsx"
                         "julia" "juttle" "k" "kal" "kconfig" "kmsg" "koka"
                         "kotlin" "kql" "kuin" "lasso" "ldapconf" "ldif" "lean"
                         "less" "lighttpd" "lilypond" "limbo" "liquid"
                         "literate-agda" "literate-cryptol" "literate-haskell"
                         "literate-idris" "livescript" "llvm" "llvm-mir"
                         "llvm-mir-body" "logos" "logtalk" "lsl" "lua"
                         "macaulay2" "make" "mako" "maql" "mask" "mason"
                         "mathematica" "matlab" "matlabsession" "maxima"
                         "mcfunction" "mcschema" "md" "meson" "mime" "minid"
                         "miniscript" "mips" "modelica" "modula2" "monkey"
                         "monte" "moocode" "moonscript" "mosel"
                         "mozhashpreproc" "mozpercentpreproc" "mql" "mscgen"
                         "mupad" "mxml" "myghty" "mysql" "nasm" "ncl" "nemerle"
                         "nesc" "nestedtext" "newlisp" "newspeak" "ng2" "nginx"
                         "nimrod" "nit" "nixos" "nodejsrepl" "notmuch" "nsis"
                         "numpy" "nusmv" "objdump" "objdump-nasm" "objective-c"
                         "objective-c++" "objective-j" "ocaml" "octave" "odin"
                         "omg-idl" "ooc" "opa" "openedge" "openscad" "output"
                         "pacmanconf" "pan" "parasail" "pawn" "peg" "perl"
                         "perl6" "phix" "php" "pig" "pike" "pkgconfig"
                         "plpgsql" "pointless" "pony" "portugol"
                         "postgres-explain" "postgresql" "postscript" "pot"
                         "pov" "powershell" "praat" "procfile" "prolog"
                         "promql" "properties" "protobuf" "prql" "psql" "psysh"
                         "ptx" "pug" "puppet" "pwsh-session" "py+ul4" "py2tb"
                         "pycon" "pypylog" "pytb" "python" "python2" "q"
                         "qbasic" "qlik" "qml" "qvto" "racket" "ragel"
                         "ragel-c" "ragel-cpp" "ragel-d" "ragel-em"
                         "ragel-java" "ragel-objc" "ragel-ruby" "rb" "rbcon"
                         "rconsole" "rd" "reasonml" "rebol" "red" "redcode"
                         "registry" "resourcebundle" "rexx" "rhtml" "ride"
                         "rita" "rng-compact" "roboconf-graph"
                         "roboconf-instances" "robotframework" "rql" "rsl"
                         "rst" "rust" "sarl" "sas" "sass" "savi" "scala"
                         "scaml" "scdoc" "scheme" "scilab" "scss" "sed" "sgf"
                         "shen" "shexc" "sieve" "silver" "singularity" "slash"
                         "slim" "slurm" "smali" "smalltalk" "smarty" "smithy"
                         "sml" "snbt" "snobol" "snowball" "solidity" "sophia"
                         "sp" "sparql" "spec" "spice" "splus" "sql" "sql+jinja"
                         "sqlite3" "squidconf" "srcinfo" "ssp" "stan" "stata"
                         "supercollider" "swift" "swig" "systemd"
                         "systemverilog" "tads3" "tal" "tap" "tasm" "tcl"
                         "tcsh" "tcshcon" "tea" "teal" "teratermmacro"
                         "termcap" "terminfo" "terraform" "tex" "text" "thrift"
                         "ti" "tid" "tlb" "tls" "tnt" "todotxt" "toml"
                         "trac-wiki" "trafficscript" "treetop" "ts" "tsql"
                         "turtle" "twig" "typoscript" "typoscriptcssdata"
                         "typoscripthtmldata" "ucode" "ul4" "unicon"
                         "unixconfig" "urbiscript" "usd" "vala" "vb.net"
                         "vbscript" "vcl" "vclsnippets" "vctreestatus"
                         "velocity" "verifpal" "verilog" "vgl" "vhdl" "vim"
                         "visualprolog" "visualprologgrammar" "vyper" "wast"
                         "wdiff" "webidl" "wgsl" "whiley" "wikitext" "wowtoc" "wren"
                         "x10" "xml" "xml+cheetah" "xml+django" "xml+evoque" "xml+lasso"
                         "xml+mako" "xml+myghty" "xml+php" "xml+ruby" "xml+smarty" "xml+ul4"
                         "xml+velocity" "xorg.conf" "xpp" "xquery" "xslt" "xtend" "xul+mozpreproc"
                         "yaml" "yaml+jinja" "yang" "yara" "zeek" "zephir" "zig" "zone"]]
    (case-try
      (accumulate [matched nil
                   _ known (ipairs known-filetypes)
                   :until (~= nil matched)]
        (case known
          (where (= filetype)) filetype
          (where (= extension)) extension)) syntax
      syntax
      (catch
        nil :text))))

(fn completions []
  {:create [:expiry_days= :syntax= :title=]})

(fn create [content metadata options on-complete]
  (let [curl (require :paperplanes.curl)
        temp-filename (vim.fn.tempname)
        args (accumulate [a [:-F (.. "content=<" temp-filename)
                             ;; dpaste will 400 if it does not recognise the syntax
                             ;; so best-attempt at this otherwise use text
                             :-F (.. "syntax=" (guess-syntax metadata))
                             :-F (.. "title=" (or options.title metadata.filename :paste.txt))]
                          key val (pairs options)]
               (doto a
                 (table.insert :-F)
                 (table.insert (.. key "=" val))))
        resp-handler (fn [{: response : status : headers}]
                           (vim.loop.fs_unlink temp-filename)
                           (case status
                             201 (let [url (. headers :location 1)]
                                  (on-complete url {}))
                             _ (on-complete nil response)))]
    (with-open [outfile (io.open temp-filename :w)]
               (outfile:write content))
    (curl :https://dpaste.com/api/v2/ args resp-handler)))

{: create
 : completions}
