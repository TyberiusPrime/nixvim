-- Verify shebang injection using the same pattern as force_inject6.lua
local fname = arg and arg[1] or "test_inject.py"
vim.cmd("edit " .. fname)

local parser = vim.treesitter.get_parser(0, "python")
parser:parse({0,-1})
for _, child in pairs(parser:children()) do child:parse(true) end

print("=== Active injection languages ===")
local children = parser:children()
local langs = {}
for lang, _ in pairs(children) do table.insert(langs, lang) end
table.sort(langs)
for _, lang in ipairs(langs) do print("  " .. lang) end

print("\n=== Injection query matches ===")
local tree = parser:parse()[1]
local root = tree:root()
local q = vim.treesitter.query.get("python", "injections")
if not q then print("ERROR: no injection query"); vim.cmd("qa!"); return end

for pattern, match, metadata in q:iter_matches(root, 0) do
  local global_lang = metadata["injection.language"]
  local content_range
  for id, nodes in pairs(match) do
    local name = q.captures[id]
    local node_list = type(nodes) == "table" and nodes or {nodes}
    for _, node in ipairs(node_list) do
      if not node then goto cont end
      if name == "injection.content" then
        local sr, sc, er, ec = node:range()
        content_range = string.format("(%d,%d)-(%d,%d)", sr, sc, er, ec)
      end
      ::cont::
    end
  end
  if global_lang then
    print(string.format("  pattern=%d lang=%-8s content=%s", pattern, global_lang, content_range or "?"))
  end
end

print("\n=== Captures at shebang positions ===")
-- test_inject.py (0-indexed):
-- 13: """#!/usr/bin/env bash
-- 14: echo "hello world"
-- 15: ls -la
-- 16: """
-- 18: """#!toml
-- 19: [server]
-- 20: host = "localhost"
-- 21: port = 8080
-- 22: """
local function inj(row, col, label)
  local caps = vim.treesitter.get_captures_at_pos(0, row, col)
  local t = {}
  for _, c in ipairs(caps) do
    if c.lang ~= "python" then table.insert(t, c.capture .. "(" .. c.lang .. ")") end
  end
  print(string.format("  row=%-2d %-25s: %s", row, label, #t > 0 and table.concat(t, "|") or "(python only)"))
end

inj(14, 2, "echo (want bash)")
inj(15, 0, "ls (want bash)")
inj(19, 1, "[server] (want toml)")
inj(20, 0, "host (want toml)")
inj(21, 0, "port (want toml)")

vim.cmd("qa!")
