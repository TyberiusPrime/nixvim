{
  plugins.tiny-glimmer.enable = true;
  plugins.tiny-glimmer.settings = {

    animations = {
      pulse = {
        chars_for_max_duration = 10;
        max_duration = 400;
        min_duration = 200;
      };
      rainbow = {
        chars_for_max_duration = 10;
      };
    };
    overwrite = {
      paste = {
        enabled = true;
        default_animation = "reverse_fade";
          paste_mapping = "p";     #- Paste after cursor
          Paste_mapping = "P";     #- Paste before cursor
      };
      search = {
        enabled = true;
         default_animation = "pulse";
            next_mapping = "n";      #- Key for next match
            prev_mapping = "N";      #- Key for previous match
      };
      yank = {
        default_animation = "rainbow";
      };
      undo = {
        enabled = true;
        default_animation = {
          name = "fade";
          settings = {
            from_color = "DiffDelete";
            max_duration = 500;
            min_duration = 500;
          };
        };
        undo_mapping = "u";
      };

      redo = {
        enabled = true;
        default_animation = {
          name = "fade";
          settings = {
            from_color = "DiffAdd";
            max_duration = 500;
            min_duration = 500;
          };
        };
        redo_mapping = "<c-r>";
      };
    };
    refresh_interval_ms = 5;

  };
  # autoCmd = [
  #   {
  #     event = [ "TextYankPost" ];
  #     pattern = [ "*" ];
  #     command = ":lua vim.highlight.on_yank({higroup='Visual', timeout=300})";
  #   }
  # ];

}
