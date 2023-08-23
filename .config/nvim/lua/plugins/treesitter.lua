return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            pcall(require("nvim-treesitter.install").update({ with_sync = true }))
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            require("nvim-treesitter.configs").setup({
                -- Add languages to be installed here that you want installed for treesitter
                ensure_installed = {
                    "bash",
                    "c",
                    "c_sharp",
                    "cpp",
                    "css",
                    "html",
                    "javascript",
                    "lua",
                    "python",
                    "rust",
                    "scss",
                    "sql",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "query"
                },

                highlight = { enable = true },
                indent = {
                    enable = true,
                    disable = { "python" }
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<c-space>",
                        node_incremental = "<c-space>",
                        scope_incremental = "<c-s>",
                        node_decremental = "<c-backspace>",
                    },
                },
            })
        end,
    },
}
