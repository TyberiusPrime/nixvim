-- Simplified injection debug
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)

local parser = vim.treesitter.get_parser(0)
if not parser then
  print("ERROR: no parser for buffer")
  vim.cmd("qa!")
  return
end

print("Parser lang: " .. parser:lang())
print("Parser type: " .. type(parser))

-- Check methods
print("has parse: " .. tostring(type(parser.parse) == "function"))
print("has for_each_child: " .. tostring(type(parser.for_each_child) == "function"))
print("has children: " .. tostring(type(parser.children) == "function"))
print("has child_for_range: " .. tostring(type(parser.child_for_range) == "function"))

-- Try to get tree
local trees = parser:parse()
print("Trees: " .. #trees)

-- List available methods
local methods = {}
for k, v in pairs(getmetatable(parser) or {}) do
  if type(v) == "function" then
    table.insert(methods, k)
  end
end
table.sort(methods)
print("Methods: " .. table.concat(methods, ", "))

vim.cmd("qa!")
