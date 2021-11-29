require('cmp').register_source('ultisnips', require('cmp_nvim_ultisnips').create_source())

vim.cmd[[
command! -nargs=0 CmpUltisnipsReloadSnippets lua require('cmp_nvim_ultisnips').reload_snippets()
]]
