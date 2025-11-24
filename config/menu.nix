# todo
#         vim.keymap.set('n', '<Leader>t', require('whitespace-nvim').trim)
# SudaWrite
# MarkdownPreview / MarkdownToggle
# oil
# undotree
{

  extraConfigLua = ''
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
  ];
}
