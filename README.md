# cmp-nvim-ultisnips

[ultisnips](https://github.com/SirVer/ultisnips) completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

```lua
-- Installation
use { 'quangnguyen30192/cmp-nvim-ultisnips' } 
use { 
  'hrsh7th/nvim-cmp',
  config = function ()
    local t = function(str)
      return vim.api.nvim_replace_termcodes(str, true, true, true)
    end

    require'cmp'.setup {
    snippet = {
      expand = function(args)
        vim.fn["UltiSnips#Anon"](args.body)
      end,
    },
  
    sources = {
      { name = 'ultisnips' },
      -- more sources
    },
    -- tab for expand source 
    mapping = {
      ['<Tab>'] = cmp.mapping(function(fallback)
        if vim.fn.pumvisible() == 1 then
          if vim.fn["UltiSnips#CanExpandSnippet"]() == 1 or vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
            return vim.fn.feedkeys(t("<C-R>=UltiSnips#ExpandSnippetOrJump()<CR>"))
          end

          vim.fn.feedkeys(t("<C-n>"), "n")
        elseif is_prior_char_whitespace() then
          vim.fn.feedkeys(t("<tab>"), "n")
        else
          fallback()
        end
      end, { 'i', 's' })
    },
  }
  end
}
```

# Credit
[Compe source for ultisnips](https://github.com/hrsh7th/nvim-compe/blob/master/lua/compe_ultisnips/init.lua)
