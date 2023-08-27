return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        vim.g.loaded_netrw       = 1
        vim.g.loaded_netrwPlugin = 1

        require("nvim-tree").setup({})

        require("which-key").register({
            ["<leader>"] = {
                t = {
                    name = "Tree",
                    t = { "<cmd>NvimTreeToggle<CR>", "Toggle" },
                    r = { "<cmd>NvimTreeRefresh<CR>", "Refresh" },
                    f = { "<cmd>NvimTreeFindFile<CR>", "Find File" },
                }
            }
        })
    end
}
