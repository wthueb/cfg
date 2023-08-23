local keys = require("keys")

vim.g.mapleader = ","
vim.g.maplocalleader = ","

vim.opt.termguicolors = true

require("plugin-manager")

vim.opt.visualbell = true

vim.opt.number = true
vim.opt.signcolumn = "number"
vim.opt.cursorline = true

-- have 5 lines above/below the cursor at all times if possible
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.sidescroll = 1

vim.opt.wrap = false

vim.opt.spelllang = "en_us"

-- backspace will delete newlines and indents ~normally~
vim.opt.backspace = "indent,eol,start"

-- always show status line
vim.opt.laststatus = 2
-- don't show mOde on the last line when in insert/visual mode
vim.opt.showmode = false

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 4 spaces for tabs by default. sw=0 sts=0 means it uses tabstop value
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = 0
vim.opt.expandtab = true

vim.opt.smartindent = true

-- show tabs as characters
vim.opt.list = true
vim.opt.listchars = "tab:>·,trail:·,nbsp:·"

vim.opt.colorcolumn = "100"

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    command = [[setlocal colorcolumn=88]]
})
