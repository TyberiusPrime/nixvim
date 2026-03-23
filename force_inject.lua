-- Force full injection parse and inspect result
local filename = vim.fn.argv(0)
if filename == "" then filename = "test.py" end

vim.cmd("edit " .. filename)

-- Start the highlighter (this triggers injection parsing)
local ok = pcall(vim.treesitter.start, 0, "python")

local parser = vim.treesitter.get_parser(0, "python")

-- Force full parse with all injections
local function force_full_parse(p)
  p:parse({ 0, -1 })
  p:for_each_child(function(child, lang)
    force_full_parse(child)
  end)
end

force_full_parse(parser)

-- Manually inspect injections via the private API
print("=== LanguageTree children ===")
local function print_tree(p, lang, depth)
  depth = depth or 0
  local prefix = string.rep("  ", depth)
  local regions = p:included_regions()
  local range_str = ""
  for _, region in ipairs(regions) do
    for _, r in ipairs(region) do
      range_str = range_str .. string.format("(%d,%d)-(%d,%d) ", r[1], r[2], r[4], r[5])
    end
  end
  print(prefix .. lang .. ": " .. (range_str ~= "" and range_str or "(no regions)"))
  p:for_each_child(function(child_p, child_lang)
    print_tree(child_p, child_lang, depth + 1)
  end)
end

print_tree(parser, "python")

-- Also check what TSHighlighter would give us
print("\n=== Captures at toml block positions ===")
-- test.py after edit:
-- 0: import re
-- 1: (empty)
-- 2: # toml
-- 3: """
-- 4: [test]
-- 5:    anton = 12
-- 6: """

-- Force highlighter to process the buffer
local highlighter = vim.treesitter.highlighter.new(parser)
-- give it a tick to process
highlighter:on_buf_highlighter_detach(0)
highlighter = vim.treesitter.highlighter.new(parser)

local captures4 = vim.treesitter.get_captures_at_pos(0, 4, 1)
print("  row=4 col=1 ([test]):")
for _, cap in ipairs(captures4) do
  print("    " .. cap.capture .. " (" .. cap.lang .. ")")
end

local captures5 = vim.treesitter.get_captures_at_pos(0, 5, 4)
print("  row=5 col=4 (anton):")
for _, cap in ipairs(captures5) do
  print("    " .. cap.capture .. " (" .. cap.lang .. ")")
end

vim.cmd("qa!")
