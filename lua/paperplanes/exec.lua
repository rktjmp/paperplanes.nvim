local uv = vim["loop"]
local function exec(cmd, args, on_exit)
  _G.assert((nil ~= on_exit), "Missing argument on-exit on fnl/paperplanes/exec.fnl:3")
  _G.assert((nil ~= args), "Missing argument args on fnl/paperplanes/exec.fnl:3")
  _G.assert((nil ~= cmd), "Missing argument cmd on fnl/paperplanes/exec.fnl:3")
  local io = {stdout = uv.new_pipe(false), stderr = uv.new_pipe(false), output = {}, errput = {}}
  local save_io
  local function _1_(into, err, data)
    assert(not err, err)
    return table.insert(into, data)
  end
  save_io = _1_
  local opts = {args = args, stdio = {nil, io.stdout, io.stderr}}
  local exit
  local function _2_(exit_code)
    uv.close(io.stdout)
    uv.close(io.stderr)
    local errors = table.concat(io.errput)
    local output = table.concat(io.output)
    return on_exit(exit_code, output, errors)
  end
  exit = vim.schedule_wrap(_2_)
  uv.spawn(cmd, opts, exit)
  local function _4_()
    local _3_ = io.errput
    local function _5_(...)
      return save_io(_3_, ...)
    end
    return _5_
  end
  uv.read_start(io.stderr, _4_())
  local function _7_()
    local _6_ = io.output
    local function _8_(...)
      return save_io(_6_, ...)
    end
    return _8_
  end
  return uv.read_start(io.stdout, _7_())
end
return {exec = exec}