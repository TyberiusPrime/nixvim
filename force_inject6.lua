-- Force all children with parse(true) then check captures
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)
vim.bo.filetype = "python"

local parser = vim.treesitter.get_parser(0, "python")
parser:parse({ 0, -1 })

-- Force all children to parse
local children = parser:children()
for lang, child in pairs(children) do
  child:parse(true)
  print("forced parse for: " .. lang)
end

-- Now check captures
print("\n=== Captures after forced child parse ===")
local function show_caps(row, col, label)
  local caps = vim.treesitter.get_captures_at_pos(0, row, col)
  local names = {}
  for _, c in ipairs(caps) do
    table.insert(names, c.capture .. "(" .. c.lang .. ")")
  end
  print(string.format("  %s: %s", label, #names > 0 and table.concat(names, ", ") or "(none)"))
end

-- test.py layout:
-- 0: import re
-- 1: (empty)
-- 2: # toml
-- 3: """
-- 4: [test]
-- 5:    anton = 12
-- 6: """
show_caps(4, 1, "row=4 [test]")
show_caps(4, 0, "row=4 col=0")
show_caps(5, 4, "row=5 anton=12")
show_caps(2, 2, "row=2 # toml")
show_caps(0, 0, "row=0 import")

-- Also directly query the toml tree
print("\n=== TOML tree highlights ===")
local toml_child = children["toml"]
if toml_child then
  local trees = toml_child:parse(true)
  if #trees > 0 then
    local root = trees[1]:root()
    print("toml root type: " .. root:type())
    print("toml root range: " .. vim.inspect({root:range()}))

    -- Try to get highlights query for toml
    local hl_q = vim.treesitter.query.get("toml", "highlights")
    if hl_q then
      print("toml highlights captures: " .. vim.inspect(hl_q.captures))
      for pattern, match, meta in hl_q:iter_matches(root, 0) do
        for id, nodes in pairs(match) do
          local name = hl_q.captures[id]
          local node_list = type(nodes) == "table" and nodes or {nodes}
          for _, node in ipairs(node_list) do
            if node then
              local sr, sc, er, ec = node:range()
              local text = vim.treesitter.get_node_text(node, 0)
              if #text > 30 then text = text:sub(1,30) .. "..." end
              print(string.format("  [%s] (%d,%d)-(%d,%d): %s", name, sr, sc, er, ec, vim.inspect(text)))
            end
          end
        end
      end
    else
      print("no toml highlights query found")
    end
  end
end

vim.cmd("qa!")
