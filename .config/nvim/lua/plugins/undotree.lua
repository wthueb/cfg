return {
    "mbbill/undotree",
    config = function()
        require("which-key").register({
            ["<leader>u"] = { vim.cmd.UndotreeToggle, "Toggle undotree" }
        })
    end
}
