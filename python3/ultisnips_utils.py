from UltiSnips import UltiSnips_Manager, vim_helper
import vim

# Retrieves additional snippet information that is not directly accessible
# using the UltiSnips API functions. Stores a list of dictionaries (one per
# snippet) with the keys "trigger", "description", "options" and "value"
# in the vim variable g:_cmpu_current_snippets.
#
# If 'expandable_only' is True, only expandable snippets are stored, otherwise
# all snippets for the current filetype are added.


def fetch_snippets(expandable_only):
    if expandable_only:
        before = vim_helper.buf.line_till_cursor
        snippets = UltiSnips_Manager._snips(before, True)
    else:
        snippets = UltiSnips_Manager._snips("", True)

    vim.command('let g:_cmpu_current_snippets = []')
    for snippet in snippets:
        vim.command(
            "call add(g:_cmpu_current_snippets, {"
            "'trigger': pyxeval('str(snippet._trigger)'),"
            "'description': pyxeval('str(snippet._description)'),"
            "'options': pyxeval('str(snippet._opts)'),"
            "'value': pyxeval('str(snippet._value)'),"
            "})"
        )
