local fmt = string.format
local uv = (vim.uv or vim.loop)
local function guess_syntax(_1_)
  local filetype = _1_["filetype"]
  local extension = _1_["extension"]
  local known_filetypes = {"abap", "abnf", "actionscript", "actionscript3", "ada", "adl", "agda", "aheui", "alloy", "ambienttalk", "amdgpu", "ampl", "ansys", "antlr", "antlr-actionscript", "antlr-cpp", "antlr-csharp", "antlr-java", "antlr-objc", "antlr-perl", "antlr-python", "antlr-ruby", "apacheconf", "apl", "applescript", "arduino", "arrow", "arturo", "asc", "asn1", "aspectj", "aspx-cs", "aspx-vb", "asymptote", "augeas", "autohotkey", "autoit", "awk", "bare", "basemake", "bash", "batch", "bbcbasic", "bbcode", "bc", "bdd", "befunge", "berry", "bibtex", "blitzbasic", "blitzmax", "blueprint", "bnf", "boa", "boo", "boogie", "bqn", "brainfuck", "bst", "bugs", "c", "c-objdump", "ca65", "cadl", "camkes", "capdl", "capnp", "carbon", "cbmbas", "cddl", "ceylon", "cfc", "cfengine3", "cfm", "cfs", "chaiscript", "chapel", "charmci", "cheetah", "cirru", "clay", "clean", "clojure", "clojurescript", "cmake", "cobol", "cobolfree", "coffeescript", "comal", "common-lisp", "componentpascal", "console", "coq", "cplint", "cpp", "cpp-objdump", "cpsa", "cr", "crmsh", "croc", "cryptol", "csharp", "csound", "csound-document", "csound-score", "css", "css+django", "css+genshitext", "css+lasso", "css+mako", "css+mozpreproc", "css+myghty", "css+php", "css+ruby", "css+smarty", "css+ul4", "cuda", "cypher", "cython", "d", "d-objdump", "dart", "dasm16", "dax", "debcontrol", "debsources", "delphi", "desktop", "devicetree", "dg", "diff", "django", "docker", "doscon", "dpatch", "dtd", "duel", "dylan", "dylan-console", "dylan-lid", "earl-grey", "easytrieve", "ebnf", "ec", "ecl", "eiffel", "elixir", "elm", "elpi", "emacs-lisp", "email", "erb", "erl", "erlang", "evoque", "execline", "extempore", "ezhil", "factor", "fan", "fancy", "felix", "fennel", "fift", "fish", "flatline", "floscript", "forth", "fortran", "fortranfixed", "foxpro", "freefem", "fsharp", "fstar", "func", "futhark", "gap", "gap-console", "gas", "gcode", "gdscript", "genshi", "genshitext", "gherkin", "glsl", "gnuplot", "go", "golo", "gooddata-cl", "gosu", "graphql", "graphviz", "groff", "groovy", "gsql", "gst", "haml", "handlebars", "haskell", "haxe", "haxeml", "hexdump", "hlsl", "hsail", "hspec", "html", "html+cheetah", "html+django", "html+evoque", "html+genshi", "html+handlebars", "html+lasso", "html+mako", "html+myghty", "html+ng2", "html+php", "html+smarty", "html+twig", "html+ul4", "html+velocity", "http", "hybris", "hylang", "i6t", "icon", "idl", "idris", "iex", "igor", "inform6", "inform7", "ini", "io", "ioke", "irc", "isabelle", "j", "jags", "jasmin", "java", "javascript+cheetah", "javascript+django", "javascript+lasso", "javascript+mako", "javascript+mozpreproc", "javascript+myghty", "javascript+php", "javascript+ruby", "javascript+smarty", "jcl", "jlcon", "jmespath", "js", "js+genshitext", "js+ul4", "jsgf", "jslt", "json", "jsonld", "jsonnet", "jsp", "jsx", "julia", "juttle", "k", "kal", "kconfig", "kmsg", "koka", "kotlin", "kql", "kuin", "lasso", "ldapconf", "ldif", "lean", "less", "lighttpd", "lilypond", "limbo", "liquid", "literate-agda", "literate-cryptol", "literate-haskell", "literate-idris", "livescript", "llvm", "llvm-mir", "llvm-mir-body", "logos", "logtalk", "lsl", "lua", "macaulay2", "make", "mako", "maql", "mask", "mason", "mathematica", "matlab", "matlabsession", "maxima", "mcfunction", "mcschema", "md", "meson", "mime", "minid", "miniscript", "mips", "modelica", "modula2", "monkey", "monte", "moocode", "moonscript", "mosel", "mozhashpreproc", "mozpercentpreproc", "mql", "mscgen", "mupad", "mxml", "myghty", "mysql", "nasm", "ncl", "nemerle", "nesc", "nestedtext", "newlisp", "newspeak", "ng2", "nginx", "nimrod", "nit", "nixos", "nodejsrepl", "notmuch", "nsis", "numpy", "nusmv", "objdump", "objdump-nasm", "objective-c", "objective-c++", "objective-j", "ocaml", "octave", "odin", "omg-idl", "ooc", "opa", "openedge", "openscad", "output", "pacmanconf", "pan", "parasail", "pawn", "peg", "perl", "perl6", "phix", "php", "pig", "pike", "pkgconfig", "plpgsql", "pointless", "pony", "portugol", "postgres-explain", "postgresql", "postscript", "pot", "pov", "powershell", "praat", "procfile", "prolog", "promql", "properties", "protobuf", "prql", "psql", "psysh", "ptx", "pug", "puppet", "pwsh-session", "py+ul4", "py2tb", "pycon", "pypylog", "pytb", "python", "python2", "q", "qbasic", "qlik", "qml", "qvto", "racket", "ragel", "ragel-c", "ragel-cpp", "ragel-d", "ragel-em", "ragel-java", "ragel-objc", "ragel-ruby", "rb", "rbcon", "rconsole", "rd", "reasonml", "rebol", "red", "redcode", "registry", "resourcebundle", "rexx", "rhtml", "ride", "rita", "rng-compact", "roboconf-graph", "roboconf-instances", "robotframework", "rql", "rsl", "rst", "rust", "sarl", "sas", "sass", "savi", "scala", "scaml", "scdoc", "scheme", "scilab", "scss", "sed", "sgf", "shen", "shexc", "sieve", "silver", "singularity", "slash", "slim", "slurm", "smali", "smalltalk", "smarty", "smithy", "sml", "snbt", "snobol", "snowball", "solidity", "sophia", "sp", "sparql", "spec", "spice", "splus", "sql", "sql+jinja", "sqlite3", "squidconf", "srcinfo", "ssp", "stan", "stata", "supercollider", "swift", "swig", "systemd", "systemverilog", "tads3", "tal", "tap", "tasm", "tcl", "tcsh", "tcshcon", "tea", "teal", "teratermmacro", "termcap", "terminfo", "terraform", "tex", "text", "thrift", "ti", "tid", "tlb", "tls", "tnt", "todotxt", "toml", "trac-wiki", "trafficscript", "treetop", "ts", "tsql", "turtle", "twig", "typoscript", "typoscriptcssdata", "typoscripthtmldata", "ucode", "ul4", "unicon", "unixconfig", "urbiscript", "usd", "vala", "vb.net", "vbscript", "vcl", "vclsnippets", "vctreestatus", "velocity", "verifpal", "verilog", "vgl", "vhdl", "vim", "visualprolog", "visualprologgrammar", "vyper", "wast", "wdiff", "webidl", "wgsl", "whiley", "wikitext", "wowtoc", "wren", "x10", "xml", "xml+cheetah", "xml+django", "xml+evoque", "xml+lasso", "xml+mako", "xml+myghty", "xml+php", "xml+ruby", "xml+smarty", "xml+ul4", "xml+velocity", "xorg.conf", "xpp", "xquery", "xslt", "xtend", "xul+mozpreproc", "yaml", "yaml+jinja", "yang", "yara", "zeek", "zephir", "zig", "zone"}
  local function _2_(...)
    local _3_ = ...
    if (nil ~= _3_) then
      local syntax = _3_
      return syntax
    elseif (_3_ == nil) then
      return "text"
    else
      return nil
    end
  end
  local function _5_()
    local matched = nil
    for _, known in ipairs(known_filetypes) do
      if (nil ~= matched) then break end
      local _6_, _7_ = known
      if (_6_ == filetype) then
        matched = filetype
      elseif (_6_ == extension) then
        matched = extension
      else
        matched = nil
      end
    end
    return matched
  end
  return _2_(_5_())
