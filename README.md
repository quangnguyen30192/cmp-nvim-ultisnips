# cmp-nvim-ultisnips

[ultisnips](https://github.com/SirVer/ultisnips) completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

```lua
-- Installation
use({
  "hrsh7th/nvim-cmp",
  requires = {
    "quangnguyen30192/cmp-nvim-ultisnips",
  },
  config = function()
    local cmp = require("cmp")
    local t = function(str)
      return vim.api.nvim_replace_termcodes(str, true, true, true)
    end

    local check_back_space = function()
      local col = vim.fn.col(".") - 1
      return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
    end

    cmp.setup({
      snippet = {
        expand = function(args)
          vim.fn["UltiSnips#Anon"](args.body)
        end,
      },
      sources = {
        { name = "ultisnips" },
        -- more sources
      },
      -- Configure for <TAB> people
      -- - <TAB> and <S-TAB>: cycle forward and backward through autocompletion items
      -- - <TAB> and <S-TAB>: cycle forward and backward through snippets tabstops and placeholders
      -- - <TAB> to expand snippet when no completion item selected (you don't need to select the snippet from completion item to expand)
      -- - <C-space> to expand the selected snippet from completion menu
      mapping = {
        ["<C-Space>"] = cmp.mapping(function(fallback)
          if vim.fn.pumvisible() == 1 then
            if vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
              return vim.fn.feedkeys(t("<C-R>=UltiSnips#ExpandSnippet()<CR>"))
            end

            vim.fn.feedkeys(t("<C-n>"), "n")
          elseif check_back_space() then
            vim.fn.feedkeys(t("<cr>"), "n")
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if vim.fn.complete_info()["selected"] == -1 and vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
            vim.fn.feedkeys(t("<C-R>=UltiSnips#ExpandSnippet()<CR>"))
          elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
            vim.fn.feedkeys(t("<C-R>=UltiSnips#JumpForwards()<CR>"))
          elseif vim.fn.pumvisible() == 1 then
            vim.fn.feedkeys(t("<C-n>"), "n")
          elseif check_back_space() then
            vim.fn.feedkeys(t("<tab>"), "n")
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
            return vim.fn.feedkeys(t("<C-R>=UltiSnips#JumpBackwards()<CR>"))
          elseif vim.fn.pumvisible() == 1 then
            vim.fn.feedkeys(t("<C-p>"), "n")
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
      },
    })
  end,
})
```

# Credit
[Compe source for ultisnips](https://github.com/hrsh7th/nvim-compe/blob/master/lua/compe_ultisnips/init.lua)
