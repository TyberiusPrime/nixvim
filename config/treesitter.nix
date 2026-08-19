{pkgs, ...}: {
  plugins.treesitter = {
    enable = true;
    settings = {
      highlight.enable = true;
      indent.enable = true;
    };
  };
  plugins.rainbow-delimiters.enable = true;

  # The pinned nvim-treesitter-textobjects is the "main" branch rewrite, which
  # dropped the old declarative `require("nvim-treesitter").setup({textobjects=...})`
  # config path entirely (that's the old nvim-treesitter "modules" system, which
  # the new nvim-treesitter no longer has). nixvim's plugins.treesitter-textobjects
  # module still only knows how to generate that old-style config, so it's silently
  # ignored -- af/if/ac/etc never got mapped. Only `enable` (for plugin install) does
  # anything useful here; keymaps are wired up by hand below via extraConfigLua,
  # per https://github.com/nvim-treesitter/nvim-treesitter-textobjects#text-objects-select
  plugins.treesitter-textobjects.enable = true;

  extraConfigLua = ''
    do
      local textobjects = require("nvim-treesitter-textobjects")
      textobjects.setup({
        select = {
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "<c-v>",
          },
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local function select_textobject(query)
        return function()
          select.select_textobject(query, "textobjects")
        end
      end

      local textobject_keymaps = {
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
        ai = "@block.outer",
        ii = "@block.inner",
        P = "@parameter.inner",
        al = "@call.outer",
        il = "@call.inner",
      }
      for lhs, query in pairs(textobject_keymaps) do
        vim.keymap.set({ "x", "o" }, lhs, select_textobject(query))
      end
    end
  '';

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
      action = ":lua require('sibling-swap').swap_with_right() <cr>";
      key = "g,";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = ":lua require('sibling-swap').swap_with_left() <cr>";
      key = "g.";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = ":lua require('sibling-swap').swap_with_right() <cr>";
      key = "g>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = ":lua require('sibling-swap').swap_with_left() <cr>";
      key = "g<";
      mode = "n";
      options = {
        silent = true;
      };
    }
  ];
}
