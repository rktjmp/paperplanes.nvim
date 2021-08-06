command! -range=% PP
      \ :lua require("paperplanes")["cmd"](<line1>, <line2>)
