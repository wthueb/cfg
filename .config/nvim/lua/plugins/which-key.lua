return {
    "folke/which-key.nvim",
    config = function()
        require("which-key").setup()

        vim.keymap.set("n", "<leader>?n", "<cmd>WhichKey<CR>", { silent = true, desc = "Show all normal mode keybindings" })
        vim.keymap.set("n", "<leader>?v", "<cmd>WhichKey '' v<CR>", { silent = true, desc = "Show all visual mode keybindings" })
        vim.keymap.set("n", "<leader>?i", "<cmd>WhichKey '' i<CR>", { silent = true, desc = "Show all insert mode keybindings" })
    end
}
