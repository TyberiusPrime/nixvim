-- Debug what highlight captures are active at positions in the toml block
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)
vim.treesitter.start(0, "python")
local parser = vim.treesitter.get_parser(0, "python")
parser:parse()

-- Check what injection.language resolve to
local q = vim.treesitter.query.get("python", "injections")
print("=== injection query captures: " .. vim.inspect(q and q.captures or "nil"))

if q then
  local tree = parser:parse()[1]
  local root = tree:root()
  for pattern, match, metadata in q:iter_matches(root, 0) do
    for id, nodes in pairs(match) do
      local name = q.captures[id]
      if name:match("injection") then
        local node_list = type(nodes) == "table" and nodes or {nodes}
        for _, node in ipairs(node_list) do
          if node and node.range then
            local sr, sc = node:range()
            local meta_text = metadata[id] and metadata[id].text
            local raw = vim.treesitter.get_node_text(node, 0)
            if #raw > 40 then raw = raw:sub(1, 40) .. "..." end
            print(string.format("  [%d] %s: %s%s", pattern, name, vim.inspect(raw),
              meta_text and " -> '" .. meta_text .. "'" or ""))
          end
        end
      end
    end
  end
end

-- Check highlight captures at row 4 (the "[test]" line, 0-indexed)
print("\n=== Highlight captures at key positions ===")
local function get_captures(row, col)
  local captures = vim.treesitter.get_captures_at_pos(0, row, col)
  if #captures == 0 then
    return "(none)"
  end
  local names = {}
  for _, cap in ipairs(captures) do
    table.insert(names, cap.capture .. "(" .. cap.lang .. ")")
  end
  return table.concat(names, ", ")
end

-- Row 3 = "# toml" comment (0-indexed: row 2 in file)
-- File layout after edit:
-- 0: import re
-- 1: (empty)
-- 2: # toml
-- 3: """
-- 4: [test]
-- 5:    anton = 12
-- 6: """
print(string.format("  row=2 (# toml comment): %s", get_captures(2, 2)))
print(string.format("  row=4 ([test]): %s", get_captures(4, 1)))
print(string.format("  row=5 (   anton = 12): %s", get_captures(5, 4)))
print(string.format("  row=0 (import re): %s", get_captures(0, 0)))

vim.cmd("qa!")
