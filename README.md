# cmp-nvim-ultisnips

<p align="center">
  <a href="https://github.com/SirVer/ultisnips">UltiSnips</a> completion source for <a href="https://github.com/hrsh7th/nvim-cmp">nvim-cmp</a>
</p>

<p align="center">
  <img alt="Screenshot" title="cmp-nvim-ultisnips" src="screenshots/preview.png" width="80%" height="80%">
</p>

## Installation

```lua
use({
  "hrsh7th/nvim-cmp",
  requires = {
    "quangnguyen30192/cmp-nvim-ultisnips",
    config = function()
      -- optional call to setup (see Customization section)
      require("cmp-nvim-ultisnips").setup{}
    end
  },
  config = function()
    local cmp = require("cmp")
    local has_any_words_before = function()
      if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
        return false
      end
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local press = function(key)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), "n", true)
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
          if cmp.visible() then
            if vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
              return press("<C-R>=UltiSnips#ExpandSnippet()<CR>")
            end

            cmp.select_next_item()
          elseif has_any_words_before() then
            press("<Space>")
          else
            fallback()
          end
        end, {
          "i",
          "s",
          -- add this line when using cmp-cmdline:
          -- "c",
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.get_selected_entry() == nil and vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
            press("<C-R>=UltiSnips#ExpandSnippet()<CR>")
          elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
            press("<ESC>:call UltiSnips#JumpForwards()<CR>")
          elseif cmp.visible() then
            cmp.select_next_item()
          elseif has_any_words_before() then
            press("<Tab>")
          else
            fallback()
          end
        end, {
          "i",
          "s",
          -- add this line when using cmp-cmdline:
          -- "c",
        }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
            press("<ESC>:call UltiSnips#JumpBackwards()<CR>")
          elseif cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, {
          "i",
          "s",
          -- add this line when using cmp-cmdline:
          -- "c",
        }),
      },
    })
  end,
})
```

## Reloading Snippets
To avoid having to restart Neovim after you have modified your UltiSnips snippets, you can use the `:CmpUltisnipsReloadSnippets` command
and e.g. use it in an autocommand:
```vim
autocmd BufWritePost *.snippets :CmpUltisnipsReloadSnippets
```
This will automatically reload all of your snippets after saving a snippet file.

## Customization
Note: calling the setup function is only required if you wish to customize this plugin.
### Example Configuration
```lua
require("cmp-nvim-ultisnips").setup {
  documentation = function(snippet_info)
    return snippet_info.description
  end
}
```

### Available Options
In this section, `snippet_info` is a table that contains the following information about a snippet:
```lua
snippet_info = {
  tab_trigger = ... -- type: string, never nil
  description = ... -- type: string, optional
  options = ... -- type: string, optional
  expression = ... -- type: string, only present for snippets with the 'e' option

  -- type: table of strings, where each string is one line in the snippet definition, never nil
  content = { ... }
}
```
---

`documentation(snippet_info: {})`

**Returns**: a string that is shown by cmp in the documentation window.
If `nil` is returned, the documentation window will not appear for this snippet.

**Default value:** `require('cmp_nvim_ultisnips.snippets').documentation`

By default, this shows the snippet description at the top of the documentation window
followed by the snippet content (see screenshot at the top of the readme).


## Credit
[Compe source for ultisnips](https://github.com/hrsh7th/nvim-compe/blob/master/lua/compe_ultisnips/init.lua)

## Known Issues
`honza/vim-snippets` does not work in neovim nightly for the time being. Please check this [issue](https://github.com/quangnguyen30192/cmp-nvim-ultisnips/issues/9).

Neovim team is working on the [fix](https://github.com/neovim/neovim/pull/15632).

The temporary solution is to set the runtimepath as follows:
```lua
use {'honza/vim-snippets', rtp = '.'}
```

---

UltiSnips was auto-removing tab mappings for select mode, that way it was not possible to jump through snippet stops.
We have to disable this by setting `UltiSnipsRemoveSelectModeMappings = 0` (Credit [JoseConseco](https://github.com/quangnguyen30192/cmp-nvim-ultisnips/issues/5))
```lua
use({
  "SirVer/ultisnips",
  requires = "honza/vim-snippets",
  config = function()
    vim.g.UltiSnipsRemoveSelectModeMappings = 0
  end,
})
```

