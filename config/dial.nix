{

#   nnoremap  <C-a> <Plug>(dial-increment)
# nnoremap  <C-x> <Plug>(dial-decrement)
# nnoremap g<C-a> <Plug>(dial-g-increment)
# nnoremap g<C-x> <Plug>(dial-g-decrement)
# xnoremap  <C-a> <Plug>(dial-increment)
# xnoremap  <C-x> <Plug>(dial-decrement)
# xnoremap g<C-a> <Plug>(dial-g-increment)
# xnoremap g<C-x> <Plug>(dial-g-decrement)

  keymaps = [



{
      action = '':lua require("dial.map").manipulate("increment", "normal")<cr>'';
      key = "<c-a>";
      mode = "n";
    }
    {
      action = '':lua require("dial.map").manipulate("decrement", "normal")<cr>'';
      key = "<C-x>";
      mode = "n";
    }
    {
      action = '':lua require("dial.map").manipulate("increment", "gnormal")<cr>'';
      key = "g<c-a>";
      mode = "n";
    }
    {
      action = '':lua require("dial.map").manipulate("decrement", "gnormal")<cr>'';
      key = "g<C-x>";
      mode = "n";
    }

    {
      action = '':lua require("dial.map").manipulate("increment", "visual")<cr>'';
      key = "<c-a>";
      mode = "x";
    }
    {
      action = '':lua require("dial.map").manipulate("decrement", "visual")<cr>'';
      key = "<C-x>";
      mode = "x";
    }
    {
      action = '':lua require("dial.map").manipulate("increment", "gvisual")<cr>'';
      key = "g<C-a>";
      mode = "x";
    }
    {
      action = '':lua require("dial.map").manipulate("decrement", "gvisual")<cr>'';
      key = "g<C-x>";
      mode = "x";
    }
  ];
  plugins.dial.enable = false; # improved  ctrl-a 456
}
