---@module "lazy"
---@type LazySpec
return {
    "nvim-telescope/telescope.nvim",
    version = "*",
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
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                    "--glob",
                    "!.git/",
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
    end,
    keys = {
        {
            "<leader><space>",
            "<cmd>Telescope buffers<CR>",
            desc = "Telescope open buffers",
        },
        {
            "<leader>/",
            "<cmd>Telescope current_buffer_fuzzy_find<CR>",
            desc = "Telescope in current buffer",
        },
        {
            "<leader>sf",
            "<cmd>Telescope find_files<CR>",
            desc = "Files",
        },
        {
            "<leader>ss",
            "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>",
            desc = "LSP symbols",
        },
        {
            "<leader>sh",
            "<cmd>Telescope help_tags<CR>",
            desc = "Help",
        },
        {
            "<leader>sg",
            "<cmd>Telescope live_grep<CR>",
            desc = "Grep",
        },
        {
            "<leader>sd",
            "<cmd>Telescope diagnostics<CR>",
            desc = "Diagnostics",
        },
        {
            "<C-p>",
            "<cmd>Telescope keymaps<CR>",
            desc = "Telescope keymaps",
        },
    },
}
