{ ... }:
{
  extraConfigLua = ''
      -- a function that writes and closes the current buffer
      -- if it was the last buffer, quit vim
      function write_and_close()
          vim.cmd("w")
          if #vim.fn.getbufinfo({ buflisted = true }) == 1 then
              vim.cmd("q")
          else
              vim.cmd("bd")
          end
        end

    vim.api.nvim_create_user_command("GotoToday", function(opts)

      for ii = 0, 14 do -- Loop up to 2 weeks
        local date = os.date("%Y-%m-%d", os.time() - (ii * 86400)) -- Subtract days
        local pattern = "# " .. date
        local exists = vim.fn.search(pattern, "n") ~= 0

            -- for now this is good enough
            -- I could get all positions, list them by date, and move to the prev one if we're on one,
            -- or to the last one if no...
        if exists then
          local old_pos = vim.fn.getcurpos()[2]
          vim.cmd.normal("/" .. pattern .. "\nzz")
          local new_pos = vim.fn.getcurpos()[2]
          if old_pos ~= new_pos then
            return
           end
        end
      end

      print("Target date not found in the last two weeks.")
    end, { nargs = "?", range = 1 })

      -- insert current time (24h) plus a trailing space, then keep typing.
      -- adds a separating space first only when there's non-blank text
      -- right before the cursor; feeds the keys as if typed, so the cursor
      -- provably lands after the trailing space in insert mode.
      function insert_string_and_insert_mode(text)
          local line = vim.api.nvim_get_current_line()
          local col = vim.fn.col(".") -- 1-based byte col, cursor char
          local prev = line:sub(col - 1, col - 1) -- char left of cursor
          local sep = prev:match("%S") and " " or ""
          -- trailing <C-g>u breaks the undo sequence right after the
          -- inserted text, so it stays undoable on its own even though
          -- we remain in insert mode and keep typing afterwards.
          local keys = vim.api.nvim_replace_termcodes("i" .. sep .. text .. " <C-g>u", true, false, true)
          vim.api.nvim_feedkeys(keys, "n", false)
      end

      function time_and_insert()
        insert_string_and_insert_mode(os.date("%H:%M"))
      end

      function date_and_insert()
        insert_string_and_insert_mode(os.date("%Y-%m-%d"))
      end

      -- values for the <expr> abbreviations below. plain iabbrev only
      -- expands at a real word boundary, so no separator handling needed
      -- here (unlike insert_string_and_insert_mode, used by the <leader>
      -- mappings which can fire anywhere).
      function time_abbrev_expr()
        return os.date("%H:%M")
      end

      function date_abbrev_expr()
        return os.date("%Y-%m-%d")
      end

      vim.cmd([[
      :inoreabbrev <expr> ttt v:lua.time_abbrev_expr()
      :inoreabbrev <expr> ddd v:lua.date_abbrev_expr()
      ]])

  '';
  keymaps = [
    {
      action = ":lua write_and_close() <cr>";
      key = "<c-c><c-c>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = "<esc>:lua write_and_close() <cr>";
      key = "<c-c><c-c>";
      mode = "i";
      options = {
        silent = true;
      };
    }
    {
      # remove text, write to file and close
      action = "1GdG:lua write_and_close() <cr>";
      key = "<c-c><c-k>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = "<esc>1GdG:lua write_and_close() <cr>";
      key = "<c-c><c-k>";
      mode = "i";
      options = {
        silent = true;
      };
    }

    # { see lsp.nix
    #   action = "<esc>:lua vim.lsp.buf.format() <cr>";
    #   key = "<F12>";
    #   mode = "i";
    #   options = {
    #     silent = true;
    #   };
    # }
    {
      # quit without saving
      action = ":bd!<cr>:q<cr>";
      key = "<c-c><c-p>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = "<esc>:bd!<cr>:q<cr>";
      key = "<c-c><c-p>";
      mode = "i";
      options = {
        silent = true;
      };
    }
    # copy to clipboard
    {
      action = "\"+y";
      key = "<c-c>";
    }
    # paste from clipboard. pastes an image if the clipboard *contains* one,
    # otherwise the register, unchanged. see paste-image.nix
    {
      action = "i<C-g>u<esc><cmd>lua paste_image_or_register()<cr>";
      key = "<c-v>";
      mode = "n";
    }
    {
      action = "<C-g>u<esc><cmd>lua paste_image_or_register()<cr>";
      key = "<c-v>";
      mode = "i";
    }
    {
      # because it's muscle memory, and lsp signatures are less important
      action = ":w<cr>";
      key = "<c-s>";
      mode = "n";
    }
    {
      # because it's muscle memory, and lsp signatures are less important
      action = ":lua vim.lsp.buf.signature_help()<cr>";
      key = "<c-l>";
      mode = "n";
    }
    {
      action = "<esc>:w<cr>i";
      key = "<c-s>";
      mode = "i";
    }

    # {
    #   action = ":e <cfile><CR>";
    #   key = "gf";
    #   mode = "n";
    #   options.desc = "Open file under cursor, even if it doesn't exist";
    #
    # }
    {
      action = ":GotoToday()<cr>";
      key = "gt";
      mode = "n";
      options.desc = "go to todays dayt";

    }
    {
      action = ":lua time_and_insert()<cr>";
      key = "<leader>t";
      mode = "n";
      options = {
        silent = true;
        desc = "insert current time (24h)";
      };
    }

    {
      action = ":lua date_and_insert()<cr>";
      key = "<leader>d";
      mode = "n";
      options = {
        silent = true;
        desc = "insert current date (iso)";
      };
    }
    # ttt/ddd themselves are now real abbreviations (see :inoreabbrev
    # above), so they only expand at a word boundary and don't need a
    # keymap entry here.

    # break the undo sequence at word/line boundaries, so a single `u`
    # in insert mode undoes one word (or the ttt/ddd abbreviation
    # expansion) at a time instead of the whole insert session.
    # <C-]> first, to explicitly trigger any pending abbreviation
    # expansion: once <space>/<cr> is itself mapped, Neovim no longer
    # treats it as a "typed" trigger character, so plain iabbrev
    # expansion (ttt/ddd here, sgg/impotr elsewhere) silently stops
    # firing without it.
    {
      action = "<C-]><C-g>u<space>";
      key = "<space>";
      mode = "i";
      options.desc = "insert space, expanding abbrevs and breaking undo sequence";
    }
    {
      action = "<C-]><C-g>u<cr>";
      key = "<cr>";
      mode = "i";
      options.desc = "insert newline, expanding abbrevs and breaking undo sequence";
    }
  ];
  autoCmd = [
    {
      event = "FileType";
      pattern = "asciidoc";
      command = "noremap <buffer> <F12> :lua zettelkasten_fix_links()<cr>";
    }
  ];

}
