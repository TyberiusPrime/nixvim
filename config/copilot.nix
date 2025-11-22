{
  nixpkgs.config.allowUnfree = true;
  plugins.lsp.servers.copilot.enable= true;
  plugins.copilot-vim={
    enable = true;
    settings = {
      filetypes = {
        "mail"= false;
      };
    };
  };

  autoCmd = [
    {
    event = ["BufNewFile" "BufRead"];
    pattern = ["*.mail"];
    command = "set filetype=mail";
  }
  ];

  plugins.copilot-chat.enable = true;
}
