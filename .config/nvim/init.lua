vim.g.mapleader = ","
vim.g.maplocalleader = ","

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

local whichkey = require("which-key")

whichkey.register({
    ["<leader>"] = {
        ["<leader>"] = { ":w<CR>:sus<CR>", "Write file and suspend" },
        ["."] = { ":nohl<CR>", "Remove highlighting" },
        ["y"] = { '"+y', "Yank to system clipboard" },
        ["h"] = { "<cmd>lprev<cr>zz", "Previous loc" },
        ["l"] = { "<cmd>lnext<cr>zz", "Next loc" },
    },
    ["J"] = { "mzJ`z:delm z<cr>", "Keep cursor in same place while picking up lines" },
    ["<C-d>"] = { "<C-d>zz", "Keep cursor in middle while scrolling down" },
    ["<C-u>"] = { "<C-u>zz", "Keep cursor in middle while scrolling up" },
    ["n"] = { "nzz", "Keep cursor in middle while searching down" },
    ["N"] = { "Nzz", "Keep cursor in middle while searching up" },
    ["<C-f>"] = { "<cmd>silent !tmux neww tmux-sessionizer<cr>", "Open tmux-sessionizer" },
    ["<C-j>"] = { "<cmd>cprev<cr>zz", "Previous fix" },
    ["<C-k>"] = { "<cmd>cnext<cr>zz", "Next fix" },
})

whichkey.register({
    ["J"] = { ":m '>+1<CR>gv=gv", "Move selection down" },
    ["K"] = { ":m '<-2<CR>gv=gv", "Move selection up" },
}, { mode = "v" })
