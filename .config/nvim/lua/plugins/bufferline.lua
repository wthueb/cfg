return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        ---@diagnostic disable: missing-fields
        require("bufferline").setup({
            options = {
                numbers = "none",
                diagnostics = "coc",
                always_show_bufferline = false,
            }
        })

        -- disable by default
        vim.opt.showtabline = 0

        vim.keymap.set("n", ";t", function()
            if vim.opt.showtabline:get() == 2 then
                vim.opt.showtabline = 0
            else
                vim.opt.showtabline = 2
            end
        end, { silent = true, desc = "Toggle bufferline" })

        vim.keymap.set("n", ";d", "<cmd>bd<CR>", { silent = true, desc = "Close current buffer" })
        vim.keymap.set("n", ";;", "<cmd>bp<CR>", { silent = true, desc = "Go to previous buffer" })
        vim.keymap.set("n", ";[", "<cmd>BufferLineCyclePrev<CR>", { silent = true, desc = "Cycle back one buffer" })
        vim.keymap.set("n", ";]", "<cmd>BufferLineCycleNext<CR>", { silent = true, desc = "Cycle forward one buffer" })

        vim.keymap.set("n", ";1", "<cmd>BufferLineGoToBuffer 1<CR>", { silent = true, desc = "Go to buffer 1" })
        vim.keymap.set("n", ";2", "<cmd>BufferLineGoToBuffer 2<CR>", { silent = true, desc = "Go to buffer 2" })
        vim.keymap.set("n", ";3", "<cmd>BufferLineGoToBuffer 3<CR>", { silent = true, desc = "Go to buffer 3" })
        vim.keymap.set("n", ";4", "<cmd>BufferLineGoToBuffer 4<CR>", { silent = true, desc = "Go to buffer 4" })
        vim.keymap.set("n", ";5", "<cmd>BufferLineGoToBuffer 5<CR>", { silent = true, desc = "Go to buffer 5" })
        vim.keymap.set("n", ";6", "<cmd>BufferLineGoToBuffer 6<CR>", { silent = true, desc = "Go to buffer 6" })
        vim.keymap.set("n", ";7", "<cmd>BufferLineGoToBuffer 7<CR>", { silent = true, desc = "Go to buffer 7" })
        vim.keymap.set("n", ";8", "<cmd>BufferLineGoToBuffer 8<CR>", { silent = true, desc = "Go to buffer 8" })
        vim.keymap.set("n", ";9", "<cmd>BufferLineGoToBuffer 9<CR>", { silent = true, desc = "Go to buffer 9" })
        vim.keymap.set("n", ";0", "<cmd>BufferLineGoToBuffer 10<CR>", { silent = true, desc = "Go to buffer 10" })
    end
}
