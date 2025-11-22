{ pkgs, ... }:
{
  colorschemes.tokyonight = {
    enable = true; # I quite like this slightly purple colorscheme.
    settings = {
      style = "night";
      styles.functions.italic = false;
    };
  };
  colorschemes.kanagawa.enable = true;
  colorscheme = "tokyonight";
}
