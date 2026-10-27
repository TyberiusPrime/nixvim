{ pkgs, ... }:
{

  # Imports every .nix file in this folder and every subfolder with a default.nix.
  # Unused modules live in ./disabled_config.
  # builtins only - using pkgs/lib here would cause infinite recursion.
  imports =
    let
      entries = builtins.readDir ./.;
      isModule =
        name:
        (
          entries.${name} == "regular"
          && name != "default.nix"
          && builtins.match ".*\\.nix" name != null
        )
        || (entries.${name} == "directory" && builtins.pathExists (./. + "/${name}/default.nix"));
    in
    map (name: ./. + "/${name}") (builtins.filter isModule (builtins.attrNames entries));
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
