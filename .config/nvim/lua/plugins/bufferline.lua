return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        require("bufferline").setup({
            options = {
                numbers = "none",
                diagnostics = "coc",
                always_show_bufferline = false,
            }
        })

        require("which-key").register({
            [";"] = {
                name = "Buffer",
                d = { ":bd<CR>", "Close current buffer" },
                [";"] = { ":bp<CR>", "Go to previous buffer" },
                ["["] = { ":BufferLineCyclePrev<CR>", "Cycle back one buffer" },
                ["]"] = { ":BufferLineCycleNext<CR>", "Cycle forward one buffer" },
            }
        })
    end
}
