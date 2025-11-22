{
  plugins.treesitter = {
    enable = true;
    settings = {
      highlight.enable = true;
    };
  };
  plugins.rainbow-delimiters.enable = true;
  plugins.treesitter-textobjects = {
    enable = true;
    settings = {
      select = {
        enable = true;
        disable.__empty = { };
        lookahead = true;

        keymaps = {
          "af" = "@function.outer";
          "if" = "@function.inner";
          "ac" = "@class.outer";
          "ic" = "@class.inner";
          "ai" = "@block.outer";
          "ii" = "@block.inner";
          "p" = "@parameter.inner";

          al = "@call.outer";
          il = "@call.inner";
        };
        selection_modes = {
          "@parameter.outer" = "v";
          "@function.outer" = "V";
          "@class.outer" = "<c-v>";
        };

      };
      swap = {
        enable = true;
        swap_next = {
          "g>" = "@parameter.inner";
        };
        swap_previous = {
          "g<" = "@parameter.inner";
        };
      };

      # seems to be a another k?
      # lsp_interop = {
      #       enable = true;
      #       border = "none";
      #       peek_definition_code = {
      #         "<leader>df" = "@function.outer";
      #         "<leader>dF" = "@class.outer";
      #       };
      #     };

    };
  };
}
