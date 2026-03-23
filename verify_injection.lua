-- Verify that treesitter injection actually works for # toml / # sql blocks
local filename = vim.fn.argv(0)
if filename == "" then filename = "test_inject.py" end

vim.cmd("edit " .. filename)
vim.treesitter.start(0, "python")
vim.cmd("redraw")

-- Try to parse injections by asking what language is at specific positions
-- Line 4 (0-indexed: line 3), col 1 should be inside the toml block
local function check_lang_at(row, col)
  local node = vim.treesitter.get_node({ pos = {row, col}, ignore_injections = false })
  if node then
    local lang = vim.treesitter.get_parser(0):language_for_range({row, col, row, col + 1})
    return lang
  end
  return "no node"
end

-- Give treesitter time to run injections
vim.defer_fn(function()
  print("=== Language at positions ===")
  -- Line 4 col 1 = inside toml block  (0-indexed: row=4, col=1)
  -- File:
  --  0: import re
  --  1: (empty)
  --  2: # toml
  --  3: """
  --  4: [test]
  --  5:    anton = 12
  --  6: """
  --  7: (empty)
  --  8: # sql
  --  9: """
  -- 10: SELECT...

  local function get_lang(row, col)
    local ok, result = pcall(function()
      local node = vim.treesitter.get_node({ pos = {row, col}, ignore_injections = false })
      if not node then return "no node" end
      -- Walk up to find language
      local p = vim.treesitter.get_parser(0)
      -- Check all child parsers
      local found_lang = "python"
      p:for_each_child(function(child_parser, lang)
        local trees = child_parser:trees()
        for _, tree in ipairs(trees) do
          local root = tree:root()
          if root:contains({row, col, row, col}) then
            found_lang = lang
          end
        end
      end)
      return found_lang
    end)
    if ok then return result else return "error: " .. tostring(result) end
  end

  print(string.format("  row=4 col=1 (inside toml block): %s", get_lang(4, 1)))
  print(string.format("  row=10 col=1 (inside sql block): %s", get_lang(10, 1)))
  print(string.format("  row=0 col=0 (import re): %s", get_lang(0, 0)))
  print(string.format("  row=13 col=0 (x = 5): %s", get_lang(13, 0)))

  vim.cmd("qa!")
end, 200)
