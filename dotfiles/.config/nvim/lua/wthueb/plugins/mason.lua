---@module "lazy"
---@type LazySpec
return {
    "mason-org/mason.nvim",
    version = "^2.0.0",
    dependencies = {
        { "mason-org/mason-lspconfig.nvim", version = "^2.0.0" },
        "WhoIsSethDaniel/mason-tool-installer",
        "jay-babu/mason-nvim-dap.nvim",
    },

    config = function()
        require("mason").setup({
            registries = {
                "github:mason-org/mason-registry",
                "github:Crashdummyy/mason-registry",
            },
        })
        require("mason-lspconfig").setup()
        require("mason-tool-installer").setup({
            ensure_installed = {
                "angularls",
                "basedpyright",
                "cssls",
                "docker-language-server",
                "efm",
                "emmet_language_server",
                "eslint",
                "html",
                "jsonls",
                { "lua_ls", version = "3.16.4" },
                "prettier",
                "ruff",
                "stylua",
                "systemd-lsp",
                "vtsls",
                "yamlls",
            },
        })
        require("mason-nvim-dap").setup({
            automatic_installation = true,
            ensure_installed = {},
        })
    end,
}
