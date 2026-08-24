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
      function time_and_insert()
          local line = vim.api.nvim_get_current_line()
          local col = vim.fn.col(".") -- 1-based byte col, cursor char
          local prev = line:sub(col - 1, col - 1) -- char left of cursor
          local sep = prev:match("%S") and " " or ""
          vim.api.nvim_feedkeys("i" .. sep .. os.date("%H:%M") .. " ", "n", false)
      end

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
    # paste from clipboard
    {
      action = "i<C-g>u<esc>\"+p";
      key = "<c-v>";
      mode = "n";
    }
    {
      action = "<C-g>u<esc>\"+p";
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
  ];
  autoCmd = [
    {
      event = "FileType";
      pattern = "asciidoc";
      command = "noremap <buffer> <F12> :lua zettelkasten_fix_links()<cr>";
    }
  ];

}
