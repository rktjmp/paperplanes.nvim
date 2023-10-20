return {
  -- compiler = {
  --   modules = { correlate = true }
  -- },
  build = {
    {atomic = true, verbose = true},
    {"fnl/**/*.fnl", true}
  },
  clean = true
}
