-- Inspect treesitter parse tree for a file
-- Usage: nvim --headless -u NONE -l inspect_ts.lua <file>

local filename = vim.fn.argv(0)
if filename == "" then
  filename = "test_inject.py"
end

-- Load the file
vim.cmd("edit " .. filename)

-- Ensure treesitter is loaded for python
local ok, err = pcall(vim.treesitter.start, 0, "python")
if not ok then
  print("Error starting treesitter: " .. tostring(err))
  vim.cmd("qa!")
  return
end

local parser = vim.treesitter.get_parser(0, "python")
if not parser then
  print("No parser available")
  vim.cmd("qa!")
  return
end

local tree = parser:parse()[1]
local root = tree:root()

-- Print all nodes in the tree
local function print_node(node, indent)
  indent = indent or 0
  local prefix = string.rep("  ", indent)
  local srow, scol, erow, ecol = node:range()
  local text = ""
  if node:child_count() == 0 then
    -- leaf node, get text
    text = " = " .. vim.inspect(vim.treesitter.get_node_text(node, 0))
    if #text > 60 then text = text:sub(1, 60) .. "..." end
  end
  print(string.format("%s[%s] (%d,%d)-(%d,%d)%s", prefix, node:type(), srow, scol, erow, ecol, text))
  for child in node:iter_children() do
    print_node(child, indent + 1)
  end
end

print("=== Full parse tree ===")
print_node(root)

-- Now check what the injections query finds
print("\n=== Checking injection queries ===")
local query_str = [[
((comment) @comment
 .
 (expression_statement
   (string) @string))
]]

-- Also test the gsub injection approach
print("\n=== Testing gsub injection query ===")
local gsub_query_str = [[
((comment) @injection.language
 .
 (expression_statement
   (string (string_content) @injection.content))
 (#gsub! @injection.language "^# ?" ""))
]]

local ok2, query = pcall(vim.treesitter.query.parse, "python", query_str)
if not ok2 then
  print("Query parse error: " .. tostring(query))
else
  print("Query OK, running matches...")
  for pattern, match, metadata in query:iter_matches(root, 0) do
    for id, nodes in pairs(match) do
      local name = query.captures[id]
      -- nodes may be a single node or a list
      local node_list = type(nodes) == "table" and nodes or {nodes}
      for _, node in ipairs(node_list) do
        if node and node.range then
          local srow, scol, erow, ecol = node:range()
          local text = vim.treesitter.get_node_text(node, 0)
          if #text > 80 then text = text:sub(1, 80) .. "..." end
          print(string.format("  capture[%s] (%d,%d)-(%d,%d): %s", name, srow, scol, erow, ecol, vim.inspect(text)))
        end
      end
    end
  end
end

local ok3, q2 = pcall(vim.treesitter.query.parse, "python", gsub_query_str)
if not ok3 then
  print("gsub query parse error: " .. tostring(q2))
else
  print("gsub query OK, running matches...")
  for pattern, match, metadata in q2:iter_matches(root, 0) do
    for id, nodes in pairs(match) do
      local name = q2.captures[id]
      local node_list = type(nodes) == "table" and nodes or {nodes}
      for _, node in ipairs(node_list) do
        if node and node.range then
          local srow, scol, erow, ecol = node:range()
          local meta_text = metadata[id] and metadata[id].text
          local raw_text = vim.treesitter.get_node_text(node, 0)
          if #raw_text > 60 then raw_text = raw_text:sub(1, 60) .. "..." end
          print(string.format("  capture[%s] (%d,%d)-(%d,%d): raw=%s gsub_text=%s",
            name, srow, scol, erow, ecol, vim.inspect(raw_text), vim.inspect(meta_text)))
        end
      end
    end
  end
end

vim.cmd("qa!")
