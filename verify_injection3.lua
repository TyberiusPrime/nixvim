-- Check the combined injection query content
local filename = vim.fn.argv(0)
if filename == "" then filename = "test_inject.py" end

vim.cmd("edit " .. filename)
vim.treesitter.start(0, "python")
local parser = vim.treesitter.get_parser(0, "python")
parser:parse()

-- Check the combined injection query
local q = vim.treesitter.query.get("python", "injections")
if not q then
  print("ERROR: no python injection query found")
  vim.cmd("qa!")
  return
end

print("=== Combined python injection query captures ===")
print("  captures: " .. vim.inspect(q.captures))

-- Run the query
local tree = parser:parse()[1]
local root = tree:root()
print("\n=== Injection query matches ===")
local match_count = 0
for pattern, match, metadata in q:iter_matches(root, 0) do
  match_count = match_count + 1
  local match_info = {}
  for id, nodes in pairs(match) do
    local name = q.captures[id]
    local node_list = type(nodes) == "table" and nodes or {nodes}
    for _, node in ipairs(node_list) do
      if node and node.range then
        local sr, sc, er, ec = node:range()
        local meta_text = metadata[id] and metadata[id].text
        local raw = vim.treesitter.get_node_text(node, 0)
        if #raw > 40 then raw = raw:sub(1, 40) .. "..." end
        table.insert(match_info, string.format("%s=%s%s", name, vim.inspect(raw),
          meta_text and ("->'" .. meta_text .. "'") or ""))
      end
    end
  end
  if #match_info > 0 then
    print("  match[" .. pattern .. "]: " .. table.concat(match_info, ", "))
  end
end

if match_count == 0 then
  print("  (no matches found)")
end

vim.cmd("qa!")
