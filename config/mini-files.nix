{ ... }:
{
  # mini.files as a *path inserter* (not as a file opener -- oil keeps that job,
  # hence use_as_default_explorer = false below).
  #
  # Why not a picker: both <leader>f pickers in files.nix shell out to
  # ff_filelister, which walks the whole tree up front and filters by a type
  # whitelist built for *editing* source files. For inserting a path you want the
  # files that whitelist throws away (.png, .csv, .pdf) plus directories, and over
  # sshfs the up-front walk is unusable. mini.files scans exactly one directory
  # per level you descend into, so the cost is one round trip per keypress.
  #
  # Why not i_CTRL-X_CTRL-F: it parses the text before the cursor with 'isfname',
  # which contains no space, so a path with a space can never be continued; it is
  # always rooted at the cwd; and it inserts by feeding keys. Here the seed region
  # is captured once (spaces and all) and overwritten with nvim_buf_set_text, so
  # nothing is re-parsed and nothing runs through the ttt/ddd abbreviations.
  #
  # In an insert session: l/L/<CR> descend, h/H climb out, <CR> on a file inserts
  # it, <C-y> inserts whatever is under the cursor (directories included, with a
  # trailing /), <Tab> cycles the path style, q cancels.
  #
  # <leader>e / <leader>E open the same tree as a plain explorer (at the current
  # file / at the cwd), where <CR> and L open files for editing instead.
  plugins.mini-files = {
    enable = true;
    settings = {
      options = {
        # oil stays the directory editor; mini.files is only summoned explicitly.
        use_as_default_explorer = false;
        permanent_delete = false;
      };
      windows = {
        # previews read file contents -- the one thing that would make this slow
        # over sshfs again.
        preview = false;
        width_focus = 45;
        width_nofocus = 18;
        max_number = 4;
      };
    };
  };

  extraConfigLua = ''
    _G.PathInsert = _G.PathInsert or {}
    local PI = _G.PathInsert

    PI.styles = { "file", "cwd", "abs", "home" }
    -- Short on purpose: these go in the window footer, which is as wide as the
    -- window. Anything echoed to the message line instead risks a hit-enter
    -- prompt, and that prompt eats the next keystroke (so `q` never reaches
    -- mini.files).
    PI.labels = {
      file = "rel: file",
      cwd = "rel: cwd",
      abs = "absolute",
      home = "rel: ~",
    }
    PI.style = nil -- sticky across invocations, set on first use
    PI.ctx = nil -- where to put the result; non-nil only during our sessions

    local function segments(p)
      local out = {}
      for s in p:gmatch("[^/]+") do
        out[#out + 1] = s
      end
      return out
    end

    -- path of `target` as seen from `dir`, using .. to climb out
    local function relpath(dir, target)
      local a, b = segments(vim.fs.normalize(dir)), segments(vim.fs.normalize(target))
      local i = 1
      while a[i] and b[i] and a[i] == b[i] do
        i = i + 1
      end
      local out = {}
      for _ = i, #a do
        out[#out + 1] = ".."
      end
      for j = i, #b do
        out[#out + 1] = b[j]
      end
      return #out == 0 and "." or table.concat(out, "/")
    end

    -- Openers we accept as "the seed starts here". Everything after an unclosed
    -- one is the seed, spaces included -- that is the whole point.
    local OPENERS = {
      ['"'] = '"',
      ["'"] = "'",
      ["`"] = "`",
      ["("] = ")",
      ["["] = "]",
      ["{"] = "}",
      ["<"] = ">",
    }

    -- Byte offset where the path the user is typing begins, given the text left
    -- of the cursor. Returns offset (0-based, i.e. #prefix) and the opener char.
    local function seed_begin(before)
      for i = #before, 1, -1 do
        local c = before:sub(i, i)
        local close = OPENERS[c]
        if close and not before:find(close, i + 1, true) then
          local content = before:sub(i + 1)
          -- Reject prose: an apostrophe in "don't" is an unclosed opener too.
          -- Content with a space is only a path if it also has a separator, and
          -- the opener must not sit inside a word.
          local wordish = i > 1 and before:sub(i - 1, i - 1):match("[%w_]")
          local pathish = content == "" or not content:find("%s") or content:find("/")
          if not wordish and pathish then
            return i, c
          end
          break
        end
      end
      -- no delimiter: walk back to whitespace, stepping over backslash-escapes
      local i = #before
      while i > 0 do
        local c = before:sub(i, i)
        if c:match("%s") then
          if before:sub(i - 1, i - 1) ~= "\\" then
            break
          end
          i = i - 1
        end
        i = i - 1
      end
      -- cut at the last = so `src = ./foo` seeds with ./foo, not `src = ./foo`
      local run = before:sub(i + 1)
      local eq = run:match(".*=()")
      if eq then
        i = i + eq - 1
      end
      return i, nil
    end

    -- Which directory to open, and the partial name to put the cursor on.
    local function resolve(seed, filedir)
      if seed == "" then
        return filedir, nil
      end
      local s = seed
      if s:sub(1, 1) == "~" then
        s = vim.fs.normalize(s)
      elseif s:sub(1, 1) ~= "/" then
        s = filedir .. "/" .. s
      end
      s = vim.fs.normalize(s)
      -- an existing entry: mini.files opens its parent with the cursor on it
      if vim.fn.isdirectory(s) == 1 or vim.fn.filereadable(s) == 1 then
        return s, nil
      end
      local dir, base = s:match("^(.*)/([^/]*)$")
      if dir and vim.fn.isdirectory(dir) == 1 then
        return dir, base
      end
      return filedir, nil
    end

    local function format(path, is_dir, ctx)
      local out
      if PI.style == "abs" then
        out = path
      elseif PI.style == "home" then
        out = vim.fn.fnamemodify(path, ":~")
      elseif PI.style == "cwd" then
        out = relpath(vim.fn.getcwd(), path)
      else
        out = relpath(ctx.filedir, path)
      end
      if is_dir then
        out = out .. "/"
      end
      if not out:find(" ") then
        return out
      end
      -- spaces: let the surrounding syntax decide
      local md = ctx.ft == "markdown" or ctx.ft == "asciidoc"
      if md and (ctx.delim == nil or ctx.delim == "(") then
        return (out:gsub(" ", "%%20"))
      end
      if ctx.delim then
        return out -- already inside quotes or brackets
      end
      local shelly = { sh = true, bash = true, zsh = true, fish = true, make = true, dockerfile = true }
      if shelly[ctx.ft] then
        return "'" .. out .. "'"
      end
      return out
    end

    -- Put the cursor back where we interrupted the user and resume typing.
    -- Shared by confirm (after the text is in) and cancel (nothing inserted).
    local function resume(ctx, col)
      if not (vim.api.nvim_buf_is_valid(ctx.buf) and vim.api.nvim_win_is_valid(ctx.win)) then
        return
      end
      vim.api.nvim_set_current_win(ctx.win)
      local line = vim.api.nvim_buf_get_lines(ctx.buf, ctx.row, ctx.row + 1, false)[1] or ""
      if col >= #line then
        vim.api.nvim_win_set_cursor(ctx.win, { ctx.row + 1, math.max(#line - 1, 0) })
        vim.cmd("startinsert!")
      else
        vim.api.nvim_win_set_cursor(ctx.win, { ctx.row + 1, col })
        vim.cmd("startinsert")
      end
    end

    -- pcall: setting a footer errors if the window has no border
    function PI.set_footer(win)
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative == "" then
        return
      end
      cfg.footer = " " .. PI.labels[PI.style] .. "  <Tab> "
      cfg.footer_pos = "right"
      pcall(vim.api.nvim_win_set_config, win, cfg)
    end

    function PI.cycle()
      local idx = 1
      for i, s in ipairs(PI.styles) do
        if s == PI.style then
          idx = i
        end
      end
      PI.style = PI.styles[(idx % #PI.styles) + 1]
      PI.set_footer(vim.api.nvim_get_current_win())
    end

    function PI.confirm()
      local MiniFiles = require("mini.files")
      local entry = MiniFiles.get_fs_entry()
      local ctx = PI.ctx
      if not entry or not ctx then
        return
      end
      local text = format(entry.path, entry.fs_type == "directory", ctx)
      ctx.done = true -- so the close autocmd does not also try to restore
      MiniFiles.close()
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(ctx.buf) then
          return
        end
        -- set_text, not feedkeys: no abbreviation expansion (ttt/ddd), no <>
        -- keycode parsing, no off-by-one from <esc>a, and its own undo block.
        vim.api.nvim_buf_set_text(ctx.buf, ctx.row, ctx.scol, ctx.row, ctx.ecol, { text })
        resume(ctx, ctx.scol + #text)
      end)
    end

    -- <CR>: descend into directories (the obvious reflex), insert files.
    -- Use <C-y> when the directory itself is what you want written out.
    function PI.enter()
      local MiniFiles = require("mini.files")
      local entry = MiniFiles.get_fs_entry()
      if entry and entry.fs_type == "directory" then
        MiniFiles.go_in({})
      else
        PI.confirm()
      end
    end

    function PI.start()
      local MiniFiles = require("mini.files")
      local win = vim.api.nvim_get_current_win()
      local buf = vim.api.nvim_get_current_buf()
      local cursor = vim.api.nvim_win_get_cursor(win)
      local row, col = cursor[1] - 1, cursor[2]
      local line = vim.api.nvim_get_current_line()
      local before = line:sub(1, col)
      local scol, delim = seed_begin(before)
      local name = vim.api.nvim_buf_get_name(buf)
      local filedir = name ~= "" and vim.fn.fnamemodify(name, ":p:h") or vim.fn.getcwd()

      PI.style = PI.style or (name ~= "" and "file" or "cwd")
      PI.ctx = {
        buf = buf,
        win = win,
        row = row,
        scol = scol,
        ecol = col,
        delim = delim,
        ft = vim.bo[buf].filetype,
        filedir = filedir,
      }

      local target, base = resolve(before:sub(scol + 1), filedir)
      -- The <Cmd> mapping runs *inside* insert mode and mode is global, not
      -- per-buffer, so without this the explorer window opens in insert mode
      -- and l/h type themselves into the (editable) directory buffer.
      vim.cmd("stopinsert")
      MiniFiles.open(target, false)
      vim.schedule(function()
        if base and base ~= "" then
          local b = vim.api.nvim_get_current_buf()
          for i = 1, vim.api.nvim_buf_line_count(b) do
            local e = MiniFiles.get_fs_entry(b, i)
            if e and e.name:lower():sub(1, #base) == base:lower() then
              pcall(vim.api.nvim_win_set_cursor, 0, { i, 0 })
              break
            end
          end
        end
      end)
    end

    -- Same tree, no insert session: just browse and open files. `where` nil
    -- reveals the current file inside its own directory.
    function PI.explore(where)
      local path = where
      if path == nil then
        local name = vim.api.nvim_buf_get_name(0)
        path = (name ~= "" and vim.fn.filereadable(name) == 1) and name or vim.fn.getcwd()
      end
      require("mini.files").open(path, true)
    end

    -- PI.ctx tells the two modes apart: set => we owe the caller a path.
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local b = args.data.buf_id
        if PI.ctx then
          vim.keymap.set("n", "<CR>", PI.enter, { buffer = b, desc = "go in / insert this file" })
          vim.keymap.set("n", "<C-y>", PI.confirm, { buffer = b, desc = "insert this path" })
          vim.keymap.set("n", "<Tab>", PI.cycle, { buffer = b, desc = "cycle path style" })
        else
          vim.keymap.set("n", "<CR>", function()
            require("mini.files").go_in({ close_on_file = true })
          end, { buffer = b, desc = "go in / open this file" })
        end
      end,
    })

    -- mini.files rebuilds window config as you navigate, so re-apply the footer
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesWindowUpdate",
      callback = function(args)
        if PI.ctx then
          PI.set_footer(args.data.win_id)
        end
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesExplorerClose",
      callback = function()
        local ctx = PI.ctx
        PI.ctx = nil
        if ctx and not ctx.done then -- cancelled: nothing inserted, keep typing
          vim.schedule(function()
            resume(ctx, ctx.ecol)
          end)
        end
      end,
    })

    vim.api.nvim_create_user_command("InsertPath", PI.start, {})
    vim.api.nvim_create_user_command("Explore", function(a)
      PI.explore(a.args ~= "" and a.args or nil)
    end, { nargs = "?", complete = "dir" })
  '';

  keymaps = [
    {
      # single key on purpose: <c-h>f times out into a backspace when you are
      # slow, because <c-h> *is* BS.
      key = "<M-f>";
      action = "<cmd>lua PathInsert.start()<cr>";
      mode = [
        "i"
        "n"
      ];
      options = {
        desc = "insert a file path (mini.files)";
        silent = true;
      };
    }
    {
      key = "<leader>e";
      action = "<cmd>lua PathInsert.explore()<cr>";
      mode = "n";
      options = {
        desc = "explore from this file (mini.files)";
        silent = true;
      };
    }
    {
      key = "<leader>E";
      action = "<cmd>lua PathInsert.explore(vim.fn.getcwd())<cr>";
      mode = "n";
      options = {
        desc = "explore from cwd (mini.files)";
        silent = true;
      };
    }
    {
      # muscle memory; worst case of the chord timing out is the builtin
      # completion it replaces.
      key = "<C-x><C-f>";
      action = "<cmd>lua PathInsert.start()<cr>";
      mode = "i";
      options = {
        desc = "insert a file path (mini.files)";
        silent = true;
      };
    }
  ];
}
