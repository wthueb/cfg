return {
    {
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

            local map = require("keys").map

            map("n", ";d", ":bd<cr>", "Close current buffer")
            map("n", ";;", ":bp<cr>", "Go to previous buffer")
            map("n", ";[", ":BufferLineCyclePrev<CR>", "Cycle back one buffer")
            map("n", ";]", ":BufferLineCycleNext<CR>", "Cycle forward one buffer")
        end
    },
}
