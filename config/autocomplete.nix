{ pkgs, ... }:
let
  # Custom snippets, one attrset per filetype -> <filetype>.json (VSCode snippet format).
  # prefix = what you type (keyword chars only, so no leading '.'), body = what gets inserted.
  # body may use $1, ''${1:default}, $0 for tab stops.
  snippets = {
    python = {
      mkdir = {
        prefix = "mkdir";
        body = "mkdir(exist_ok=True, parents=True)";
        description = "mkdir(exist_ok=True, parents=True)";
      };
    };
  };
  snippetsDir = pkgs.linkFarm "my-snippets" (
    pkgs.lib.mapAttrsToList (ft: s: {
      name = "${ft}.json";
      path = pkgs.writeText "${ft}.json" (builtins.toJSON s);
    }) snippets
  );
in
{
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
