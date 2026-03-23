-- Synchronous injection verification
local filename = vim.fn.argv(0)
if filename == "" then filename = "test_inject.py" end

vim.cmd("edit " .. filename)
vim.treesitter.start(0, "python")

local parser = vim.treesitter.get_parser(0, "python")
-- Force a full parse including injections
parser:parse(true)

print("=== Injected language ranges ===")
local found_any = false
parser:for_each_child(function(child_parser, lang)
  found_any = true
  local trees = child_parser:parse()
  for _, tree in ipairs(trees) do
    local root = tree:root()
    local sr, sc, er, ec = root:range()
    print(string.format("  lang=%s range=(%d,%d)-(%d,%d)", lang, sr, sc, er, ec))
  end
end)

if not found_any then
  print("  (no injected languages found - trying explicit approach)")

  -- Try explicitly loading the injection query
  local q = vim.treesitter.query.get("python", "injections")
  if q then
    print("  injection query loaded, captures: " .. vim.inspect(q.captures))
    local tree = parser:parse()[1]
    local root = tree:root()
    for pattern, match, metadata in q:iter_matches(root, 0) do
      for id, nodes in pairs(match) do
        local name = q.captures[id]
        if name == "injection.language" then
          local node_list = type(nodes) == "table" and nodes or {nodes}
          for _, node in ipairs(node_list) do
            if node then
              local meta_text = metadata[id] and metadata[id].text
              local raw = vim.treesitter.get_node_text(node, 0)
              print(string.format("  injection.language: raw=%s -> resolved=%s", vim.inspect(raw), vim.inspect(meta_text or raw)))
            end
          end
        end
      end
    end
  else
    print("  no injection query found")
  end
end

vim.cmd("qa!")
