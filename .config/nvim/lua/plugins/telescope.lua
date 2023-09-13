return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
    },
    config = function()
        require("telescope").setup({
            pickers = {
                find_files = {
                    find_command = {
                        "fd",
                        "--type", "f",
                        "--hidden",
                        "--exclude", ".git",
                    }
                }
            }
        })

        -- Enable telescope fzf native, if installed
        pcall(require("telescope").load_extension, "fzf")

        require("which-key").register({
            ["<leader>"] = {
                ["<space>"] = { "<cmd>Telescope buffers<CR>", "Telescope open buffers" },
                ["/"] = { "<cmd>Telescope current_buffer_fuzzy_find<CR>", "Telescope in current buffer" },
                s = {
                    name = "Telescope",
                    r = { "<cmd>Telescope oldfiles<CR>", "Recently opened" },
                    f = { "<cmd>Telescope find_files hidden=true<CR>", "Files" },
                    h = { "<cmd>Telescope help_tags<CR>", "Help" },
                    w = { "<cmd>Telescope grep_string<CR>", "Current word" },
                    g = { "<cmd>Telescope live_grep<CR>", "Grep" },
                    d = { "<cmd>Telescope diagnostics<CR>", "Diagnostics" },
                }
            },
            ["<C-p>"] = { "<cmd>Telescope keymaps<CR>", "Telescope keymaps" },
        })
    end
}
