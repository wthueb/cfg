return {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
        local harpoon = require("harpoon")

        harpoon:setup()

        vim.keymap.set("n", "<leader>a", function()
            harpoon:list():append()
        end, { silent = true, desc = "Add harpoon mark" })
        vim.keymap.set("n", "<C-h>", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { silent = true, desc = "Toggle harpoon quick menu" })
        vim.keymap.set("n", "<C-j>", function()
            harpoon:list():select(1)
        end, { silent = true, desc = "Go to harpoon #1" })
        vim.keymap.set("n", "<C-k>", function()
            harpoon:list():select(2)
        end, { silent = true, desc = "Go to harpoon #2" })
        vim.keymap.set("n", "<C-l>", function()
            harpoon:list():select(3)
        end, { silent = true, desc = "Go to harpoon #3" })
        vim.keymap.set("n", "<C-;>", function()
            harpoon:list():select(4)
        end, { silent = true, desc = "Go to harpoon #4" })
    end,
}
