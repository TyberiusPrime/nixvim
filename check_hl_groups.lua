-- Check what highlight groups are actually active
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)
vim.bo.filetype = "python"

local parser = vim.treesitter.get_parser(0, "python")
parser:parse({ 0, -1 })
-- Force child parsers
for _, child in pairs(parser:children()) do
  child:parse(true)
end

-- Check captures with priority info
print("=== Effective highlight at each position ===")
-- test.py:
-- row=2: # toml  (comment)
-- row=3: """     (string start)
-- row=4: [test]  (toml content)
-- row=5:    anton = 12  (toml content)
-- row=6: """     (string end)

local rows = {
  {2, 0, "# toml"},
  {3, 0, '"""  start'},
  {4, 0, "[test] bracket"},
  {4, 1, "[test] 't'"},
  {5, 3, "anton"},
  {5, 11, "12"},
  {6, 0, '"""  end'},
}

for _, r in ipairs(rows) do
  local row, col, label = r[1], r[2], r[3]
  local caps = vim.treesitter.get_captures_at_pos(0, row, col)
  -- Sort by priority (higher priority last = wins)
  local info = {}
  for _, c in ipairs(caps) do
    local hl_group = "@" .. c.capture .. (c.lang and ("." .. c.lang) or "")
    -- Check if the actual hl group exists
    local resolved = vim.fn.hlID(hl_group)
    local actual_hl = resolved > 0 and hl_group or ("@" .. c.capture)
    table.insert(info, string.format("%s->%s(%s)", c.capture, actual_hl, c.lang))
  end
  print(string.format("  row=%d %-20s: %s", row, label, table.concat(info, " | ")))
end

vim.cmd("qa!")
