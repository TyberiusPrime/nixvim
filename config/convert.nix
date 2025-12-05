{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "convy.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "necrom4";
        repo = "convy.nvim";
        rev = "2d51ba9d25459f8fa0e663fe8cca5d1afc13f3a6";
        sha256 = "sha256-c4M7jYr+J2QO2hKLPVIRdfTka6XocoWF6sCsn9JzxvI=";
      };
    })
  ];

}
