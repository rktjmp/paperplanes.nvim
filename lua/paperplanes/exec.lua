local uv = (vim.uv or vim.loop)
local function exec(cmd, args, on_exit, _3fon_spawn)
  _G.assert((nil ~= on_exit), "Missing argument on-exit on fnl/paperplanes/exec.fnl:3")
  _G.assert((nil ~= args), "Missing argument args on fnl/paperplanes/exec.fnl:3")
  _G.assert((nil ~= cmd), "Missing argument cmd on fnl/paperplanes/exec.fnl:3")
  local process = {stdout = uv.new_pipe(false), stderr = uv.new_pipe(false), stdin = uv.new_pipe(false), output = {}, errput = {}, handle = nil}
  local save_io
  local function _1_(into, err, data)
    assert(not err, err)
    return table.insert(into, data)
  end
  save_io = _1_
  local opts = {args = args, stdio = {process.stdin, process.stdout, process.stderr}}
  local exit
  local function _2_(exit_code)
    uv.close(process.stdin)
    uv.close(process.stdout)
    uv.close(process.stderr)
    uv.close(process.handle)
    local errors = table.concat(process.errput)
    local output = table.concat(process.output)
    return on_exit(exit_code, output, errors)
  end
  exit = vim.schedule_wrap(_2_)
  local handle, _pid = uv.spawn(cmd, opts, exit)
  process.handle = handle
  local function _4_()
    local _3_ = process.output
    local function _5_(...)
      return save_io(_3_, ...)
    end
    return _5_
  end
  uv.read_start(process.stdout, _4_())
  local function _7_()
    local _6_ = process.errput
    local function _8_(...)
      return save_io(_6_, ...)
    end
    return _8_
  end
  uv.read_start(process.stderr, _7_())
  if _3fon_spawn then
    _3fon_spawn(process)
    return uv.shutdown(process.stdin)
  else
    return nil
  end
end
return {exec = exec}