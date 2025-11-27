{ pkgs, ... }:
{
  plugins.blink-copilot = {
    enable = true;
  };
  plugins.blink-cmp = {
    enable = true;
    settings = {
      keymap = {
        preset = "super-tab";
      };
      sources.default = [
        "lsp"
        #"copilot"
        "path"
        #"luasnip"
        "buffer"
        #"spell"
      ];
      #sources = {
        # copilot = { # couldn't get it to work.
        #   name = "copilot";
        #   module = "blink-copilot";
        #   async = true;
        #   score_offset = 100;
        # };

        #};
    };
  };
}
