local cmp = require('cmp')
local util = require('vim.lsp.util')
local cmp_snippets = require("cmp_nvim_ultisnips.snippets")

local source = {}
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

  local snippets = cmp_snippets.load()
  for key, value in pairs(snippets) do
    local item = {
      label = key,
      insertText = value.insertText,
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

  local documentation = util.convert_input_to_markdown_lines(cmp_snippets.get_snippet_preview(user_data))
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
  -- if UltiSnips is installed then this variable should be defined
  return vim.g.UltiSnipsExpandTrigger ~= nil
end

return source
