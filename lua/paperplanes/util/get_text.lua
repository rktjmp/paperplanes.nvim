local function get_range(buf, start, stop)
  assert(buf, "get-range missing buf arg")
  assert(start, "get-range missing start arg")
  assert(stop, "get-range missing stop arg")
  local function _1_()
    local _0_ = start
    if ((type(_0_) == "table") and (nil ~= (_0_)[1]) and (nil ~= (_0_)[2])) then
      local row = (_0_)[1]
      local col = (_0_)[2]
      return {row, math.min(10000, (col + 1))}
    elseif (nil ~= _0_) then
      local line = _0_
      return {line, 1}
    end
  end
  local _local_0_ = _1_()
  local start_line = _local_0_[1]
  local start_col = _local_0_[2]
  local function _3_()
    local _2_ = stop
    if ((type(_2_) == "table") and (nil ~= (_2_)[1]) and (nil ~= (_2_)[2])) then
      local row = (_2_)[1]
      local col = (_2_)[2]
      return {row, math.min(10000, (col + 1))}
    elseif (nil ~= _2_) then
      local line = _2_
      return {line, -1}
    end
  end
  local _local_1_ = _3_()
  local stop_line = _local_1_[1]
  local stop_col = _local_1_[2]
  local lines = vim.api.nvim_buf_get_lines(buf, (start_line - 1), (stop_line + 0), false)
  if (#lines > 0) then
    local _4_ = (start_line == stop_line)
    if (_4_ == true) then
      lines[1] = string.sub(lines[1], start_col, stop_col)
    elseif (_4_ == false) then
      local last = #lines
      lines[1] = string.sub(lines[1], start_col, -1)
      lines[last] = string.sub(lines[last], 1, stop_col)
    end
  end
  return table.concat(lines, "\n")
end
local function get_selection()
  local start = vim.api.nvim_buf_get_mark(0, "<")
  local stop = vim.api.nvim_buf_get_mark(0, ">")
  return get_range(0, start, stop)
end
local function get_buf(buf)
  return get_range(buf, 1, -1)
end
return {["get-buf"] = get_buf, ["get-range"] = get_range, ["get-selection"] = get_selection}