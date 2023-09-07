return {
    "folke/which-key.nvim",
    config = function()
        local wk = require("which-key")

        wk.setup()

        wk.register({
            ["<leader>?n"] = { vim.cmd.WhichKey, "Show all normal mode keybindings" },
            ["<leader>?v"] = { "<cmd>WhichKey '' v<CR>", "Show all visual mode keybindings" },
            ["<leader>?i"] = { "<cmd>WhichKey '' i<CR>", "Show all insert mode keybindings" },
        })
    end
}
