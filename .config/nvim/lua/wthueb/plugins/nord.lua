---@module "lazy"
---@type LazySpec
return {
    "gbprod/nord.nvim",
    priority = 1000,
    config = function()
        ---@module "nord"
        require("nord").setup({})
        --vim.cmd.colorscheme("nord")
    end,
}
