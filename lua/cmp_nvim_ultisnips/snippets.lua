local util = require("vim.lsp.util")

local M = {}

-- Caches all retrieved snippets information per filetype
local snippets_for_ft = {}

function M.load_snippets(expandable_only)
  if expandable_only then
    -- Do not cache snippets since the set of expandable
    -- snippets can change on every keystroke.
    return vim.fn["cmp_nvim_ultisnips#get_current_snippets"](true)
  end
  local ft = vim.bo.filetype
  local snippets = snippets_for_ft[ft]
  if not snippets then
    snippets = vim.fn["cmp_nvim_ultisnips#get_current_snippets"](false)
    snippets_for_ft[ft] = snippets
  end
  return snippets
end

function M.clear_caches()
  snippets_for_ft = {}
end

function M.format_snippet_value(value)
  local ft = vim.bo.filetype
  -- turn \\n into \n to get "real" whitespace
  local unescaped_value = value:gsub("\\([ntrab])", {
    n = "\n",
    t = "\t",
    r = "\r",
    a = "\a",
    b = "\b",
  })
  local snippet_docs = string.format("```%s\n%s\n```", ft, unescaped_value)
  local lines = util.convert_input_to_markdown_lines(snippet_docs)
  return table.concat(lines, "\n")
end

-- Returns the documentation string shown by cmp
function M.documentation(snippet)
  local formatted_value = M.format_snippet_value(snippet.value)
  if snippet.description == "" then
    return formatted_value
  end
  -- Remove surrounding quotes and italicize
  local description = snippet.description
  if description:match('".*"') then
    description = description:sub(2, -2)
  end
  return string.format("*%s*\n\n%s", description, formatted_value)
end

return M
