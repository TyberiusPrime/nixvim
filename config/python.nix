{
  extraFiles = {
    "queries/python/injections.scm".text = ''
      ;extends

      ; Inject language based on # <lang> comment immediately before a string literal.
      ; Example:
      ;   # toml
      ;   """[section]
      ;   key = "value"
      ;   """
      ((comment) @injection.language
       .
       (expression_statement
         (string (string_content) @injection.content))
       (#gsub! @injection.language "^# ?" ""))

      ; Inject language based on shebang on the first line of a multi-line string.
      ; Supports: #!lang  |  #!/path/to/lang  |  #!/usr/bin/env lang
      ; Example:
      ;   """#!/usr/bin/env bash
      ;   echo hello
      ;   """
      ((string
        (string_content) @_shebang @injection.content)
       (#lua-match? @_shebang "^\n?#!")
       (#set-lang-from-shebang! @_shebang))
    '';
  };

  autoCmd = [
    {
      event = "FileType";
      pattern = "python";
      command = "iabbrev impotr import";
    }
  ];

  keymaps = [
    {
      key = "<c-f>";
      action = ":lua toggle_f_string()<cr>";
      mode = "n";
      options.desc = "Toggle f-string";
    }
    {
      key = "<c-f>";
      action = "<esc>:lua toggle_f_string()<cr>";
      mode = "i";
      options.desc = "Toggle f-string";
    }
  ];

  extraConfigLua = ''
    -- Register directive to extract injection language from a shebang line.
    -- Handles: #!lang  |  #!/path/to/lang  |  #!/usr/bin/env lang
    vim.treesitter.query.add_directive("set-lang-from-shebang!", function(match, _, bufnr, pred, metadata)
      local node = match[pred[2]]
      if not node then return end
      local text = vim.treesitter.get_node_text(node, bufnr)
      local first_line = text:match("^%s*([^\n]+)")
      if not first_line then return end
      local lang =
        first_line:match("^#!.*/env%s+(%a[%w_%-]*)") or  -- #!/usr/bin/env bash
        first_line:match("^#!.*/(%a[%w_%-]*)") or         -- #!/bin/bash
        first_line:match("^#!(%a[%w_%-]*)")                -- #!bash
      if lang then
        metadata["injection.language"] = lang:lower()
      end
    end, { force = true, all = false })

      local ts_utils = require("nvim-treesitter.ts_utils")

    function toggle_f_string()
    	local node = ts_utils.get_node_at_cursor()

    	-- Check if we're inside a string
    	while node do
    		if node:type() == "string" then
    			break
    		end
    		node = node:parent()
    	end

    	if not node or node:type() ~= "string" then
    		print("Not inside a string")
    		return
    	end

    	-- Get the start and end positions of the string
    	local start_row, start_col, end_row, end_col = ts_utils.get_node_range(node)

    	-- Read the current line content
    	local line = vim.api.nvim_get_current_line()

    	-- Check  the string is already an f-string
    	local is_f_string = line:sub(start_col + 1, start_col + 2):match("^f")

    	-- Toggle the f-string status
    	if is_f_string then
    		-- Remove the 'f'
    		vim.api.nvim_buf_set_text(0, start_row, start_col, start_row, start_col + 1, { "" })
    	else
    		-- Add the 'f'
    		vim.api.nvim_buf_set_text(0, start_row, start_col, start_row, start_col, { "f" })
    	end
    end


  '';

}
