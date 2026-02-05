local cmpu_snippets = require("cmp_nvim_ultisnips.snippets")

local M = {}

M.default_config = {
  show_snippets = "expandable",
  documentation = cmpu_snippets.documentation,
  filetype_source = "treesitter",
}

local function is_valid_show_snippets(arg)
  return arg == "expandable" or arg == "all"
end

local function is_valid_filetype_source(arg)
  return arg == "treesitter" or arg == "ultisnips_default"
end

function M.get_user_config(config)
  local user_config = vim.tbl_deep_extend("force", M.default_config, config)
  vim.validate("show_snippets", user_config.show_snippets, is_valid_show_snippets, "either 'expandable' or 'all'")
  vim.validate("documentation", user_config.documentation, "function")
  vim.validate(
    "filetype_source",
    user_config.filetype_source,
    is_valid_filetype_source,
    "either 'treesitter' or 'ultisnips_default'"
  )
  return user_config
end

return M
