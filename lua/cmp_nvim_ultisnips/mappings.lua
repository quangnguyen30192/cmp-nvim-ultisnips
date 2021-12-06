local cmp = require("cmp")

local M = {}

local t = function(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "m", true)
end

-- The <Plug> mappings are defined in autoload/cmp_nvim_ultisnips.vim.

function M.expand_or_jump_forwards(fallback)
  if cmp.get_selected_entry() == nil and vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
    t("<Plug>(cmpu-expand)")
  elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
    t("<Plug>(cmpu-jump-forwards)")
  elseif cmp.visible() then
    cmp.select_next_item()
  else
    fallback()
  end
end

function M.jump_backwards(fallback)
  if vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
    t("<Plug>(cmpu-jump-backwards)")
  elseif cmp.visible() then
    cmp.select_prev_item()
  else
    fallback()
  end
end

return M
