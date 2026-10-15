{ pkgs, ... }:
let
  # Custom snippets: every other .nix file in this directory is named after its
  # filetype (python.nix -> python) and becomes <filetype>.json (VSCode snippet format).
  # prefix = what you type (keyword chars only, so no leading '.'), body = what gets inserted.
  # body may use $1, ''${1:default}, $0 for tab stops; a literal $ must be written \\$.
  snippets =
    pkgs.lib.mapAttrs'
      (file: _: {
        name = pkgs.lib.removeSuffix ".nix" file;
        value = import (./. + "/${file}");
      })
      (
        pkgs.lib.filterAttrs (
          file: type: type == "regular" && file != "default.nix" && pkgs.lib.hasSuffix ".nix" file
        ) (builtins.readDir ./.)
      );
  snippetsDir = pkgs.linkFarm "my-snippets" (
    pkgs.lib.mapAttrsToList (ft: s: {
      name = "${ft}.json";
      path = pkgs.writeText "${ft}.json" (builtins.toJSON s);
    }) snippets
  );
in
{
  # <leader>b: pick from the snippets for the current filetype and expand it.
  # Goes through blink's own snippet registry (same opts), so the menu lists
  # exactly what blink completes: our snippets, friendly-snippets and the
  # global 'all' set.
  extraConfigLua = ''
    function snippet_menu()
      local ft = vim.bo.filetype
      local opts = require("blink.cmp.config").sources.providers.snippets.opts or {}
      snippet_registry = snippet_registry or require("blink.cmp.sources.snippets.default.registry").new(opts)

      local items = {}
      local function add(snips, tag)
        for _, snip in ipairs(snips) do
          local body = type(snip.body) == "table" and table.concat(snip.body, "\n") or snip.body
          -- skip what vim.snippet can't expand (some friendly-snippets nest tabstops in placeholders)
          if pcall(vim.lsp._snippet_grammar.parse, body) then
            table.insert(items, {
              text = tag .. snip.prefix .. "  " .. (snip.description or ""),
              body = body,
              preview = { text = body, ft = ft },
            })
          end
        end
      end
      add(snippet_registry:get_snippets_for_ft(ft), "")
      add(snippet_registry:get_extended_snippets(ft), "")
      if #items == 0 then
        vim.notify("No snippets for filetype '" .. ft .. "'", vim.log.levels.INFO)
        return
      end
      add(snippet_registry:get_global_snippets(), "~")
      table.sort(items, function(a, b) return a.text < b.text end)

      Snacks.picker({
        title = "Snippets (" .. ft .. ")",
        items = items,
        format = "text",
        preview = "preview",
        -- on equal match score keep our alphabetical order; snacks' default
        -- prefers the shortest line, i.e. whichever has the shortest description
        sort = { fields = { "score:desc", "idx" } },
        confirm = function(picker, item)
          picker:close()
          if not item then return end
          -- append after the cursor like `a`, then expand once insert mode is live
          vim.api.nvim_create_autocmd("InsertEnter", {
            once = true,
            callback = function()
              vim.schedule(function()
                -- resolve $TM_FILENAME, $CURRENT_YEAR, ... like blink does
                vim.snippet.expand(snippet_registry:expand_vars(item.body, vim.uv.now()))
              end)
            end,
          })
          vim.api.nvim_feedkeys("a", "n", false)
        end,
      })
    end
  '';
  keymaps = [
    {
      key = "<leader>b";
      action = ":lua snippet_menu()<cr>";
      mode = "n";
      options = {
        silent = true;
        desc = "snippets for this filetype";
      };
    }
  ];

  plugins.friendly-snippets.enable = true; # blink picks it up from the runtimepath

  plugins.blink-cmp-copilot = {
    enable = true;
  };
  plugins.blink-cmp = {
    enable = true;
    settings = {
      keymap = {
        preset = "super-tab";
      };
      sources.default = [
        "lsp"
        #"minuet"
        "copilot"
        "path"
        "snippets"
        #"luasnip"
        "buffer"
        #"spell"
      ];
      fuzzy = {
        # exact label match first (typing "subpar" puts the snippet with prefix
        # "subpar" above "subparimport", even if frecency boosted the latter),
        # then alphabetical on ties instead of whatever order the source returned.
        sorts = [
          "exact"
          "score"
          "sort_text"
          "label"
        ];
      };
      completion = {
        trigger = {
          prefetch_on_insert = false;
        };
      };
      sources = {
        providers = {
          snippets.opts = {
            search_paths = [ "${snippetsDir}" ];
            use_label_description = true;
          };
          copilot = {
            # couldn't get it to work.
            name = "copilot";
            module = "blink-cmp-copilot";
            async = true;
            score_offset = 100;
          };
          # minuet = {
          #   name = "minuet";
          #   module = "minuet.blink";
          #   async = true;
          #   #-- Should match minuet.config.request_timeout * 1000,
          #   #-- since minuet.config.request_timeout is in seconds
          #   timeout_ms = 3000;
          #   score_offset = 50; # -- Gives minuet higher priority among suggestions
          # };
        };
      };
    };
  };
  # plugins.minuet = {
  #   # non github completion
  #   enable = true;
  #   settings = {
  #     config = {
  #       request_timeout = 3;
  #       notify = false;
  #     };
  #     provider = "openai_fim_compatible";
  #     provider_options = {
  #       openai_fim_compatible = {
  #         api_key = "TERM";
  #         end_point = "http://localhost:8012/v1/completions";
  #         model = "ggml-org/Qwen2.5-Coder-7B-Q8_0-GGUF";
  #         name = "qwen2.5 coder 7b";
  #         optional = {
  #           max_tokens = 256;
  #           top_p = 0.9;
  #         };
  #         stream = true;
  #       };
  #     };
  #   };
  # };
}
