# cmp-nvim-ultisnips

<p align="center">
  <a href="https://github.com/SirVer/ultisnips">UltiSnips</a> completion source for <a href="https://github.com/hrsh7th/nvim-cmp">nvim-cmp</a>
</p>

<p align="center">
  <img alt="Screenshot" title="cmp-nvim-ultisnips" src="screenshots/preview.png" width="80%" height="80%">
</p>

## Installation and Recommended Mappings

```lua
use({
  "hrsh7th/nvim-cmp",
  requires = {
    "quangnguyen30192/cmp-nvim-ultisnips",
    config = function()
      -- optional call to setup (see customization section)
      require("cmp_nvim_ultisnips").setup{}
    end
  },
  config = function()
    local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
    require("cmp").setup({
      snippet = {
        expand = function(args)
          vim.fn["UltiSnips#Anon"](args.body)
        end,
      },
      sources = {
        { name = "ultisnips" },
        -- more sources
      },
      --[[
      Configuration for <Tab> people:
      <Tab> (and <S-Tab>)
        cycle forward (backward) through completion items
        and snippet tabstops / placeholders

      <Tab>
        to expand a snippet when no completion item is selected
      ]]
      mapping = {
        ["<Tab>"] = cmp.mapping(function(fallback)
          cmp_ultisnips_mappings.expand_or_jump_forwards(fallback)
        end, {
          "i",
          "s",
          -- add this line when using cmp-cmdline:
          -- "c",
        }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          cmp_ultisnips_mappings.jump_backwards(fallback)
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
When the option `show_snippets` is set to `expandable` (see customization section; this is the default),
the snippets are not cached and thus automatically reloaded after you modified your snippet definitions.

When set to `all`, you can manually reload the snippets with the command
`:CmpUltisnipsReloadSnippets` and e.g. use it in an autocommand:

```vim
autocmd BufWritePost *.snippets :CmpUltisnipsReloadSnippets
```

## Customization
Note: calling the setup function is only required if you wish to customize this plugin.
### Example Configuration
```lua
require("cmp_nvim_ultisnips").setup {
  show_snippets = "all",
  documentation = function(snippet)
    return snippet.description
  end
}
```

### Available Options
In this section, `snippet` is a table that contains the following keys (each value is a string):

- trigger, description, options, value

---

`show_snippets: "expandable" | "all"`

If set to `"expandable"`, only those snippets currently expandable by UltiSnips will be
shown by cmp. `"all"` will show all snippets for the current filetype except regular
expression snippets (option `r`) and custom context snippets (option `e`).

**Default:** `"expandable"`

---

`documentation(snippet: {}): function`

**Returns:** a string that is shown by cmp in the documentation window.
If an empty string (`""`) is returned, the documentation window will not appear for that snippet.

**Default:** `require("cmp_nvim_ultisnips.snippets").documentation`

By default, this shows the snippet description at the top of the documentation window
followed by the snippet content (see screenshot at the top of the readme).


## Credit
[Compe source for UltiSnips](https://github.com/hrsh7th/nvim-compe/blob/master/lua/compe_ultisnips/init.lua)

## Known Issues
`honza/vim-snippets` does not work in neovim nightly for the time being. Please check this [issue](https://github.com/quangnguyen30192/cmp-nvim-ultisnips/issues/9).

Neovim team is working on the [fix](https://github.com/neovim/neovim/pull/15632).

The temporary solution is to set the runtimepath as follows:
```lua
use {"honza/vim-snippets", rtp = "."}
```

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

