local M = {}

local ft_snippets_cache = {}

function M.load()
  if ft_snippets_cache[vim.bo.filetype] == nil then
    vim.F.npcall(vim.call, 'UltiSnips#SnippetsInCurrentScope', 1)
    ft_snippets_cache[vim.bo.filetype] = vim.g.current_ulti_dict_info
  end

  return ft_snippets_cache[vim.bo.filetype]
end

function M.get_snippet_preview(user_data)
  local filepath = string.gsub(user_data.location, '.snippets:%d*', '.snippets')
  local _, _, linenr = string.find(user_data.location, ':(%d+)')
  local content = vim.fn.readfile(filepath)

  local snippet = {}
  local count = 0

  table.insert(snippet, '```' .. vim.bo.filetype)
  for i, line in pairs(content) do
    if i > linenr - 1 then
      local is_snippet_header = line:find('^snippet%s[^%s]') ~= nil
      count = count + 1
      if line:find('^endsnippet') ~= nil or is_snippet_header and count ~= 1 then
        break
      end
      if not is_snippet_header then
        table.insert(snippet, line)
      end
    end
  end
  table.insert(snippet, '```')

  return snippet
end

return M
