local cmpu_source = require("cmp_nvim_ultisnips.source")
local cmpu_config = require("cmp_nvim_ultisnips.config")

local M = {}

local user_config = cmpu_config.default_config
function M.setup(config)
  user_config = cmpu_config.get_user_config(config)
end

local source
function M.create_source()
  -- Source UltiSnips file in case it is not loaded yet (GH issue #49)
  vim.cmd("runtime! plugin/UltiSnips.vim")
  -- This is necessary because we want to be able to define our own
  -- select mode mappings used to jump between snippet tabstops (GH issue #5)
  vim.g.UltiSnipsRemoveSelectModeMappings = 0
  source = cmpu_source.new(user_config)
  return source
end

function M.reload_snippets()
  source.clear_snippet_caches()
end

return M
