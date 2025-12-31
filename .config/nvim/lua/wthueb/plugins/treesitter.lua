---@module "lazy"
---@type LazySpec
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
    config = function()
        ---@diagnostic disable-next-line: missing-fields
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "angular",
                "bash",
                "c",
                "c_sharp",
                "cpp",
                "css",
                "html",
                "javascript",
                "lua",
                "nu",
                "python",
                "rust",
                "scss",
                "sql",
                "typescript",
                "vim",
                "vimdoc",
                "query",
            },

            sync_install = false,
            auto_install = true,

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },

            indent = { enable = true },

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = "<C-s>",
                    node_decremental = "<C-b>",
                },
            },

            textobjects = {
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]]"] = "@class.outer",
                        ["]o"] = "@loop.*",
                        ["]s"] = "@scope",
                        ["]z"] = "@fold",
                    },
                    goto_next_end = {
                        ["]M"] = "@function.outer",
                        ["]["] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[["] = "@class.outer",
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer",
                        ["[]"] = "@class.outer",
                    },
                },
            },
        })
    end,
}
