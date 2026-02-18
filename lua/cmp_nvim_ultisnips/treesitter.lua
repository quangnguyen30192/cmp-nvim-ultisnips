local M = {}

-- Check if nvim-treesitter is available
-- (there would be a lot of copied code without this dependency)
local ok_parsers, ts_parsers = pcall(require, "nvim-treesitter.parsers")
if not ok_parsers then
  ts_parsers = nil
end

local ok_utils, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
if not ok_utils then
  ts_utils = nil
end

function M.is_available()
  return ok_parsers and ok_utils
end

local function get_ft_at_cursor()
  local cur_node = ts_utils.get_node_at_cursor()
  if cur_node then
    local parser = ts_parsers.get_parser()
    local lang = parser:language_for_range({ cur_node:range() }):lang()
    if ts_parsers.list[lang] ~= nil then
      -- UltiSnips expects a filetype; if filetype is not specified for a parser,
      -- the filetype is the same as lang, so lang can be safely used
      return ts_parsers.list[lang].filetype or lang
    end
  end
  return nil
end

local cur_ft_at_cursor
function M.set_filetype()
  local new_ft = get_ft_at_cursor()
  if new_ft ~= nil and new_ft ~= cur_ft_at_cursor and new_ft ~= vim.bo.filetype then
    vim.fn["cmp_nvim_ultisnips#set_filetype"](new_ft)
    cur_ft_at_cursor = new_ft
  end
end

function M.reset_filetype()
  if cur_ft_at_cursor ~= nil then
    vim.fn["cmp_nvim_ultisnips#reset_filetype"]()
    cur_ft_at_cursor = nil
  end
end

return M
