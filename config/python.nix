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
      -- Neovim 0.10+ passes an array of nodes per capture; older versions a single node.
      local nodes = match[pred[2]]
      local node = type(nodes) == "table" and nodes[1] or nodes
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

    function toggle_f_string()
    	local node = vim.treesitter.get_node()

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
    	local start_row, start_col, end_row, end_col = node:range()

    	-- Inspect the string's actual prefix via its node text (position-independent).
    	-- Matches the leading letters before the opening quote, e.g. f"" / rf"" / "".
    	local node_text = vim.treesitter.get_node_text(node, 0)
    	local prefix = node_text:match("^(%a*)['\"]") or ""
    	local is_f_string = prefix:lower():find("f")

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
