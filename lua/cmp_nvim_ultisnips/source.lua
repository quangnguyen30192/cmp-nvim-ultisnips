local cmp = require("cmp")
local cmp_snippets = require("cmp_nvim_ultisnips.snippets")

local source = {}
function source.new(config)
  local self = setmetatable({}, { __index = source })
  self.config = config
  return self
end

function source:get_keyword_pattern()
  return "\\%([^[:alnum:][:blank:]]\\|\\w\\+\\)"
end

function source:get_debug_name()
  return "ultisnips"
end

function source:complete(_, callback)
  local items = {}
  -- Retrieve all snippets for now (including not expandable ones)
  local snippets = cmp_snippets.load_snippets(false)
  for _, snippet in pairs(snippets) do
    -- Skip regex and expression snippets for now
    if not snippet.options:match("[re]") then
      local item = {
        word = snippet.trigger,
        label = snippet.trigger,
        kind = cmp.lsp.CompletionItemKind.Snippet,
        snippet = snippet,
      }
      table.insert(items, item)
    end
  end
  callback(items)
end

function source.resolve(self, completion_item, callback)
  local doc_string = self.config.documentation(completion_item.snippet)
  if doc_string ~= nil then
    completion_item.documentation = {
      kind = cmp.lsp.MarkupKind.Markdown,
      value = doc_string,
    }
  end
  callback(completion_item)
end

function source:execute(completion_item, callback)
  vim.call("UltiSnips#ExpandSnippet")
  callback(completion_item)
end

function source:is_available()
  -- if UltiSnips is installed then this variable should be defined
  return vim.g.UltiSnipsExpandTrigger ~= nil
end

function source:clear_snippet_caches()
  cmp_snippets.clear_caches()
end

return source
