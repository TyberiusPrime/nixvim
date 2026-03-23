-- Check if toml/sql parsers are findable
print("=== Parser availability ===")
local function check(lang)
  local files = vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false)
  local has = vim._ts_has_language(lang)
  print(string.format("  %s: ts_has=%s, rtp_files=%s", lang, tostring(has), vim.inspect(files)))
end

check("toml")
check("sql")
check("python")
check("lua")
check("comment")

print("\n=== Trying to load toml parser ===")
local ok, err = pcall(vim.treesitter.language.require_language, "toml")
print("  toml load: " .. tostring(ok) .. " " .. tostring(err))

-- Check parser_install_dir
local data_dir = vim.fn.stdpath("data")
print("\n=== data dir: " .. data_dir)
local site_parsers = vim.fn.globpath(vim.o.runtimepath, "parser/toml.so", false, true)
print("=== toml.so in rtp: " .. vim.inspect(site_parsers))

vim.cmd("qa!")
