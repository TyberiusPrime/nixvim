-- Live test using timer - waits for treesitter to process fully
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)
-- Treesitter will auto-start via ftplugin

vim.fn.timer_start(300, function()
  local parser = vim.treesitter.get_parser(0)
  if not parser then
    print("ERROR: no parser")
    vim.cmd("qa!")
    return
  end

  -- Check children
  local children = parser:children()
  local child_langs = {}
  for lang, _ in pairs(children) do
    table.insert(child_langs, lang)
  end
  print("Active injection languages: " .. table.concat(child_langs, ", "))

  -- Check captures at key positions
  local function cap_str(row, col)
    local caps = vim.treesitter.get_captures_at_pos(0, row, col)
    local t = {}
    for _, c in ipairs(caps) do
      table.insert(t, c.capture .. "(" .. c.lang .. ")")
    end
    return #t > 0 and table.concat(t, " | ") or "(none)"
  end

  print("row=2 # toml:       " .. cap_str(2, 2))
  print("row=4 [test] [  :   " .. cap_str(4, 0))
  print("row=4 [test] t  :   " .. cap_str(4, 1))
  print("row=5 anton     :   " .. cap_str(5, 3))
  print("row=5 12        :   " .. cap_str(5, 11))

  -- Check actual extmarks from treesitter highlighter ns
  local ns_ids = vim.api.nvim_get_namespaces()
  local ts_ns = ns_ids["nvim.treesitter.highlighter"]
  if ts_ns then
    local marks = vim.api.nvim_buf_get_extmarks(0, ts_ns, {4, 0}, {4, -1}, { details = true })
    print("\nExtmarks at row 4 (treesitter highlighter):")
    for _, m in ipairs(marks) do
      print(string.format("  col=%d-%s hl=%s priority=%s", m[3],
        tostring(m[4].end_col or "?"), tostring(m[4].hl_group), tostring(m[4].priority)))
    end
    if #marks == 0 then print("  (none - highlighter not running?)") end
  else
    print("\nno treesitter highlighter namespace yet")
  end

  vim.cmd("qa!")
end)
