local _local_1_ = vim
local uv = _local_1_["loop"]
local function exec(cmd, args, on_exit)
  _G.assert((nil ~= on_exit), "Missing argument on-exit on fnl/paperplanes/exec.fnl:3")
  _G.assert((nil ~= args), "Missing argument args on fnl/paperplanes/exec.fnl:3")
  _G.assert((nil ~= cmd), "Missing argument cmd on fnl/paperplanes/exec.fnl:3")
  local io = {stdout = uv.new_pipe(false), stderr = uv.new_pipe(false), output = {}, errput = {}}
  local save_io
  local function _2_(into, err, data)
    assert(not err, err)
    return table.insert(into, data)
  end
  save_io = _2_
  local opts = {args = args, stdio = {nil, io.stdout, io.stderr}}
  local exit
  local function _3_(exit_code)
    uv.close(io.stdout)
    uv.close(io.stderr)
    local errors = table.concat(io.errput)
    local output = table.concat(io.output)
    return on_exit(exit_code, output, errors)
  end
  exit = vim.schedule_wrap(_3_)
  uv.spawn(cmd, opts, exit)
  local function _5_()
    local _4_ = io.errput
    local function _6_(...)
      return save_io(_4_, ...)
    end
    return _6_
  end
  uv.read_start(io.stderr, _5_())
  local function _8_()
    local _7_ = io.output
    local function _9_(...)
      return save_io(_7_, ...)
    end
    return _9_
  end
  return uv.read_start(io.stdout, _8_())
end
return {exec = exec}