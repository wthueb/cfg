vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true

require("plugin-manager")

vim.opt.visualbell = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes:1"
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

vim.opt.updatetime = 50

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    command = [[setlocal colorcolumn=88]]
})

vim.keymap.set("i", "kj", "<Esc>", { silent = true, desc = "Exit insert mode" })
vim.keymap.set("c", "kj", "<C-c>", { silent = true, desc = "Exit command mode" })

vim.keymap.set("n", ";d", "<cmd>bd<CR>", { silent = true, desc = "Close current buffer" })

vim.keymap.set("n", "<leader><leader>", ":w<CR>:sus<CR>", { silent = true, desc = "Write file and suspend" })

vim.keymap.set("n", "<leader>.", ":nohl<CR>", { silent = true, desc = "Remove highlighting" })
vim.keymap.set("n", "<leader>y", '"+y', { silent = true, desc = "Yank to system clipboard" })

vim.keymap.set("n", "J", "mzJ`z:delm z<CR>", { silent = true, desc = "Keep cursor in same place while picking up lines" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true, desc = "Keep cursor in middle while scrolling down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true, desc = "Keep cursor in middle while scrolling up" })
vim.keymap.set("n", "n", "nzz", { silent = true, desc = "Keep cursor in middle while searching down" })
vim.keymap.set("n", "N", "Nzz", { silent = true, desc = "Keep cursor in middle while searching up" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { silent = true, desc = "Open tmux-sessionizer" })

pcall(require, "custom")
