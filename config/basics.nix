{ ... }:
{
  globals = {
    mapleader = " ";
    termguicolors = true;

  };

    wrapRc = true; # config only from here
    impureRtp = false; # remove runtime dirs
  globalOpts = {
    # Line numbers
    number = true;
    relativenumber = false;
    hlsearch = true;
    mouse = "nv";
    showmode = true;
    #loaded_netrw = 1;
    #loaded_netrwPlugin = 1;
    completeopt = [
      "menuone"
      "noselect"
      "noinsert"
    ];
    # Always show the signcolumn, otherwise text would be shifted when displaying error icons
    signcolumn = "yes:3";
    spelllang = "en_us,de_de";

    ignorecase = true;
    smartcase = true;
    splitkeep = "screen"; # sensible splitting behaviour

  };

  extraConfigLua = ''

    -- Display settings

    -- Scrolling and UI settings
    vim.opt.cursorline = true
    vim.opt.cursorcolumn = true
    vim.opt.signcolumn = 'yes'
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 8
    vim.opt.scrolloff = 8

    -- Title
    vim.opt.title = true
    vim.opt.titlestring = "nixnvim %f"

    -- Persist undo (persists your undo history between sessions)
    -- vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
    vim.opt.undofile = true

    -- backup to $XDG_DATA_HOME/nvim/backup
    -- vim.opt.backupdir = vim.fn.stdpath("data") .. "/backup//"

    -- Tab stuff
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
    vim.opt.autoindent = true

    -- Search configuration
    -- vim.opt.gdefault = true -I'm used to  the old g behaviour.

    -- open new split panes to right and below (as you probably expect)
    vim.opt.splitright = true
    vim.opt.splitbelow = true

    -- LSP
    vim.lsp.inlay_hint.enable(true)
  '';
}
