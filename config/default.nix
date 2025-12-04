{

  # Import all your configuration modules here
  imports = [
    ./abbr.nix
    ./autocomplete.nix
    ./basics.nix
    ./bioinformatics.nix
    ./bufferline.nix
    ./colorscheme.nix
    ./comments.nix
    ./copilot.nix
    ./dial.nix
    #./file-history.nix
    ./files.nix
    ./keybinds.nix
    ./lsp.nix
    ./menu.nix
    ./myswitch.nix
    ./project.nix
    ./python.nix
    ./register.nix
    ./replacewithregister.nix
    ./review.nix
    ./sandwich.nix
    #./snacks.nix
    ./snacks.nix
    ./spell.nix
    ./treesitter.nix
    ./typst.nix
    ./undo.nix
    ./yank_highlight.nix
    ./bacon.nix

  ];
  config = {
    # one liner plugins.:
    plugins.jupytext.enable = true;
    plugins.lastplace.enable = true; # open files at the last edit place.
    plugins.oil.enable = true;
    plugins.vim-suda.enable = true;
    plugins.whitespace.enable = true;

  };

  # vim-repeat: offers . for multiple plugins. Am I usingone?
}


# todo:
# https://github.com/tris203/hawtkeys.nvim
