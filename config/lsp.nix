{ pkgs, ... }:
{
  plugins.lsp.enable = true;
  lsp.servers = {
    lua_ls = {
      enable = true;
    };
    nixd = {
      enable = true;
    };
    rls = {
      enable = true;
    };
    pyright = {
      enable = true;
    };
  };
  extraPackages = [
    pkgs.nixd
    pkgs.nixfmt-rfc-style
  ];
}
