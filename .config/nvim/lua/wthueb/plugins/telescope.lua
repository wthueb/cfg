return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
    },
    config = function()
        require("telescope").setup({
            defaults = {
                mappings = {
                    n = {
                        ["<C-q>"] = require("telescope.actions").send_to_qflist,
                        ["<C-t>"] = require("trouble.sources.telescope").open,
                    },
                    i = {
                        ["<C-q>"] = require("telescope.actions").send_to_qflist,
                        ["<C-t>"] = require("trouble.sources.telescope").open,
                    },
                },
            },
            pickers = {
                find_files = {
                    find_command = {
                        "fd",
                        "--type",
                        "f",
                        "--hidden",
                        "--exclude",
                        ".git",
                    },
                },
            },
        })

        -- Enable telescope fzf native, if installed
        pcall(require("telescope").load_extension, "fzf")

        vim.keymap.set(
            "n",
            "<leader><space>",
            "<cmd>Telescope buffers<CR>",
            { silent = true, desc = "Telescope open buffers" }
        )
        vim.keymap.set(
            "n",
            "<leader>/",
            "<cmd>Telescope current_buffer_fuzzy_find<CR>",
            { silent = true, desc = "Telescope in current buffer" }
        )
        vim.keymap.set("n", "<leader>sr", "<cmd>Telescope oldfiles<CR>", { silent = true, desc = "Recently opened" })
        vim.keymap.set(
            "n",
            "<leader>sf",
            "<cmd>Telescope find_files hidden=true<CR>",
            { silent = true, desc = "Files" }
        )
        vim.keymap.set(
            "n",
            "<leader>ss",
            "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>",
            { silent = true, desc = "LSP symbols" }
        )
        vim.keymap.set("n", "<leader>sh", "<cmd>Telescope help_tags<CR>", { silent = true, desc = "Help" })
        vim.keymap.set("n", "<leader>sg", "<cmd>Telescope live_grep<CR>", { silent = true, desc = "Grep" })
        vim.keymap.set("n", "<leader>sd", "<cmd>Telescope diagnostics<CR>", { silent = true, desc = "Diagnostics" })
        vim.keymap.set("n", "<C-p>", "<cmd>Telescope keymaps<CR>", { silent = true, desc = "Telescope keymaps" })
    end,
}
