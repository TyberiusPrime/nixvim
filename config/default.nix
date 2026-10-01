{ pkgs, ... }:
{

  # Import all your configuration modules here
  imports = [
    ./abbr.nix
    ./autocomplete
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
    ./mini-files.nix
    ./myswitch.nix
    ./paste-image.nix
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
    # Replaces the matchit that nvim auto-loads (see loaded_matchit in basics.nix).
    # matchit's operator-pending `%` forgets to compensate for selection=exclusive,
    # so `d%`/`y%`/`c%` dropped the closing bracket while `v%d` kept it.
    # match-up gets that right, and does word matching via its own treesitter
    # queries -- it calls vim.treesitter directly, so it does NOT depend on
    # nvim-treesitter's removed module system (cf. the note in treesitter.nix).
    # Deliberately NOT setting `.treesitter` here: that nixvim option emits the old
    # nvim-treesitter module config, which is the dead path. match-up enables
    # treesitter itself (g:matchup_treesitter_enabled, default on for nvim >= 0.11.2).
    plugins.vim-matchup.enable = true;
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
