-- Final check on test.py injection
local filename = arg and arg[1] or "test.py"
vim.cmd("edit " .. filename)

local parser = vim.treesitter.get_parser(0, "python")
local tree = parser:parse()[1]
local root = tree:root()

-- Run the injection query
local q = vim.treesitter.query.get("python", "injections")
print("=== Injection matches in " .. filename .. " ===")
for pattern, match, metadata in q:iter_matches(root, 0) do
  for id, nodes in pairs(match) do
    local name = q.captures[id]
    if name == "injection.language" then
      local node_list = type(nodes) == "table" and nodes or {nodes}
      for _, node in ipairs(node_list) do
        if node and node.range then
          local meta_text = metadata[id] and metadata[id].text
          local raw = vim.treesitter.get_node_text(node, 0)
          print(string.format("  comment %s -> lang '%s'", vim.inspect(raw), meta_text or "(raw)"))
        end
      end
    end
  end
end

-- Force children and check captures
parser:parse({0,-1})
for _, child in pairs(parser:children()) do child:parse(true) end

print("\n=== Key captures (after forced parse) ===")
local function cap_str(row, col, label)
  local caps = vim.treesitter.get_captures_at_pos(0, row, col)
  local t = {}
  for _, c in ipairs(caps) do
    if c.lang ~= "python" then  -- only show non-python (injection) captures
      table.insert(t, c.capture .. "(" .. c.lang .. ")")
    end
  end
  print(string.format("  row=%d %s: %s", row, label, #t > 0 and table.concat(t, " | ") or "(python only - NO injection)"))
end

-- test.py rows:
-- 2: # toml
-- 3: """
-- 4: [test]
-- 5:    anton = 12
-- 6: """
-- 24: # 2025-11-24  <- should NOT inject
-- 8: "hallo grausami welt"  <- should NOT inject
cap_str(4, 0, "[test] bracket")
cap_str(4, 1, "[test] key 't'")
cap_str(5, 3, "anton")
cap_str(5, 11, "12")
cap_str(23, 2, "# 2025-11-24 (should be python only)")
cap_str(8, 1, "'hallo...' (should be python only)")

vim.cmd("qa!")
