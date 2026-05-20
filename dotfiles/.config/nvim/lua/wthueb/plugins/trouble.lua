---@module "lazy"
---@type LazySpec
return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
        {
            "<leader>q",
            function()
                require("trouble").toggle({ mode = "qflist" })
            end,
            desc = "Toggle trouble quickfix list",
        },
        {
            "[q",
            function()
                require("trouble").prev({ mode = "qflist", skip_groups = true, jump = true })
            end,
            desc = "Previous quickfix item",
        },
        {
            "]q",
            function()
                require("trouble").next({ mode = "qflist", skip_groups = true, jump = true })
            end,
            desc = "Next quickfix item",
        },
        {
            "H",
            function()
                require("trouble").prev({ skip_groups = true, jump = true })
            end,
            desc = "Previous trouble item",
        },
        {
            "L",
            function()
                require("trouble").next({ skip_groups = true, jump = true })
            end,
            desc = "Next trouble item",
        },
    },
}
