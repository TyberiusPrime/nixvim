{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "cursortab-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "leonardcser";
        repo = "cursortab.nvim";
        rev = "f2f2a7d1cf502ea4c435cc56fe36e88f62ae00d0";
        sha256 = "sha256-12dwKuCqyjF+0L5mLQyjYVD9VbJaf+1RniTFZR4z1vs=";
      };
      dependencies = [ pkgs.vimPlugins.nui-nvim ];
    })
  ];
  extraConfigLua = ''
      require("cursortab").setup({
      -- CUSTOMIZATION
      deletion_color = "#4f2f2f",        -- Background color for deletions
      addition_color = "#394f2f",        -- Background color for additions
      modification_color = "#282e38",    -- Background color for modifications
      completion_color = "#80899c",      -- Foreground color for completions
      jump_symbol = "",                 -- Symbol shown for jump points
      jump_text = " TAB ",               -- Text displayed after jump symbol
      jump_show_distance = true,         -- Show line distance for off-screen jumps
      jump_bg_color = "#373b45",         -- Jump text background color
      jump_fg_color = "#bac1d1",         -- Jump text foreground color

      -- OPTIONS
      enabled = true,                    -- Whether the plugin is enabled on startup
      provider = "sweep",         -- Provider: "autocomplete", "sweep", or "zeta"
      idle_completion_delay = 50,        -- Delay in ms after being idle to trigger completion (-1 to disable)
      text_changed_debounce = 50,        -- Debounce in ms after text changed to trigger completion

      -- CONTEXT OPTIONS
      max_context_tokens = 1024,         -- Max tokens to send as context (0 = no limit)

      -- PROVIDER OPTIONS (applied to all providers: autocomplete, sweep, zeta)
      provider_url = "http://ff-m5.wg:8080",  -- URL of the provider server
      provider_model = "sweepai_sweep-next-edit-1.5B_sweep-next-edit-1.5b.q8_0.v2",
      provider_temperature = 0.0,              -- Sampling temperature
      provider_max_tokens = 100,                -- Max tokens to generate
      provider_top_k = 50,                     -- Top-k sampling
    })

  '';
}
