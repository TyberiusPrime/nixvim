{
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
