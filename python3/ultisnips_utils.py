from UltiSnips import UltiSnips_Manager, vim_helper

# Retrieves additional snippet information that is not directly accessible
# using the UltiSnips API functions. Stores a list of dictionaries (one per
# snippet) with the keys "trigger", "description", "options" and "value"
# in the vim variable g:_cmpu_current_snippets.
#
# If 'expandable_only' is True, only expandable snippets are stored, otherwise
# all snippets for the current filetype are added.


def fetch_current_snippets(expandable_only):
    if expandable_only:
        snippets = UltiSnips_Manager._snips(before_line, True)
    else:
        snippets = UltiSnips_Manager._snips("", True)

    current_snippet_infos = []
    for snippet in snippets:
        snippet_info = {
            "trigger": snippet._trigger,
            "description": snippet._description,
            "options": snippet._opts,
            "value": snippet._value,
        }
        current_snippet_infos.append(snippet_info)
    return current_snippet_infos


def set_filetype(ft):
    class CustomVimBuffer(vim_helper.VimBuffer):
        @property
        def filetypes(self):
            return [ft]

    vim_helper._orig_buf = vim_helper.buf
    vim_helper.buf = CustomVimBuffer()


def reset_filetype():
    vim_helper.buf = vim_helper._orig_buf
