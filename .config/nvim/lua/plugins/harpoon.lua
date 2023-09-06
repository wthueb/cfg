return {
    "theprimeagen/harpoon",
    config = function()
        require("harpoon").setup()

        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")

        require("which-key").register({
            ["<leader>a"] = { mark.add_file, "Add harpoon mark" },
            ["<C-s>"] = { ui.toggle_quick_menu, "Toggle harpoon quick menu" },
            ["<C-j>"] = { function() ui.nav_file(1) end, "Go to harpoon #1" },
            ["<C-k>"] = { function() ui.nav_file(2) end, "Go to harpoon #2" },
            ["<C-l>"] = { function() ui.nav_file(3) end, "Go to harpoon #3" },
            ["<C-;>"] = { function() ui.nav_file(4) end, "Go to harpoon #4" },
        })
    end
}
