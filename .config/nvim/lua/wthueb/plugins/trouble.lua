return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("trouble").setup()

        vim.keymap.set("n", "H", function()
            require("trouble").previous({ skip_groups = true, jump = true })
        end, { silent = true, desc = "Previous trouble item" })
        vim.keymap.set("n", "L", function()
            require("trouble").next({ skip_groups = true, jump = true })
        end, { silent = true, desc = "Next trouble item" })
    end,
}
