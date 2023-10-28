return {
    "mbbill/undotree",
    config = function()
        vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { silent = true, desc = "Toggle undotree" })
    end,
}
