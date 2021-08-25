local cmp = require('cmp')
local util = require('vim.lsp.util')

local source = {}

local function get_snippet_preview(user_data)
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

source.new = function()
  return setmetatable({}, { __index = source })
end

source.get_keyword_pattern = function()
  return '\\%([^[:alnum:][:blank:]]\\|\\w\\+\\)'
end

function source:get_debug_name()
  return 'ultisnips'
end

function source:complete(_, callback)
  local items = {}

  local received_snippets = vim.F.npcall(vim.call, 'UltiSnips#SnippetsInCurrentScope', 1) or {}
  if vim.tbl_isempty(received_snippets) then
    callback(items)
  end

  local snippets_list = vim.g.current_ulti_dict_info

  for key, value in pairs(snippets_list) do
    local item = {
      word =  key,
      label =  key,
      user_data = value,
      kind = cmp.lsp.CompletionItemKind.Snippet,
    }
    items[#items+1] = item
  end

  callback(items)
end

function source:resolve(completion_item, callback)
  local user_data = completion_item.user_data
  if user_data == nil or user_data == '' then
    callback(completion_item)
  end

  local documentation = util.convert_input_to_markdown_lines(get_snippet_preview(user_data))
  completion_item.documentation = {
    kind = cmp.lsp.MarkupKind.Markdown,
    value = table.concat(documentation, '\n')
  }

  callback(completion_item)
end

function source:execute(completion_item, callback)
  vim.call('UltiSnips#ExpandSnippet')
  callback(completion_item)
end

function source:is_available()
  return true
end

return source
