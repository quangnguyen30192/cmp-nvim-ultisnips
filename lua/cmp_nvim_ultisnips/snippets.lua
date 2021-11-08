local M = {}

local ft_snippets_cache = {}

function M.load()
  if ft_snippets_cache[vim.bo.filetype] == nil then
    vim.F.npcall(vim.call, 'UltiSnips#SnippetsInCurrentScope', 1)
    local cur_dict_info = vim.g.current_ulti_dict_info
    ft_snippets_cache[vim.bo.filetype] = M.add_regex_snippets(cur_dict_info)
  end
  return ft_snippets_cache[vim.bo.filetype]
end

-- Parses and returns snippets that include the 'r' option (UltiSnips does not return them).
function M.add_regex_snippets(cur_dict_info)
    local new_dict_info = {}
    local visited_files = {}

    for _, snippet_info in pairs(cur_dict_info) do
      local snippet_path = string.gsub(snippet_info.location, ':%d*$', '')
      if visited_files[snippet_path] == nil then
        local content = vim.fn.readfile(snippet_path)
        for line_idx, line in ipairs(content) do
          -- skip non-regex snippets (specified by the snippet option r)
          -- since they have already been added by UltiSnips
          local _, _, trigger_word = string.find(line, '^snippet%s+"(.-)".*%s%w*r')
          if trigger_word then
            -- search for the last pair of quotes ("") to get the description
            local _, _, description = string.find(line, '".*%s"(.*)".*$')
            description = description or ''
            local location = string.format('%s:%d', snippet_path, line_idx + 1)

            new_dict_info[trigger_word] = {
              insertText = M.transform_trigger_word(trigger_word),
              description = description,
              location = location
            }
          end
        end
        visited_files[snippet_path] = true
      end
    end
    return vim.tbl_extend('keep', cur_dict_info, new_dict_info)
end

-- Transforms a regex trigger word into a string that will be inserted by cmp.
-- Currently only supports the '?' and '*' quantifiers within a tab trigger (everything else
-- will be inserted literally by cmp).
function M.transform_trigger_word(trigger_word)
  return string.gsub(trigger_word, '[%?%*]', '')
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
