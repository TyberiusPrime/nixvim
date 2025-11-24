{ ... }:
{
  plugins.snacks = {
    enable = true;
    settings = {
      picker.enable = true;
    };
  };
  keymaps = [
    {
      action = ":lua Snacks.picker.registers()<cr>";
      key = "<leader>r";
      mode = "n";
      options = {
        silent = true;
        desc = "Register picker";
      };
    }
  ];
}
