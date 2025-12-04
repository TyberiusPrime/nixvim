{ pkgs, ... }:
{

  #plugins.undotree.enable = true; replaced with atone

  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "atone";
      src = pkgs.fetchFromGitHub {
        owner = "XXiaoA";
        repo = "atone.nvim";
        rev = "d1c1f08bfe23ac56536d0091c8a398938ee9db4e";
        sha256 = "sha256-1/scPTclNcXOKCVjAuve/wV88zIKIWeb5ul3Jb/9+xg=";
      };
    })
  ];
  extraConfigLua = ''
    require("atone").setup({})
    '';

}
