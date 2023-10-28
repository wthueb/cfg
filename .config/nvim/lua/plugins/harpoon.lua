return {
    "theprimeagen/harpoon",
    config = function()
        require("harpoon").setup()

        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")

        vim.keymap.set("n", "<leader>a", mark.add_file, { silent = true, desc = "Add harpoon mark" })
        vim.keymap.set("n", "<C-h>", ui.toggle_quick_menu, { silent = true, desc = "Toggle harpoon quick menu" })
        vim.keymap.set("n", "<C-j>", function()
            ui.nav_file(1)
        end, { silent = true, desc = "Go to harpoon #1" })
        vim.keymap.set("n", "<C-k>", function()
            ui.nav_file(2)
        end, { silent = true, desc = "Go to harpoon #2" })
        vim.keymap.set("n", "<C-l>", function()
            ui.nav_file(3)
        end, { silent = true, desc = "Go to harpoon #3" })
        vim.keymap.set("n", "<C-;>", function()
            ui.nav_file(4)
        end, { silent = true, desc = "Go to harpoon #4" })
    end,
}
