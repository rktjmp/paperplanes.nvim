 local function get_range(buf, start, stop)
 assert(buf, "get-range missing buf arg")
 assert(start, "get-range missing start arg")
 assert(stop, "get-range missing stop arg")








 local function _3_() local _2_ = start if ((_G.type(_2_) == "table") and (nil ~= (_2_)[1]) and (nil ~= (_2_)[2])) then local row = (_2_)[1] local col = (_2_)[2]
 return {row, math.min(10000, (col + 1))} elseif (nil ~= _2_) then local line = _2_
 return {line, 1} else return nil end end local _local_1_ = _3_() local start_line = _local_1_[1] local start_col = _local_1_[2]
 local function _7_() local _6_ = stop if ((_G.type(_6_) == "table") and (nil ~= (_6_)[1]) and (nil ~= (_6_)[2])) then local row = (_6_)[1] local col = (_6_)[2]
 return {row, math.min(10000, (col + 1))} elseif (nil ~= _6_) then local line = _6_
 return {line, -1} else return nil end end local _local_5_ = _7_() local stop_line = _local_5_[1] local stop_col = _local_5_[2]






 local lines = vim.api.nvim_buf_get_lines(buf, (start_line - 1), (stop_line + 0), false)




 if (#lines > 0) then

 local _9_ = (start_line == stop_line) if (_9_ == true) then


 lines[1] = string.sub(lines[1], start_col, stop_col) elseif (_9_ == false) then

 local last = #lines
 lines[1] = string.sub(lines[1], start_col, -1)
 do end (lines)[last] = string.sub(lines[last], 1, stop_col) else end else end
 return table.concat(lines, "\n") end

 local function get_selection()
 local start = vim.api.nvim_buf_get_mark(0, "<")
 local stop = vim.api.nvim_buf_get_mark(0, ">")

 return get_range(0, start, stop) end

 local function get_buf(buf)
 return get_range(buf, 1, -1) end

 return {["get-range"] = get_range, ["get-selection"] = get_selection, ["get-buf"] = get_buf}