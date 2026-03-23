-- Force child parsers to actually parse
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)
vim.bo.filetype = "python"

local parser = vim.treesitter.get_parser(0, "python")
parser:parse({ 0, -1 })

-- Force each child to parse by setting their regions and calling parse
local children = parser:children()
print("Children: " .. vim.tbl_count(children))

for lang, child_parser in pairs(children) do
  -- Try to force parse by getting included regions and re-parsing
  local regions = child_parser:included_regions()
  print(string.format("  %s: included_regions=%s", lang, vim.inspect(regions)))
  -- Force parse
  local trees = child_parser:parse({ 0, -1 })
  print(string.format("  %s: trees after force parse=%d", lang, #trees))
  for _, tree in ipairs(trees) do
    local root = tree:root()
    local sr, sc, er, ec = root:range()
    print(string.format("    range: (%d,%d)-(%d,%d) | text: %s",
      sr, sc, er, ec,
      vim.inspect(vim.treesitter.get_node_text(root, 0):sub(1, 40))))
  end
end

-- Now check captures
print("\n=== Captures AFTER forcing child parse ===")
local function show_caps(row, col, label)
  local caps = vim.treesitter.get_captures_at_pos(0, row, col)
  local names = {}
  for _, c in ipairs(caps) do
    table.insert(names, c.capture .. "(" .. c.lang .. ")")
  end
  print(string.format("  %s: %s", label, #names > 0 and table.concat(names, ", ") or "(none)"))
end

show_caps(4, 1, "row=4 [test]")
show_caps(5, 4, "row=5 anton")
show_caps(2, 2, "row=2 # toml comment")
show_caps(0, 0, "row=0 import")

vim.cmd("qa!")
