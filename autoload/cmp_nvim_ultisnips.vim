function! cmp_nvim_ultisnips#setup_treesitter_autocmds()
  augroup cmp_nvim_ultisnips
    autocmd!
    autocmd TextChangedI,TextChangedP * lua require("cmp_nvim_ultisnips.treesitter").set_filetype()
    autocmd InsertLeave * lua require("cmp_nvim_ultisnips.treesitter").reset_filetype()
  augroup end
endfunction

function! cmp_nvim_ultisnips#initCustomUltiSnipMappings()
  " Define silent mappings

  " More info on why CursorMoved is called can be found here:
  " https://github.com/SirVer/ultisnips/issues/1295#issuecomment-774056584
  imap <silent> <Plug>(cmpu-expand)
        \ <C-r>=[UltiSnips#CursorMoved(), UltiSnips#ExpandSnippet()][1]<cr>

  smap <silent> <Plug>(cmpu-expand)
        \ <Esc>:call UltiSnips#ExpandSnippetOrJump()<cr>

  imap <silent> <Plug>(cmpu-jump-forwards)
        \ <C-r>=UltiSnips#JumpForwards()<cr>

  smap <silent> <Plug>(cmpu-jump-forwards)
        \ <Esc>:call UltiSnips#JumpForwards()<cr>

  imap <silent> <Plug>(cmpu-jump-backwards)
        \ <C-r>=UltiSnips#JumpBackwards()<cr>

  smap <silent> <Plug>(cmpu-jump-backwards)
        \ <Esc>:call UltiSnips#JumpBackwards()<cr>
endfunction
