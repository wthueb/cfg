return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        require("nvim-treesitter.configs").setup({
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

            sync_install = false,
            auto_install = true,

            highlight = { enable = true },

            indent = {
                enable = true,
                disable = { "python" }
            },

            additional_vim_regex_highlighting = false,
        })
    end
}
