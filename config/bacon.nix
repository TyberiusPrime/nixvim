{

  plugins.bacon = {
    enable = true;
    settings = {
      quickfix = {
        enabled = true;
        event_trigger = true; # - Trigger QuickFixCmdPost after populating Quickfix list
      };
    };
  };
  keymaps = [
    {
      key = "!";
      action = ":BaconLoad<CR>:w<CR>:BaconNext<CR>";
      mode = "n";
      options = {
        desc = "Bacon: Load, Save, Next";
      };
    }
    {
      key = ",";
      action = ":BaconList<CR>";
      mode = "n";
      options = {
        desc = "Bacon: List";
      };
    }
  ];
}
