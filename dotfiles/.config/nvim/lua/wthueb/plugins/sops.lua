---@module "lazy"
---@type LazySpec
return {
    "trixnz/sops.nvim",
    lazy = false,
    opts = {
        supported_file_formats = { "*.sops" },
    },
    init = function()
        vim.filetype.add({ extension = { sops = "binary" } })
    end,
}
