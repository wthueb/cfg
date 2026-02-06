---@module "lazy"
---@type LazySpec
return {
    -- TODO: nvim-treesitter/nvim-treesitter-textobjects
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local fts = {
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
        }

        require("nvim-treesitter").install(fts)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = fts,
            callback = function()
                vim.treesitter.start()
            end,
        })
    end,
}
