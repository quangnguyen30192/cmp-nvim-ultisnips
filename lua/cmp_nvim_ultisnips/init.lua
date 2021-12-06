local cmpu_source = require("cmp_nvim_ultisnips.source")
local cmpu_config = require("cmp_nvim_ultisnips.config")

local M = {}

local user_config = cmpu_config.default_config
function M.setup(config)
  user_config = cmpu_config.get_user_config(config)
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
