local cmpu_source = require("cmp_nvim_ultisnips.source")
local cmpu_snippets = require("cmp_nvim_ultisnips.snippets")

local M = {}

local default_config = {
  show_snippets = "expandable",
  documentation = cmpu_snippets.documentation,
}

local user_config = default_config
function M.setup(config)
  user_config = vim.tbl_deep_extend("force", default_config, config)
  vim.validate({
    show_snippets = {
      user_config.show_snippets,
      function(arg)
        return arg == "expandable" or arg == "all"
      end,
      "either 'expandable' or 'all'",
    },
    documentation = { user_config.documentation, "function" },
  })
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
