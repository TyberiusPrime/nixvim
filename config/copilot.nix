{
  nixpkgs.config.allowUnfree = true;
  plugins.lsp.servers.copilot.enable = false;
  plugins.copilot-vim = {
    enable = false;
    settings = {
      filetypes = {
        "mail" = false;
        "beancount" = false;
      };
    };
  };
  plugins.copilot-lua = {
    enable = true;
    settings = {
      filetypes = {
        "beancount" = false;
      };

      panel = {
        auto_refresh = false;
        enabled = false;
      };
      suggestion = {
        auto_trigger = true;
        debounce = 90;
        enabled = false;
        hide_during_completion = false;
        keymap = {
          accept = "<c-u>";
        };
      };

    };
  };
  autoCmd = [
    {
      event = [
        "BufNewFile"
        "BufRead"
      ];
      pattern = [ "*.mail" ];
      command = "set filetype=mail";
    }
  ];

  plugins.copilot-chat.enable = false;
}
