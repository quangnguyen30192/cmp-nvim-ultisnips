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
if expandable_only == "True":
    before = vim_helper.buf.line_till_cursor
    snippets = UltiSnips_Manager._snips(before, True)
else:
    snippets = UltiSnips_Manager._snips("", True)

snippets_info = []
vim.command('let g:_cmpu_current_snippets = []')
for snippet in snippets:
    vim.command(
      "call add(g:_cmpu_current_snippets, {"\
        "'trigger': pyxeval('str(snippet._trigger)'),"\
        "'description': pyxeval('str(snippet._description)'),"\
        "'options': pyxeval('str(snippet._opts)'),"\
        "'value': pyxeval('str(snippet._value)'),"\
      "})"
    )
EOF
return g:_cmpu_current_snippets
endfunction
