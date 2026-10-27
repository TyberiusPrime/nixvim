-- Test shebang injection - manual setup to avoid init.lua conflicts
local fname = "test_inject.py"
vim.cmd("noautocmd edit " .. fname)

-- Register the directive the same way python.nix does
vim.treesitter.query.add_directive("set-lang-from-shebang!", function(match, _, bufnr, pred, metadata)
  local node = match[pred[2]]
  if not node then return end
  local text = vim.treesitter.get_node_text(node, bufnr)
  local first_line = text:match("^%s*([^\n]+)")
  if not first_line then return end
  local lang =
    first_line:match("^#!.*/env%s+(%a[%w_%-]*)") or
    first_line:match("^#!.*/(%a[%w_%-]*)") or
    first_line:match("^#!(%a[%w_%-]*)")
  if lang then
    metadata["injection.language"] = lang:lower()
  end
end, { force = true, all = false })

-- Start treesitter manually
local ok, err = pcall(vim.treesitter.start, 0, "python")
if not ok then print("ERROR: " .. tostring(err)); vim.cmd("qa!"); return end

local parser = vim.treesitter.get_parser(0, "python")
local tree = parser:parse()[1]
local root = tree:root()

-- Run injection query
local q = vim.treesitter.query.get("python", "injections")
if not q then print("ERROR: no injection query"); vim.cmd("qa!"); return end

print("=== Injection query matches ===")
for pattern, match, metadata in q:iter_matches(root, 0) do
  local global_lang = metadata["injection.language"]
  local lang_meta, content_range
  for id, nodes in pairs(match) do
    local name = q.captures[id]
    local node_list = type(nodes) == "table" and nodes or {nodes}
    for _, node in ipairs(node_list) do
      if not node then goto cont end
      if name == "injection.language" then
        lang_meta = metadata[id] and metadata[id].text
      elseif name == "injection.content" then
        local sr, sc, er, ec = node:range()
        content_range = string.format("(%d,%d)-(%d,%d)", sr, sc, er, ec)
      end
      ::cont::
    end
  end
  local eff_lang = global_lang or lang_meta
  if eff_lang then
    print(string.format("  pattern=%d lang=%-8s source=%-20s content=%s",
      pattern, eff_lang,
      global_lang and "shebang-directive" or "gsub",
      content_range or "?"))
  end
end

-- Force children and report
parser:parse({0,-1})
for _, child in pairs(parser:children()) do child:parse(true) end

print("\n=== Active injection languages ===")
for lang, _ in pairs(parser:children()) do
  print("  " .. lang)
end

-- Key position checks
print("\n=== Captures at shebang block positions ===")
local function inj(row, col, label)
  local caps = vim.treesitter.get_captures_at_pos(0, row, col)
  local t = {}
  for _, c in ipairs(caps) do
    if c.lang ~= "python" then table.insert(t, c.capture.."("..c.lang..")") end
  end
  print(string.format("  row=%-2d %-25s: %s", row, label, #t > 0 and table.concat(t,"|") or "(python only)"))
end

-- Rows in test_inject.py (0-indexed after additions):
-- 0: import re
-- 2: # toml, 3-6: """..."""
-- 8: # sql,  9-11: """..."""
-- 13: """#!/usr/bin/env bash
-- 14: echo "hello world"
-- 15: ls -la
-- 16: """
-- 18: """#!toml
-- 19: [server]
-- 20: host = "localhost"
-- 21: port = 8080

inj(14, 2, 'echo (want bash)')
inj(15, 0, 'ls (want bash)')
inj(19, 1, '[server] (want toml)')
inj(20, 0, 'host (want toml)')
inj(21, 0, 'port (want toml)')

vim.cmd("qa!")
