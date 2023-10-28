return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("trouble").setup()

        vim.keymap.set(
            "n",
            "<leader>qf",
            "<cmd>TroubleToggle quickfix<cr>",
            { silent = true, desc = "Open trouble quickfix" }
        )
        vim.keymap.set("n", "H", function()
            require("trouble").previous({ skip_groups = true, jump = true })
        end, { silent = true, desc = "Previous trouble item" })
        vim.keymap.set("n", "L", function()
            require("trouble").next({ skip_groups = true, jump = true })
        end, { silent = true, desc = "Next trouble item" })
        vim.keymap.set("n", "<C-t>", function(...)
            require("trouble.providers.telescope").open_trouble(...)
        end, { silent = true, desc = "Open trouble in telescope" })
    end,
}
