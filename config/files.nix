{ ... }:
{
  extraConfigLua = ''

  function ff_filelister(args, insert_or_append)
      local Snacks = require("snacks")
      local confirm = "edit"
      if insert_or_append then
          confirm  = function(picker, item)
            picker:norm(function()
              if item then
                picker:close()
                vim.api.nvim_input("a" .. item.text)
              end
            end)
          end
      end

      Snacks.picker("external_files", {
        prompt = "Select file: ",
        preview = "none",
        finder = function(opts, ctx)
    	   local cmd = "ff_filelister"

        -- This runs the command and returns its output split as lines
          -- Example command: lists all *.lua files using cmd.exe
          -- Execute & capture the output
        return require("snacks.picker.source.proc").proc(
          ctx:opts({
            cmd = cmd,
            args = args,
            ---@param item snacks.picker.finder.Item
            transform = function(item)
              item.file = item.text

              item.dir = true
            end,
          }),
          ctx
        )
      end,
      layout = {
        preset = "vscode",
      },

      -- What happens when the user selects an item
      confirm = confirm
      })
    end

    function my_files(insert_or_append) 
        local args = {}
    	table.insert(args, "300")
    	table.insert(args, vim.loop.cwd())
    	table.insert(args, "--")
    	table.insert(args, "--type")
    	table.insert(args, "js")
    	table.insert(args, "--type")
    	table.insert(args, "lua")
    	table.insert(args, "--type")
    	table.insert(args, "vim")
    	table.insert(args, "--type-add")
    	table.insert(args, "tera:*.tera")
    	table.insert(args, "--type-add")
    	table.insert(args, "adoc:*.adoc")
    	table.insert(args, "--type")
    	table.insert(args, "adoc")
    	table.insert(args, "--type-add")
    	table.insert(args, "cfg:*.cfg")
    	table.insert(args, "--type")
    	table.insert(args, "cfg")
    	table.insert(args, "--type-add")
    	table.insert(args, "toml:*.toml")
    	table.insert(args, "--type")
    	table.insert(args, "toml")
    	table.insert(args, "--type")
    	table.insert(args, "rust")
    	table.insert(args, "--type")
    	table.insert(args, "py")
    	table.insert(args, "--type")
    	table.insert(args, "cython")
    	table.insert(args, "--type")
    	table.insert(args, "rst")
    	table.insert(args, "--type")
    	table.insert(args, "md")
    	table.insert(args, "--type")
    	table.insert(args, "html")
    	table.insert(args, "--type")
    	table.insert(args, "txt")
    	table.insert(args, "--type")
    	table.insert(args, "nix")
    	table.insert(args, "--type")
    	table.insert(args, "ts")
    	table.insert(args, "--type-add")
    	table.insert(args, "svelte:*.svelte")
    	table.insert(args, "--type")
    	table.insert(args, "svelte")
    	table.insert(args, "-g!code/venv")
    	table.insert(args, "-g!results")
    	table.insert(args, "-g!cache")
    	--are we in a directory that has /database' somewhere in it's path?
    	local cwd = vim.fn.getcwd()
    	-- Check if '/database/' is in the path
    	local contains_database = string.match(cwd, "/database/") ~= nil
    	if not contains_database then
    		table.insert(args, "-g!incoming")
    	end
    	table.insert(args, "-g!manual_code")
    	table.insert(args, "-g!*.egg-info")
    	table.insert(args, "-j")
    	table.insert(args, "40")
    	table.insert(args, "--files")
        ff_filelister(args, insert_or_append)
    end

    function my_local_files(insert_or_append) 
        local args = {}
        table.insert(args, "300")
        local dir = vim.fn.expand("%:p:h")
        table.insert(args, dir)
        ff_filelister(args, insert_or_append)
    end
  '';

  keymaps = [
    {
      key = "<leader>f";
      action = ":lua my_files()<cr>";
      mode = "n";
    }
    {
      key = "<leader>F";
      action = ":lua my_local_files()<cr>";
      mode = "n";
    }
    {
      key = "<c-h>f";
      action = "<esc>:lua my_files(true)<cr>";
      mode = "i";
    }
    {
      key = "<c-h>F";
      action = "<esc>:lua my_local_files(true)<cr>";
      mode = "i";
      }
     {
      key = "<leader>j";
      action = "<esc>:lua Snacks.picker.git_files()<cr>";
      mode = "n";
    }{
      key = "<backspace>";
      action = "<esc>:lua Snacks.picker.buffers()<cr>";
      mode = "n";
    }

  ];

}
