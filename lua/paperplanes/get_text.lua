local function get_range(buf, start, stop)
  assert(buf, "get-range missing buf arg")
  assert(start, "get-range missing start arg")
  assert(stop, "get-range missing stop arg")
  local function _2_()
    if ((_G.type(start) == "table") and (nil ~= start[1]) and (nil ~= start[2])) then
      local row = start[1]
      local col = start[2]
      return {row, math.min(10000, (col + 1))}
    elseif (nil ~= start) then
      local line = start
      return {line, 1}
    else
      return nil
    end
  end
  local _local_1_ = _2_()
  local start_line = _local_1_[1]
  local start_col = _local_1_[2]
  local function _4_()
    if ((_G.type(stop) == "table") and (nil ~= stop[1]) and (nil ~= stop[2])) then
      local row = stop[1]
      local col = stop[2]
      return {row, math.min(10000, (col + 1))}
    elseif (nil ~= stop) then
      local line = stop
      return {line, -1}
    else
      return nil
    end
  end
  local _local_3_ = _4_()
  local stop_line = _local_3_[1]
  local stop_col = _local_3_[2]
  local lines = vim.api.nvim_buf_get_lines(buf, (start_line - 1), (stop_line + 0), false)
  if (#lines > 0) then
    local _5_ = (start_line == stop_line)
    if (_5_ == true) then
      lines[1] = string.sub(lines[1], start_col, stop_col)
    elseif (_5_ == false) then
      local last = #lines
      lines[1] = string.sub(lines[1], start_col, -1)
      do end (lines)[last] = string.sub(lines[last], 1, stop_col)
    else
    end
  else
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
return {["get-range"] = get_range, ["get-selection"] = get_selection, ["get-buf"] = get_buf}