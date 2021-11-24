local cmp = require('cmp')
local cmp_snippets = require('cmp_nvim_ultisnips.snippets')

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
  local info = cmp_snippets.load_snippet_info()
  for _, snippet_info in pairs(info) do
    -- skip regex and expression snippets for now
    if not snippet_info.options or not snippet_info.options:match('[re]') then
      local item = {
        word =  snippet_info.tab_trigger,
        label = snippet_info.tab_trigger,
        kind = cmp.lsp.CompletionItemKind.Snippet,
        userdata = snippet_info,
      }
      table.insert(items, item)
    end
  end
  callback(items)
end

function source:resolve(completion_item, callback)
  completion_item.documentation = {
    kind = cmp.lsp.MarkupKind.Markdown,
    value = cmp_snippets.documentation(completion_item.userdata)
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
