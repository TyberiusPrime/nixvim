{ ... }:
{
  plugins.snacks = {
    enable = true;
    settings = {
      picker.enable = true;
      picker.settings = {
        ui_select = true;
      };
      bigfile.enable = true;
      indent = {
        enable = true;
        animate.enabled = false;
      };
    };
  };

}
