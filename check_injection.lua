-- Check that the python injection query is loaded and working
local filename = vim.fn.argv(0)
if filename == "" then filename = "test_inject.py" end

vim.cmd("edit " .. filename)

-- Find the injection query file in runtimepath
local injection_files = vim.fn.globpath(vim.o.runtimepath, "queries/python/injections.scm", false, true)
print("=== Python injection files in runtimepath ===")
for _, f in ipairs(injection_files) do
  print("  " .. f)
  local content = vim.fn.readfile(f)
  for _, line in ipairs(content) do
    print("    " .. line)
  end
end

-- Start treesitter and check language trees (injections)
local ok, err = pcall(vim.treesitter.start, 0, "python")
if not ok then
  print("Error: " .. tostring(err))
  vim.cmd("qa!")
  return
end

-- Wait for parser to process
vim.cmd("redraw")

local parser = vim.treesitter.get_parser(0, "python")
parser:parse()

print("\n=== Language trees (injections) ===")
parser:for_each_child(function(child_parser, lang)
  print(string.format("  Injected language: %s", lang))
  local trees = child_parser:parse()
  for _, tree in ipairs(trees) do
    local root = tree:root()
    local sr, sc, er, ec = root:range()
    print(string.format("    range: (%d,%d)-(%d,%d)", sr, sc, er, ec))
  end
end)

vim.cmd("qa!")
