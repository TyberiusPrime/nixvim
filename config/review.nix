{ ... }:
{

  # indent line. with animations.
  # not sure I want to keep it.
  plugins.mini-indentscope = {
    #enable = true;
  };
  # I think I like this one better
  plugins.indent-blankline = {
    enable = true;
    settings = {
      exclude = {
        buftypes = [
          "terminal"
          "quickfix"
        ];
        filetypes = [
          ""
          "checkhealth"
          "help"
          "lspinfo"
          "packer"
          "TelescopePrompt"
          "TelescopeResults"
          "yaml"
        ];
      };
      scope = {
        show_end = false;
        show_exact_scope = false;
        show_start = false;
      };
    };

  };
  plugins.which-key.enable = true;
  plugins.eyeliner.enable = true; # highlight f targets...
  # plugins.markdown-preview={ # won't open browser, why?
  #   enable =true;
  #   settings = {
  #   browser = "firefox";
  # };
  # };

  #todo:
  # femaco
  # markdown-preview
   # vim table mode
   # dial/speed dating
    # spelunker?


  # nvim-hlslens what's that good for in modern neovim?:
  # nvim-peekup - good Idea but I very rarely used it
  # auto-sessions. - was this useful?
  # symbols-outline-nvim - plugin has been archieved
  # vim sandwich - I think we w
  # easy-align - it is useful, but I used it so seldom.
  # vim-test - I prefer bacon maybe? Though this also supports rust. Give it another go? oh no, it searches for rustup instead of just running cargo... plugins.vim-test.enable = true;
  # neoterm - never used it?
  # dial - is this good - right now it seem to destroy visual mode 'count up'. maybe speeddating instead
  # plugins.vim-speeddating.enable = true; -> no such plugin?
  # vim-fetch - open with line number...jj
  # vim-yoink

  # what do we do about auto-completion. nvim-cmp like before? blink? builtin?:e

  # outdated / replaced

  # kommentary -> treesitter
  # neoformat -> lsp
  # sideways-vim -> treesitter
  # vim-markdown-composer -> markdown-preview
  # vim-toml -> treesitter.
  # nvim-osc52 -> :h clipboard-osc52
  #beloglazov/vim-textobj-quotes -> treesitter

}
