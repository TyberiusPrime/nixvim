{

  # Import all your configuration modules here
  imports = [
    ./basics.nix
    ./bufferline.nix
    #./file-history.nix
    ./keybinds.nix
    ./lsp.nix
    ./review.nix
    #./snacks.nix
    ./treesitter.nix
    ./colorscheme.nix
    ./comments.nix
    ./register.nix
    ./snacks.nix
    ./spell.nix
    ./sandwich.nix
    ./replacewithregister.nix
    ./dial.nix
    ./bioinformatics.nix
    ./undo.nix
    ./copilot.nix
    ./typst.nix
    ./menu.nix
    ./myswitch.nix
    ./files.nix

  ];
  config = {
    # one liner plugins.:
    plugins.whitespace.enable = true;
    plugins.vim-suda.enable = true;
    plugins.lastplace.enable = true;#open files at the last edit place.
    plugins.oil.enable = true;
    plugins.jupytext.enable = true;

  };

  # vim-repeat: offers . for multiple plugins. Am I usingone?
}
