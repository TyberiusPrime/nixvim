{pkgs, ...}: {
  plugins.treesitter = {
    enable = true;
    settings = {
      highlight.enable = true;
      indent.enable = true;
    };
  };
  plugins.rainbow-delimiters.enable = true;
  plugins.treesitter-textobjects = {
    enable = true;
    settings = {
      select = {
        enable = true;
        disable.__empty = {};
        lookahead = true;

        keymaps = {
          "af" = "@function.outer";
          "if" = "@function.inner";
          "ac" = "@class.outer";
          "ic" = "@class.inner";
          "ai" = "@block.outer";
          "ii" = "@block.inner";
          "P" = "@parameter.inner";

          al = "@call.outer";
          il = "@call.inner";
        };
        selection_modes = {
          "@parameter.outer" = "v";
          "@function.outer" = "V";
          "@class.outer" = "<c-v>";
        };
      };
      # swap = {
      #   enable = true;
      #   swap_next = {
      #     "g>" = "@parameter.inner";
      #   };
      #   swap_previous = {
      #     "g<" = "@parameter.inner";
      #   };
      # };

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

  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "file-history";
      src = pkgs.fetchFromGitHub {
        owner = "Wansmer";
        repo = "sibling-swap.nvim";
        rev = "75e696c340429769aa34d0bbae1511c8d9660c0b";
        sha256 = "sha256-8AGMJePHYAT+XeHgXQb+RkzyTpWI0bo7u223+YxxkVI=";
      };
      extraConfigLua = ''
        require('sibling-swap').setup({use_default_keymaps = false})
      '';
    })
  ];
  keymaps = [
    {
      action = ":lua require('sibling-swap').swap_with_left() <cr>";
      key = "g,";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = ":lua require('sibling-swap').swap_with_right() <cr>";
      key = "g.";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = ":lua require('sibling-swap').swap_with_left() <cr>";
      key = "g>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = ":lua require('sibling-swap').swap_with_right() <cr>";
      key = "g<";
      mode = "n";
      options = {
        silent = true;
      };
    }
  ];
}
