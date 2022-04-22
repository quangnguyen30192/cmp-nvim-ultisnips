local cmp = require("cmp")

local function t(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "m", true)
end

local function can_execute(arg)
  return vim.fn[arg]() == 1
end

-- The <Plug> mappings are defined in autoload/cmp_nvim_ultisnips.vim.

local actions = {
  expand = {
    condition = { can_execute, "UltiSnips#CanExpandSnippet" },
    command = { t, "<Plug>(cmpu-expand)" },
  },
  jump_forwards = {
    condition = { can_execute, "UltiSnips#CanJumpForwards" },
    command = { t, "<Plug>(cmpu-jump-forwards)" },
  },
  jump_backwards = {
    condition = { can_execute, "UltiSnips#CanJumpBackwards" },
    command = { t, "<Plug>(cmpu-jump-backwards)" },
  },
  select_next_item = {
    condition = { cmp.visible },
    command = { cmp.select_next_item },
  },
  select_prev_item = {
    condition = { cmp.visible },
    command = { cmp.select_prev_item },
  },
}

local M = {}

function M.compose(action_keys)
  return function(fallback)
    for _, action_key in ipairs(action_keys) do
      local action = actions[action_key]
      if not action then
        error(
          string.format(
            "[cmp_nvim_ultisnips.mappings] Invalid key %s was passed to compose function. "
              .. "Please check your mappings.\nAllowed values: 'expand', 'jump_forwards', "
              .. "'jump_backwards', 'select_next_item', 'select_prev_item'.",
            action_key
          )
        )
      end
      if action.condition[1](action.condition[2]) == true then
        action.command[1](action.command[2])
        return
      end
    end
    fallback()
  end
end

function M.expand_or_jump_forwards(fallback)
  M.compose { "expand", "jump_forwards", "select_next_item" }(fallback)
end

function M.jump_backwards(fallback)
  M.compose { "jump_backwards", "select_prev_item" }(fallback)
end

return M
