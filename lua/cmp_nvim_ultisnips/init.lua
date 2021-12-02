local cmpu_source = require("cmp_nvim_ultisnips.source")
local cmpu_snippets = require("cmp_nvim_ultisnips.snippets")

local M = {}

local default_config = {
  documentation = cmpu_snippets.documentation,
}

local user_config = default_config
function M.setup(config)
  user_config = vim.tbl_deep_extend("force", default_config, config)
end

local source
function M.create_source()
  source = cmpu_source.new(user_config)
  return source
end

function M.reload_snippets()
  source.clear_snippet_caches()
end

return M
