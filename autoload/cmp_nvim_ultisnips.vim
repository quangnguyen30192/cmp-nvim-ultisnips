" Retrieves additional snippet information that is not directly accessible
" using the UltiSnips API functions. Returns a list of tables (one table
" per snippet) with the keys "trigger", "description" and "options".
"
" If 'expandable_only' is 1, only expandable snippets are returned, otherwise all
" snippets for the current filetype are returned.
function! cmp_nvim_ultisnips#get_current_snippets(expandable_only)
pythonx << EOF
import vim
from UltiSnips import vim_helper

expandable_only = vim.eval("a:expandable_only")
if expandable_only == 1:
    before = vim_helper.buf.line_till_cursor
    snippets = UltiSnips_Manager._snips(before, True)
else:
    snippets = UltiSnips_Manager._snips("", True)

snippets_info = []
vim.command('let g:_cmpu_current_snippets = []')
for snippet in snippets:
    # Use Lua because it was the only way to achieve correct string escaping.
    # Without this, '" in a trigger string did cause problems when converting
    # to a vim dict. If you have a better way to do this, please file a PR.
    # TODO: replace with vim.s (requires Nvim 0.6)
    vim.command("lua vim.b._cmpu_snippet_trigger = [[%s]]" % str(snippet._trigger))
    vim.command("lua vim.b._cmpu_snippet_description = [[%s]]" % str(snippet._description))
    vim.command("lua vim.b._cmpu_snippet_options = [[%s]]" % str(snippet._opts))
    vim.command("lua vim.b._cmpu_snippet_value = [[%s]]" % str(snippet._value))
    vim.command(
      "call add(g:_cmpu_current_snippets, {"\
        "'trigger': b:_cmpu_snippet_trigger,"\
        "'description': b:_cmpu_snippet_description,"\
        "'options': b:_cmpu_snippet_options,"\
        "'value': b:_cmpu_snippet_value,"\
      "})"
    )
EOF
return g:_cmpu_current_snippets
endfunction
