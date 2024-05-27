# Retrieves additional snippet information that is not directly accessible
# using the UltiSnips API functions. Stores a list of dictionaries (one per
# snippet) with the keys "trigger", "description", "options" and "value"
# in the vim variable g:_cmpu_current_snippets.
#
# If 'expandable_only' is True, only expandable snippets are stored, otherwise
# all snippets for the current filetype are added.


def fetch_current_snippets(expandable_only):
    from UltiSnips import UltiSnips_Manager, vim_helper

    line_until_cursor = vim_helper.buf.line_till_cursor
    visual_content = UltiSnips_Manager._visual_content
    if expandable_only:
        snippets = UltiSnips_Manager._snips(line_until_cursor, True)
    else:
        snippets = UltiSnips_Manager._snips("", True)

    current_snippet_infos = []
    for snippet in snippets:
        is_context_snippet = snippet._context_code is not None
        is_regex_snippet = "r" in snippet._opts
        # If show_snippets == "all", the snippets are cached so ignore "dynamic" snippets.
        if not expandable_only and (is_context_snippet or is_regex_snippet):
            continue
        # For custom context snippets, always check if the context matches.
        if is_context_snippet and not snippet._context_match(
            visual_content, line_until_cursor
        ):
            continue

        snippet_info = {
            "trigger": snippet._trigger,
            "description": snippet._description,
            "options": snippet._opts,
            "value": snippet._value,
            "matched": snippet._matched,
        }
        current_snippet_infos.append(snippet_info)
    return current_snippet_infos


def set_filetype(ft):
    from UltiSnips import vim_helper

    class CustomVimBuffer(vim_helper.VimBuffer):
        @property
        def filetypes(self):
            return [ft]

    vim_helper._orig_buf = vim_helper.buf
    vim_helper.buf = CustomVimBuffer()


def reset_filetype():
    from UltiSnips import vim_helper

    vim_helper.buf = vim_helper._orig_buf
