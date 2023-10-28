return {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.g.nord_italic = false
        vim.g.nord_uniform_diff_background = true
        require("nord").set()
    end,
}
