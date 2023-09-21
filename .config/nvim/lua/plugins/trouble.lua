return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("trouble").setup()

        require("which-key").register({
            ["<leader>qf"] = { "<cmd>TroubleToggle quickfix<cr>", "Open trouble quickfix" },
            ["H"] = { function () require("trouble").previous({skip_groups = true, jump = true}) end, "Previous trouble item" },
            ["L"] = { function () require("trouble").next({skip_groups = true, jump = true}) end, "Next trouble item" },
        })
    end
}
