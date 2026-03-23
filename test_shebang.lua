-- Test shebang injection on test_inject.py
local fname = arg and arg[1] or "test_inject.py"
vim.cmd("edit " .. fname)
local parser = vim.treesitter.get_parser(0, "python")
local tree = parser:parse()[1]
local root = tree:root()

local q = vim.treesitter.query.get("python", "injections")
print("=== Injection matches ===")
for pattern, match, metadata in q:iter_matches(root, 0) do
  local lang_node, content_node
  local lang_text, lang_meta
  for id, nodes in pairs(match) do
    local name = q.captures[id]
    local node_list = type(nodes) == "table" and nodes or {nodes}
    for _, node in ipairs(node_list) do
      if not node then goto continue end
      if name == "injection.language" then
        lang_meta = metadata[id] and metadata[id].text
        lang_text = vim.treesitter.get_node_text(node, 0):sub(1, 20)
      elseif name == "injection.content" then
        content_node = node
      end
      ::continue::
    end
  end
  -- Check global metadata injection.language (set by set-lang-from-shebang!)
  local global_lang = metadata["injection.language"]
  if lang_meta or global_lang then
    local sr, sc, er, ec = content_node and content_node:range() or 0,0,0,0
    print(string.format("  pattern=%d lang=%s (from %s) range=(%d,%d)-(%d,%d)",
      pattern,
      global_lang or lang_meta,
      global_lang and "shebang-directive" or "gsub",
      sr, sc, er, ec))
  end
end

-- Force child parses and check captures
parser:parse({0,-1})
for _, child in pairs(parser:children()) do child:parse(true) end

print("\n=== Child languages ===")
for lang, _ in pairs(parser:children()) do
  print("  " .. lang)
end

print("\n=== Captures at shebang block positions ===")
-- test_inject.py rows (0-indexed):
-- 0: import re
-- 2: # toml
-- 3: """ ... 6: """
-- 8: # sql
-- 9: """ ... 11: """
-- 13: """#!/usr/bin/env bash   <- shebang block starts
-- 14: echo "hello world"
-- 15: ls -la
-- 16: """
-- 18: """#!toml
-- 19: [server]
-- 20: host = ...

local function show_injected(row, col, label)
  local caps = vim.treesitter.get_captures_at_pos(0, row, col)
  local inj = {}
  for _, c in ipairs(caps) do
    if c.lang ~= "python" then table.insert(inj, c.capture .. "(" .. c.lang .. ")") end
  end
  print(string.format("  row=%-2d %-30s: %s", row, label, #inj > 0 and table.concat(inj, " | ") or "(python only)"))
end

show_injected(14, 2, "echo (bash)")
show_injected(15, 0, "ls (bash)")
show_injected(19, 1, "[server] (toml)")
show_injected(20, 0, "host (toml)")

vim.cmd("qa!")
