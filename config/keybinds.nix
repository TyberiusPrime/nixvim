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


    function run_job_with_output(command, args)
        local cmd = { command }
        if args and #args > 0 then
            vim.list_extend(cmd, args)
        end

        local result = {}
        local stdout = {}
        local stderr = {}

        local obj = vim.system(cmd, {
            text = true,
            stdout = function(_, data)
                table.insert(stdout, data)
                table.insert(result, data)
            end,
            stderr = function(_, data)
                table.insert(stderr, data)
                table.insert(result, data)
            end,
        }, function(success)
            if success then
                local res = obj:wait()
                print("Job finished with return value: " .. tostring(res.code))
            else
                print("Job failed to start")
            end
        end)

        -- Wait for completion (like :sync() did)
        obj:wait()

        return result
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


      vim.api.nvim_create_user_command("NotmuchGoto", function(opts)
        line = vim.api.nvim_get_current_line()
        mode = vim.api.nvim_get_mode().mode

        local pattern = "(notmuch:[^ ]+)"
        local url = find(line, mode, pattern)
        if url then
            local id = string.sub(url, 9)
            spawn_notmuch(id)
        end

        local pattern = '(f:"[^"]+)'
        local url = find(line, mode, pattern)
        -- debug url
        if url then
            local cmd = string.sub(url, 4)

            -- now run the command /persist/zettelkasten_git/florg3/bin/f
            -- get the output and open that file.
            --
            local shell_args = {}
            table.insert(shell_args, "cmd")

            local res = {}
            local res = run_job_with_output("/persist/zettelkasten_git/florg3/bin/f", { cmd })
            --trim filename
            local filename = string.gsub(res[1], "%s+", "")
            -- cut off line number after :
            -- using a regexp
            filename = string.gsub(filename, ":[0-9]*$", "")

            vim.cmd("e /persist/zettelkasten_git/florg_data/" .. filename)
        end

        local pattern = "(%d+%-[^%.]+%.adoc)"
        local url = find(line, mode, pattern)
        if url then
            vim.cmd("e /persist/zettelkasten_git/florg_data/" .. url)
        end
    end, { nargs = "?", range = 1 })

    function execute(command, args)
        -- Combine command and args into a single list
        local cmd = { command }
        if args and #args > 0 then
            vim.list_extend(cmd, args)
        end

        local result = {}
        local return_val = 0

        vim.system(cmd, { text = true }, function(obj)
            local success, exit_code, stdout, stderr = pcall(function()
                local res = obj:wait()
                return res.code, res.stdout, res.stderr
            end)

            if success then
                return_val = exit_code
                result = stdout
            else
                return_val = -1
                result = { exit_code }  -- capture error info
            end
        end)

        return return_val, result
    end
  

    function execute_with_error(command, args)
        local shell_args = {}
        for _, v in ipairs(args) do
            table.insert(shell_args, v)
        end

        local return_val, _ = execute(command, shell_args)
    end

    function spawn_notmuch(id)
        execute_with_error("kitty", {
            "--hold",
            "-d",
            "--",
            "/home/finkernagel/upstream/bfsd/result/bin/bfsd-mail-viewer",
            "--id",
            id,
        })
    end

    vim.api.nvim_create_user_command("NotmuchView", function(opts)
        local fargs = opts.fargs[1]
        if fargs then
            spawn_notmuch(fargs)
            return
        end
    end, { nargs = "?", range = 1 }
      )

    function find(line, mode, pattern, startIndex)
        startIndex = startIndex or 1
        local i, j, value = string.find(line, pattern, startIndex)
        if not i then
            return nil
        elseif check_if_cursor_on_url(mode, i, j) then
            return value
        else
            return find(line, mode, pattern, j + 1)
        end
    end

    function check_if_cursor_on_url(mode, i, j)
        if mode ~= "n" then
            return true
        end

        local col = vim.api.nvim_win_get_cursor(0)[2]
        if i <= (col + 1) and j >= (col + 1) then
            return true
        end

        return false
    end


  '';
  keymaps = [
    {
      action = ":NotmuchGoto<cr>";
      key = "gm";
      mode = "n";
    }
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
  ];
  autoCmd = [
    {
      event = "FileType";
      pattern = "asciidoc";
      command = "noremap <buffer> <F12> :lua zettelkasten_fix_links()<cr>";
    }
  ];

}
