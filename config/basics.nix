{ ... }:
{
  globals = {
    mapleader = " ";
    termguicolors = true;

    # Nvim auto-loads matchit ($VIMRUNTIME/plugin/matchit.vim does `packadd matchit`
    # unless this global is already set). Its `%` is a <Plug> mapping, not the builtin
    # motion, and its operator-pending path forgets to compensate for
    # selection=exclusive (it guards the fixup on `a:mode == 'v'` only). Result:
    # `d%`/`y%`/`c%` drop the closing bracket while `v%d` keeps it. Turning it off
    # restores a correct `%`. vim-matchup (see default.nix) now provides `%`
    # instead, and sets this global itself; keeping it explicit is a harmless
    # ordering guard so matchit stays out of the way even if match-up is disabled.
    loaded_matchit = 1;
  };

  wrapRc = true; # config only from here
  impureRtp = false; # remove runtime dirs
  opts = {
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

    # fix '10G / mouse wheel -= giant scroll
    scrolljump = 1;
    scrolloff = 0;

    # ignore my ex: lines in rust...
    modeline = false;
    wildignore = [
      "**/__pycache__/**"
      "*.pyc"
      "**/.git/**"
      "**/node_modules/**"
      "**/.DS_Store"
      "*.egg-info" # glob()/expand()
      "*.egg-info/" # :e completion (dirs only match with trailing /)
    ];

  };

  extraConfigLua = ''

    vim.opt.selection ="exclusive" -- make w do the same in visual and non-visual mode

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
    vim.opt.titlestring = "nvim : %f : %{getcwd()}"
    vim.opt.titlelen = 0 -- never truncate; let the window manager shorten it

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

  '';
}
