" Define silent mappings
imap <silent> <Plug>(cmpu-expand)
\ <C-r>=[UltiSnips#CursorMoved(), UltiSnips#ExpandSnippet()][1]<cr>

imap <silent> <Plug>(cmpu-jump-forwards)
\ <C-r>=[UltiSnips#CursorMoved(), UltiSnips#JumpForwards()][1]<cr>

imap <silent> <Plug>(cmpu-jump-backwards)
\ <C-r>=[UltiSnips#CursorMoved(), UltiSnips#JumpBackwards()][1]<cr>
