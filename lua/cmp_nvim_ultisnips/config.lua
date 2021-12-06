local cmpu_snippets = require("cmp_nvim_ultisnips.snippets")

local M = {}

M.default_config = {
  show_snippets = "expandable",
  documentation = cmpu_snippets.documentation,
}

function M.get_user_config(config)
  local user_config = vim.tbl_deep_extend("force", M.default_config, config)
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
  return user_config
end

return M
