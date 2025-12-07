{ pkgs, ... }:
{
  # extraPlugins = [
  #   (pkgs.vimUtils.buildVimPlugin {
  #     name = "black";
  #     src = pkgs.fetchFromGitHub {
  #       owner = "averms";
  #       repo = "black-nvim";
  #       rev = "8fb3efc562b67269e6f31f8653297f826534fa4b";
  #       sha256 = "sha256-pbbbkRD4ZFxTupmdNe1UYpI7tN6//GXUMll/jeCSUAg=";
  #     };
  #   })
  # ];
  extraConfigLua = ''
    -- unmap gra in visual/x mode
    vim.api.nvim_exec([[
      xunmap gra
    ]], false)

    vim.lsp.enable('rust_analyzer', vim.fn.executable("cargo") ~= 0) -- only rust when cargo present

    vim.lsp.inlay_hint.enable(false)
  '';
  # autoCmd = [
  #   {
  #     event = "FileType";
  #     pattern = "python";
  #     command = "noremap <buffer> <F12> :call Black()<cr>";
  #   }
  # ];

  plugins.lsp.enable = true;
  lsp.servers = {
    lua_ls = {
      enable = true;
    };
    nixd = {
      enable = true;
    };
    rust_analyzer = {
      enable = true;
      config= {
      };
    };
    pyright = {
      enable = true;
    };
    ruff.enable = true;
  };
  extraPackages = [
    pkgs.nixd
    pkgs.nixfmt-rfc-style
  ];
  diagnostic.settings.virtual_text = false;

  keymaps = [
    {
      # autoformat
      action = ":lua vim.lsp.buf.format() <cr>";
      key = "<F12>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      # goto definition...
      action = ":lua vim.lsp.buf.definition()<cr>";
      key = "gd";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      # goto definition...
      action = ":lua vim.lsp.buf.code_action()<cr>";
      key = "gha";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      # goto definition...
      action = ":lua vim.lsp.buf.rename()<cr>";
      key = "ghn";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      # goto definition...
      action = ":lua vim.lsp.buf.references()<cr>";
      key = "ghr";
      mode = "n";
      options = {
        silent = true;
      };
    }
    # {
    #   # autoformat
    #   action = ":lua vim.diagnostic.open_float() <cr>";
    #   key = "<C-W>";
    #   mode = "n";
    #   options = {
    #     silent = true;
    #   };
    # }
  ];

}
