local util = require("vim.lsp.util")

local M = {}

-- Caches all retrieved snippets information per filetype
local snippets_info_for_ft = {}

function M.load_snippets(expandable_only)
  local ft = vim.bo.filetype
  local snippets_info = snippets_info_for_ft[ft]
  if not snippets_info then
    local expandable = expandable_only and 1 or 0
    snippets_info = vim.fn["cmp_nvim_ultisnips#get_current_snippets"](expandable)
    snippets_info_for_ft[ft] = snippets_info
  end
  return snippets_info
end

function M.clear_caches()
  snippets_info_for_ft = {}
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
  local description = ""
  if snippet.description ~= "" then
    -- Italicize description
    description = "*" .. snippet.description .. "*"
  end
  local formatted_value = M.format_snippet_value(snippet.value)
  return string.format("%s\n\n%s", description, formatted_value)
end

return M
