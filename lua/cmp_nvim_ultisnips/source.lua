local cmp = require("cmp")
local cmpu_snippets = require("cmp_nvim_ultisnips.snippets")

local source = {}
function source.new(config)
  local self = setmetatable({}, { __index = source })
  self.config = config
  self.expandable_only = config.show_snippets == "expandable"
  if config.filetype_source == "treesitter" then
    if require("cmp_nvim_ultisnips.treesitter").is_available() then
      vim.fn["cmp_nvim_ultisnips#setup_treesitter_autocmds"]()
    end
  end
  return self
end

function source:get_keyword_pattern()
  return "\\%([^[:alnum:][:blank:]]\\|\\w\\+\\)"
end

function source:get_debug_name()
  return "ultisnips"
end

function source.complete(self, _, callback)
  local items = {}
  local snippets = cmpu_snippets.load_snippets(self.expandable_only)

  for _, snippet in pairs(snippets) do
    local is_regex_snippet = snippet.options:match("r")
    local item = {
      insertText = (is_regex_snippet and snippet.matched) or snippet.trigger,
      label = snippet.trigger,
      kind = cmp.lsp.CompletionItemKind.Snippet,
      snippet = snippet,
    }
    table.insert(items, item)
  end
  callback {
    items = items,
    -- If true, cmp will update the items on every keystroke.
    -- When self.expandable_only == false, the snippets are cached so no need to update.
    isIncomplete = self.expandable_only,
  }
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
  -- If UltiSnips is installed then this variable should be defined
  return vim.g.UltiSnipsExpandTrigger ~= nil
end

function source:clear_snippet_caches()
  cmpu_snippets.clear_caches()
end

return source
