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

        vim.keymap.set("n", ";d", "<cmd>bd<CR>", { silent = true, desc = "Close current buffer" })
        vim.keymap.set("n", ";;", "<cmd>bp<CR>", { silent = true, desc = "Go to previous buffer" })
        vim.keymap.set("n", ";[", "<cmd>BufferLineCyclePrev<CR>", { silent = true, desc = "Cycle back one buffer" })
        vim.keymap.set("n", ";]", "<cmd>BufferLineCycleNext<CR>", { silent = true, desc = "Cycle forward one buffer" })
    end
}
