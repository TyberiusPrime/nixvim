{pkgs,...}:
{
  opts = {
    spelllang = "en_us,de_de";
  };
#   extraConfigLua = ''
#     vim.api.nvim_exec(
# 	[=[
# let g:enable_spelunker_vim = 1
# let g:spelunker_check_type = 2
# let g:spelunker_disable_uri_checking = 1
# let g:spelunker_disable_account_name_checking = 1
# " Create own custom autogroup to enable spelunker.vim for specific filetypes.
# let g:spelunker_disable_auto_group = 1
# augroup spelunker
#   autocmd!
#   " Setting for g:spelunker_check_type = 1:
#   autocmd BufWinEnter,BufWritePost *.vim,*.js,*.jsx,*.json,*.md call spelunker#check()

#   " Setting for g:spelunker_check_type = 2:
#   autocmd CursorHold *.vim,*.js,*.jsx,*.json,*.md call spelunker#check_displayed_words()
# augroup END
# nmap zh ZL
# nmap zf ZF

# syn match UrlNoSpell "\\w\\+:\\/\\/[^[:space:]]\\+" contains=@NoSpell


# ]=],
# 	false
# )

    # '';
  autoCmd = [
    {
      event = "FileType";
      pattern = "markdown";
      command = "set conceallevel=0";
    }

    {
      event = "filetype";
      pattern = [ "markdown" ];
      command = "set spell";
    }
  ];

#   extraPlugins = [(pkgs.vimUtils.buildVimPlugin {
#     name = "spellunker";
#     src = pkgs.fetchFromGitHub {
#         owner = "kamykn";
#         repo = "spelunker.vim";
#         rev = "a0bc530f62798bbe053905555a4aa9ed713485eb";
#         sha256 = "sha256-/1MN2KU5+rJhjt7FALvvwmTKRk3n29tU/XQdt1Q5OTE=";
#     };
# })];
}
