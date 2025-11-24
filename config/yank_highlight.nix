{
  autoCmd = [
    {
      event = [ "TextYankPost" ];
      pattern = [ "*" ];
      command = ":lua vim.highlight.on_yank({higroup='Visual', timeout=300})";
    }
  ];

}
