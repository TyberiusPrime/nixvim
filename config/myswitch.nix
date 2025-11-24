{
  extraConfigLua =''
    vim.api.nvim_exec(
    [[
    " Ctrl-^ is very handy command in normal mode. Ctrl-^
    " switches to "alternate file". When there is no "alternate file",
    " I wanted Ctrl-^ to jump to next file in the list.
    " Insert following commands into your vimrc, then
    " Ctrl-^ will be enhanced so that when there is no alternate file
    " but there is next file, it will jump to the next file.
    " My remapping of <C-^>. If there is no alternate file, then switch to next file.
    function! MySwitch()
      if expand('#')=="" | silent! next
      else
        exe "normal! \<c-^>"
      endif
    endfu
    ]],
    	false
    )
  '';
  keymaps = [{
    key = "<Del>";
    action = ":call MySwitch()<cr>";
    mode = "n";
  }];
}
