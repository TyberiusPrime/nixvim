-- Force injection processing using correct nvim 0.11.5 API
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)
-- Set filetype to trigger treesitter autocommands
vim.bo.filetype = "python"

local parser = vim.treesitter.get_parser(0, "python")
-- Force a full parse
parser:parse({ 0, -1 })

-- Check children (injected sub-parsers) using the 0.11.5 API
print("=== Children after initial parse ===")
local children = parser:children()
print("  child count: " .. vim.tbl_count(children))
for lang, child_parser in pairs(children) do
  local child_trees = child_parser:parse()
  print("  child lang: " .. lang .. " trees: " .. #child_trees)
  for _, tree in ipairs(child_trees) do
    local root = tree:root()
    local sr, sc, er, ec = root:range()
    print(string.format("    range: (%d,%d)-(%d,%d)", sr, sc, er, ec))
  end
end

-- Try to force injection via _get_injections
print("\n=== Forcing _get_injections ===")
local ok, injections = pcall(function() return parser:_get_injections() end)
if ok then
  print("  injections type: " .. type(injections))
  if type(injections) == "table" then
    for k, v in pairs(injections) do
      print("  injection[" .. tostring(k) .. "]: " .. vim.inspect(v))
    end
  end
else
  print("  error: " .. tostring(injections))
end

-- Check children AFTER _get_injections
print("\n=== Children after _get_injections ===")
local children2 = parser:children()
print("  child count: " .. vim.tbl_count(children2))
for lang, child_parser in pairs(children2) do
  local child_trees = child_parser:parse()
  print("  child lang: " .. lang)
  for _, tree in ipairs(child_trees) do
    local root = tree:root()
    local sr, sc, er, ec = root:range()
    print(string.format("    range: (%d,%d)-(%d,%d)", sr, sc, er, ec))
  end
end

-- Check highlight captures
print("\n=== Captures at positions ===")
local captures4 = vim.treesitter.get_captures_at_pos(0, 4, 1)
print("  row=4 ([test]):")
if #captures4 == 0 then print("    (none)") end
for _, c in ipairs(captures4) do print("    " .. c.capture .. "(" .. c.lang .. ")") end

vim.cmd("qa!")
