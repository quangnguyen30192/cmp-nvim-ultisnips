local util = require('vim.lsp.util')
local parser = require('cmp_nvim_ultisnips.parser')

local snippet_info_for_file = {}

local function parse_snippets(snippets_file_path)
  local cur_info = snippet_info_for_file[snippets_file_path]
  if cur_info ~= nil then
    return cur_info
  end
  snippet_info_for_file[snippets_file_path] = {}
  cur_info = {}
  local content = vim.fn.readfile(snippets_file_path)
  local found_snippet_header = false

  for _, line in ipairs(content) do
    if not found_snippet_header then
      local stripped_header = line:match('^%s*snippet%s+(.-)%s*$')
      -- found possible snippet header
      if stripped_header ~= nil then
        local header_info = parser.parse_snippet_header(stripped_header)
        if not vim.tbl_isempty(header_info) then
          cur_info = header_info
          cur_info.content = {}
          found_snippet_header = true
        end
      end
    elseif found_snippet_header and line:match('^endsnippet') ~= nil then
      table.insert(snippet_info_for_file[snippets_file_path], cur_info)
      found_snippet_header = false
    elseif found_snippet_header then
      table.insert(cur_info.content, line)
    end
  end
  return snippet_info_for_file[snippets_file_path]
end

-- stores all parsed snippet information for a particular file type
local snippet_info_for_ft = {}

local M = {}

function M.load_snippet_info()
  local ft = vim.bo.filetype
  local snippet_info = snippet_info_for_ft[ft]
  if snippet_info == nil then
    snippet_info = {}
    vim.F.npcall(vim.call, 'UltiSnips#SnippetsInCurrentScope', 1)

    local filepaths_set = {}
    for _, info in pairs(vim.g.current_ulti_dict_info) do
      local filepath = string.gsub(info.location, '.snippets:%d*', '.snippets')
      filepaths_set[filepath] = true
    end

    for filepath, _ in pairs(filepaths_set) do
      local result = parse_snippets(filepath)
      snippet_info = vim.tbl_deep_extend('force', snippet_info, result)
    end
  end
  return snippet_info
end

local function format_snippet_content(content)
  local snippet_content = {}

  table.insert(snippet_content, '```' .. vim.bo.filetype)
  for _, line in ipairs(content) do
    table.insert(snippet_content, line)
  end
  table.insert(snippet_content, '```')

  local snippet_docs = util.convert_input_to_markdown_lines(snippet_content)
  return table.concat(snippet_docs, '\n')
end

-- returns the documentation string that will be shown by cmp
function M.documentation(snippet_info)
  local description = ''
  if snippet_info.description then
    -- italicize description
    description = '*' .. snippet_info.description ..  '*'
  end
  local header = description .. '\n\n'
  return header .. format_snippet_content(snippet_info.content)
end

return M