end
local function completions()
  return {create = {"expiry_days=", "syntax=", "title="}}
end
local function create(content, metadata, options, on_complete)
  local curl = require("paperplanes.curl")
  local temp_filename = vim.fn.tempname()
  local args
  do
    local a = {"-F", ("content=<" .. temp_filename), "-F", ("syntax=" .. guess_syntax(metadata)), "-F", ("title=" .. (options.title or metadata.filename or "paste.txt"))}
    for key, val in pairs(options) do
      table.insert(a, "-F")
      table.insert(a, (key .. "=" .. val))
      a = a
    end
    args = a
  end
  local resp_handler
  local function _10_(_9_)
    local response = _9_["response"]
    local status = _9_["status"]
    local headers = _9_["headers"]
    uv.fs_unlink(temp_filename)
    if (status == 201) then
      local url = headers.location[1]
      return on_complete(url, {})
    else
      local _ = status
      return on_complete(nil, response)
    end
  end
  resp_handler = _10_
  do
    local outfile = io.open(temp_filename, "w")
    local function close_handlers_12_(ok_13_, ...)
      outfile:close()
      if ok_13_ then
        return ...
      else
        return error(..., 0)
      end
    end
    local function _13_()
      return outfile:write(content)
    end
    local _15_
    do
      local t_14_ = _G
      if (nil ~= t_14_) then
        t_14_ = t_14_.package
      else
      end
      if (nil ~= t_14_) then
        t_14_ = t_14_.loaded
      else
      end
      if (nil ~= t_14_) then
        t_14_ = t_14_.fennel
      else
      end
      _15_ = t_14_
    end
    local or_19_ = _15_ or _G.debug
    if not or_19_ then
      local function _20_()
        return ""
      end
      or_19_ = {traceback = _20_}
    end
    close_handlers_12_(_G.xpcall(_13_, or_19_.traceback))
  end
  return curl("https://dpaste.com/api/v2/", args, resp_handler)
end
return {create = create, completions = completions}