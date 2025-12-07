{
  pkgs,
  ...
}:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "nvim-lsp-endhints";
      src = pkgs.fetchFromGitHub {
        owner = "chrisgrieser";
        repo = "nvim-lsp-endhints";
        rev = "3a42a05f46d86d767ad3e048de9032307575a7fa";
        sha256 = "sha256-+OhFPOhhkr142ZaLLX26/4qUC5ftaDMGLAutq8kDGIA=";
      };
      dependencies = [ pkgs.vimPlugins.nui-nvim ];
      extraConfigLua = ''
        require("lsp-endhints").setup() -- required, even if empty
        require("lsp-endhints").enable()

      '';
    })
  ];

}
