{ pkgs, ... }:
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
        "minuet"
        "path"
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
          # copilot = {
          #   # couldn't get it to work.
          #   name = "copilot";
          #   module = "blink-cmp-copilot";
          #   async = true;
          #   score_offset = 100;
          # };
          minuet = {
            name = "minuet";
            module = "minuet.blink";
            async = true;
            #-- Should match minuet.config.request_timeout * 1000,
            #-- since minuet.config.request_timeout is in seconds
            timeout_ms = 3000;
            score_offset = 50; # -- Gives minuet higher priority among suggestions
          };
        };
      };
    };
  };
  plugins.minuet = {
    # non github completion
    enable = true;
    settings = {
      config = {
        request_timeout = 3;
      };
      provider = "openai_fim_compatible";
      provider_options = {
         openai_fim_compatible= {
          api_key = "TERM";
          end_point = "http://localhost:8012/v1/completions";
          model = "ggml-org/Qwen2.5-Coder-3B-Q8_0-GGUF";
          name = "qwen2.5 coder 3b";
          optional = {
            max_tokens = 256;
            top_p = 0.9;
          };
          stream = true;
        };
      };
    };
  };
}
