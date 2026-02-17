package = "cmp-nvim-ultisnips"
version = "1.0.0"
source = "git@github.com:quangnguyen30192/cmp-nvim-ultisnips.git"

description = {
  summary = "nvim-cmp source for UltiSnips",
  detailed = "cmp-nvim-ultisnips is a completion source for nvim-cmp providing UltiSnips snippets. Features include composable mappings, treesitter integration, support for regular expression + custom context snippets.",
  homepage = "git@github.com:quangnguyen30192/cmp-nvim-ultisnips.git",
  license = "Apache-2.0",
}

dependencies = {
  neovim = {
    version = ">= v0.5.0",
    source = "git://github.com/neovim/neovim.git",
  },
  ["nvim-cmp"] = {
    source = "git@github.com:hrsh7th/nvim-cmp.git",
  },
}
