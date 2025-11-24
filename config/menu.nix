# todo
#         vim.keymap.set('n', '<Leader>t', require('whitespace-nvim').trim)
# SudaWrite
# MarkdownPreview / MarkdownToggle
# oil
# undotree
{

  extraConfigLua = ''

    hugo_links = function()
    	local cmd = {"find"}
    	local docs_path = require('project').get_project_root() .. "/docs/content"
    	table.insert(cmd, docs_path)
    	table.insert(cmd, "-name")
    	table.insert(cmd, "*.md")
    	table.insert(cmd, "-type")
    	table.insert(cmd, "f")

        local hits = vim.fn.systemlist(vim.tbl_flatten(cmd))

        if #hits == 0 then
            print("No markdown files found in docs/content")
            return
        end

        -- Multiple hits, use selection
        local commands = {}
        for _, file in ipairs(hits) do
            local relative_path = file:gsub("^" .. docs_path , "")
            local display_name = relative_path:gsub("%.md$", ""):gsub("/", " > ")
            local link_name = relative_path:match("([^/]+)%.md$") or relative_path:gsub("%.md$", "")
            local hugo_link = string.format('[%s]({{< relref "%s" >}})', link_name, relative_path)

            commands[display_name] = function()
                vim.api.nvim_put({ hugo_link }, "", false, true)
            end
        end

        local cmd = {}
        for name, _ in pairs(commands) do
            table.insert(cmd, name)
        end  



        vim.ui.select(cmd, {
                    prompt = 'Hugo',
                }, function(choice)
                    if choice then
                        commands[choice]()
                      end
                    end
            )
    end

    my_emails = function() 
        local emails = vim.fn.systemlist({"~/upstream/bfsd/result/bin/bfsd-mail-whoser", "--dump"})

       vim.ui.select(emails, {
                    prompt = 'Emails',
                }, function(choice)
                    if choice then
                        vim.api.nvim_put({ choice }, "", false, true)
                      end
                    end
            )
    end


          vim.api.nvim_exec(
        	[[
        function! DiffAgainstFileOnDisk()
          :w! /tmp/working_copy
          exec "!diff /tmp/working_copy %"
        endfunction

        function! SearchDate()
        	if search(strftime('%Y-%m-%d')) == 0
        		let out = "<" . strftime('%Y-%m-%d') . ">"
        		norm! Go
        		put =out
        		norm! o
        		let out = "* "
        		put =out
        		"pu=
        		"norm! kJo
        		:startinsert!
        	endif
        endfunction


        function! InsertDate()
        	let out = "# " . strftime('%Y-%m-%d') . ""
        	put=out
        	norm! o
        	:startinsert
        endfunction


        function StripAnsi()
        	%s/\%x1b\[[0-9;]*m//g
        	%s/\r/
        endfunction

        ]],
        	false
        )

      function mymenu()
        local replace_termcodes = function(str)
            return vim.api.nvim_replace_termcodes(str, true, true, true)
        end
        local commands = {}

        commands["Sudo write"] = function ()
            vim.cmd('SudaWrite')
          end
        commands["Open Undotree"] = function ()
            vim.cmd('UndotreeShow')
            vim.cmd('UndotreeFocus')
          end

        commands["Goto today/ search date"] = function() 
          vim.cmd(":call SearchDate()")
        end
        commands["insert date"] = function() 
          vim.cmd(":call InsertDate()")
        end
        commands["Diff against file on disk"] = function() 
          vim.cmd(":call DiffAgainstFileOnDisk()")
        end
        commands["Strip ANSI codes"] = function() 
          vim.cmd(":call StripAnsi()")
        end
        commands["Trim whitespace"] = function()  
         require('whitespace-nvim').trim()
        end
        commands["close other buffers"] = function() 
          vim.cmd("%bd|e#|bd#")
        end
        commands["reverse complement"] = function() 
          vim.cmd(":lua line_wise_rev_complement(true)")
        end
        commands["copy reverse complement"] = function() 
          vim.cmd(":lua line_wise_rev_complement(false)")
        end
        commands["copy filename to clipboard"] = function() 
          vim.cmd([[
          	let @+ = expand("%:p")
          ]])
        end
        commands["cwd to project"]  = function() 
          local root, lsp_or_method = require('project').get_project_root()
          if root then
              vim.cmd('cd ' .. root)
              print('Changed directory to project root: ' .. root .. ' (' .. lsp_or_method .. ')')
          else
              print('Project root not found.')
          end
        end
        commands["cwd to file"] = function()
          local filepath = vim.fn.expand('%:p:h')
          if filepath ~= "" then
              vim.cmd('cd ' .. filepath)
              print('Changed directory to file path: ' .. filepath)
          else
              print('File path not found.')
          end
        end

        commands["hugo links"] = hugo_links




        local command_names = {}
        for name, _ in pairs(commands) do
            table.insert(command_names, name)
        end

        vim.ui.select(command_names, {
                    prompt = 'Menu',
                }, function(choice)
                    if choice then
                        commands[choice]()
                      end
                    end
            )
        end
  '';
  keymaps = [
    {
      key = "<leader>m";
      action = ":lua mymenu()<cr>";
      mode = "n";
    }
    {
      key = "<leader>l";
      action = ":lua my_emails()<cr>";
      mode = "n";
    }
    {
      key = "<c-h>l";
      action = ":lua my_emails()<cr>";
      mode = "i";
    }
  ];
}
