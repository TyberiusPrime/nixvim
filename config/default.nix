{ pkgs, ... }:
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
    #./dial.nix
    #./file-history.nix
    ./files.nix
    ./json.nix
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
    ./convert.nix
    #./regexp_railroad.nix
    ./lsp-endhints.nix
    ./diffconflict.nix
    # ./cursortab.nix # needs a go server compiled, not trivial build
    ./notmuch.nix
  ];
  config = {
    # one liner plugins.:
    plugins.jupytext.enable = true;
    plugins.lastplace.enable = true; # open files at the last edit place.
    plugins.oil.enable = true;
    plugins.vim-suda.enable = true;
    plugins.whitespace.enable = true;
    plugins.marks.enable = true;
    plugins.hmts.enable = true; # nested syntax highlighting for nix/ homemanager.
    plugins.colorizer.enable = true;
    # Use calops/hmts.nvim#38 ("handle nil values") which fixes the Neovim 0.10+
    # crash where directive/predicate captures are arrays of nodes, not a single node.
    plugins.hmts.package = pkgs.vimPlugins.hmts-nvim.overrideAttrs (_: {
      src = pkgs.fetchFromGitHub {
        owner = "auipga";
        repo = "hmts.nvim";
        rev = "c3014b514ccb8f1975828b8f5a009ef93f9b4ced";
        sha256 = "1wvw8dqsibnnshjdf585l35i6d2a4jgp4cxgxkfybz5bn9jnixx5";
      };
    });

  };

  # vim-repeat: offers . for multiple plugins. Am I usingone?
}


# todo:
# https://github.com/tris203/hawtkeys.nvim
