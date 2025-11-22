# todo
#         vim.keymap.set('n', '<Leader>t', require('whitespace-nvim').trim)
# SudaWrite
# MarkdownPreview / MarkdownToggle
# oil
# undotree
{

  extraConfigLua = ''
    function mymenu()
      vim.ui.select({ 'tabs', 'spaces' }, {
                  prompt = 'Select tabs or spaces:',
                  format_item = function(item)
                      return "I'd like to choose " .. item
                  end,
              }, function(choice)
                  if choice == 'spaces' then
                      vim.o.expandtab = true
                  else
                      vim.o.expandtab = false
                  end
              end)
    end
    '';
  keymaps = [{
    key = "<leader>m";
    action = ":lua mymenu()<cr>";
    mode = "n";
  }];
}
