-- Use synstack approach to check what's winning at the toml positions
-- Test the actual combined highlight output using syn-attribute
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)
vim.bo.filetype = "python"

-- Actually trigger the full treesitter highlighting
vim.cmd("TSBufEnable highlight")

-- Force parse
local parser = vim.treesitter.get_parser(0, "python")
parser:parse({ 0, -1 })
for _, child in pairs(parser:children()) do
  child:parse(true)
end

-- Use synID which respects TS highlighting
print("=== synID approach (what actually renders) ===")
local function check_synid(row, col, label)
  -- synID uses 1-indexed
  local syn_id = vim.fn.synID(row + 1, col + 1, true)
  local trans_id = vim.fn.synIDtrans(syn_id)
  local syn_name = vim.fn.synIDattr(syn_id, "name")
  local trans_name = vim.fn.synIDattr(trans_id, "name")
  local fg = vim.fn.synIDattr(trans_id, "fg#")
  print(string.format("  row=%d col=%d %-20s: syn=%s trans=%s fg=%s",
    row, col, label, syn_name, trans_name, fg ~= "" and fg or "none"))
end

check_synid(2, 2, "# toml comment")
check_synid(3, 0, '""" start')
check_synid(4, 0, "[test] [")
check_synid(4, 1, "[test] t")
check_synid(5, 3, "anton")
check_synid(5, 11, "12")
check_synid(6, 0, '""" end')
check_synid(0, 0, "import")
check_synid(0, 7, "re")

vim.cmd("qa!")
