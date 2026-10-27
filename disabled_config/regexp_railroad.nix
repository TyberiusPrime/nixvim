{ pkgs, ... }:
# dosen't quite work, would need hologram.nvim?
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "nvim_regexplainer";
      src = pkgs.fetchFromGitHub {
        owner = "bennypowers";
        repo = "nvim-regexplainer";
        rev = "b7ab2e383ec8859bb8364872d517bfef8872b12c";
        sha256 = "sha256-w0GkPenOuYhpsTRgyRjG56WlZVzyeGOX+xG7GjCPBO8=";
      };
      dependencies = [ pkgs.vimPlugins.nui-nvim ];
      extraConfigLua = '''';
    })
  ];
}
