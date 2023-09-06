return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("trouble").setup()

        require("which-key").register({
            ["<leader>qf"] = { "<cmd>TroubleToggle quickfix<cr>", "Open trouble quickfix" }
        })
    end
}
