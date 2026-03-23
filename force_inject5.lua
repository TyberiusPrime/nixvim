-- Try different parse approaches on children
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)
vim.bo.filetype = "python"

local parser = vim.treesitter.get_parser(0, "python")
parser:parse({ 0, -1 })

local children = parser:children()

-- Try the toml child specifically
local toml_parser = children["toml"]
if not toml_parser then
  print("ERROR: no toml child parser")
  vim.cmd("qa!")
  return
end

print("toml regions: " .. vim.inspect(toml_parser:included_regions()))

-- Try various parse calls
print("parse() no args:")
local t1 = toml_parser:parse()
print("  trees: " .. #t1)

print("parse(true) force:")
local t2 = toml_parser:parse(true)
print("  trees: " .. #t2)

print("parse({3,6}) range:")
local t3 = toml_parser:parse({3, 6})
print("  trees: " .. #t3)
for _, tree in ipairs(t3) do
  local root = tree:root()
  local sr, sc, er, ec = root:range()
  local text = vim.treesitter.get_node_text(root, 0)
  print(string.format("  range=(%d,%d)-(%d,%d) root_type=%s text=%s",
    sr, sc, er, ec, root:type(), vim.inspect(text:sub(1,40))))
end

-- Try using _parse directly
print("\n_parse():")
local ok, res = pcall(function() return toml_parser:_parse(false, 0, -1) end)
print("  ok=" .. tostring(ok) .. " res=" .. tostring(res))

-- Check is_valid
print("\ntoml valid: " .. tostring(toml_parser:is_valid()))

vim.cmd("qa!")
