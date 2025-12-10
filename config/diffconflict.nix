{ pkgs, ... }:

{

  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "jj-diffconflicts";
      src = pkgs.fetchFromGitHub {
        owner = "rafikdraoui";
        repo = "jj-diffconflicts";
        rev = "bee239e847cf336fc10925a35c65052f41aa89e3";
        sha256 = "sha256-FXsLSYy+eli8VArUL8ZOiPtyOk4Q8TUYwobEefZPRII=";
      };
      # dependencies = [ pkgs.vimPlugins.nui-nvim ];
      # extraConfigLua = ''
      #
      # '';
    })
  ];
}
