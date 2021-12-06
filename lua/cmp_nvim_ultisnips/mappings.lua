local cmp = require("cmp")

local M = {}

local t = function(keys, mode)
  print(mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', true)
end

-- The <Plug> mappings are defined in autoload/cmp_nvim_ultisnips.vim.

function M.expand_or_jump_forwards(fallback)
  if cmp.get_selected_entry() == nil and vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
    -- vim.fn.feedkeys(string.format("%c%c%ccmpu-jump-forwards", 0x80, 253, 83))
    -- vim.fn.feedkeys(string.format("%c%c%ccmpu-jump-forwards", 0x80, 253, 83))
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>cmpu-jump-forwards", true, false, true), "")
  elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
    -- vim.cmd('\\<Plug>cmpu-jump-backwards')
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
