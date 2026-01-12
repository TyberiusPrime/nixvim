{ pkgs, ... }:
{
  plugins.blink-cmp-copilot = {
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
        "copilot"
        "path"
        #"luasnip"
        "buffer"
        #"spell"
      ];
      sources = {
        providers = {
          copilot = {
            # couldn't get it to work.
            name = "copilot";
            module = "blink-cmp-copilot";
            async = true;
            score_offset = 100;
          };
        };
      };
    };
  };
}
