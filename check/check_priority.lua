-- Check highlight priority for captures at toml positions
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)
vim.bo.filetype = "python"

local parser = vim.treesitter.get_parser(0, "python")
parser:parse({ 0, -1 })
for _, child in pairs(parser:children()) do
  child:parse(true)
end

-- Check actual extmarks on the buffer to see what wins
-- The treesitter highlighter uses extmarks with priorities
print("=== Extmarks at row 4 (the [test] line) ===")
local ns_ids = vim.api.nvim_get_namespaces()
print("Namespaces: " .. vim.inspect(vim.tbl_keys(ns_ids)))

for name, nsid in pairs(ns_ids) do
  local marks = vim.api.nvim_buf_get_extmarks(0, nsid, {4, 0}, {4, -1}, { details = true })
  if #marks > 0 then
    print(string.format("  ns=%s (%d marks):", name, #marks))
    for _, mark in ipairs(marks) do
      local id, row, col, details = mark[1], mark[2], mark[3], mark[4]
      print(string.format("    col=%d hl_group=%s priority=%s",
        col, tostring(details.hl_group), tostring(details.priority)))
    end
  end
end

-- Also check what color @property.toml and @string.documentation.python actually are
print("\n=== Highlight group colors ===")
local function check_hl(group)
  local id = vim.fn.hlID(group)
  if id == 0 then
    -- try without language suffix
    print(string.format("  %s: NOT DEFINED", group))
    return
  end
  local info = vim.fn.hlget(group, true)  -- resolve links
  if info and #info > 0 then
    print(string.format("  %s: fg=%s bg=%s", group,
      tostring(info[1].fg or "nil"), tostring(info[1].bg or "nil")))
  else
    print(string.format("  %s: id=%d (no color info)", group, id))
  end
end

check_hl("@property.toml")
check_hl("@property")
check_hl("@string.documentation.python")
check_hl("@string.documentation")
check_hl("@string")

vim.cmd("qa!")
