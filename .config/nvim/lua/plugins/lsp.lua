return {
    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "williamboman/mason-lspconfig.nvim",
            dependencies = {
                {
                    "williamboman/mason.nvim",
                    config = function()
                        require("mason").setup()
                    end
                }
            },
            config = function()
                require("mason-lspconfig").setup({
                    ensure_installed = {
                        "bashls",
                        "cssls",
                        "html",
                        "jsonls",
                        "rust_analyzer",
                        "lua_ls",
                        "pyright",
                        "tsserver",
                        "yamlls",
                    }
                })
            end
        },
    },
    config = function()
        local whichkey = require("which-key")

        vim.api.nvim_create_autocmd("LspAttach", {
            desc = "LSP actions",
            callback = function(event, opts)
                opts = opts or {}

                whichkey.register({
                    ["<leader>"] = {
                        ["d"] = {
                            ["ca"] = { vim.lsp.buf.code_action, "Apply code action" },
                            ["d"] = { vim.diagnostic.open_float, "Open diagnostic" },
                        },
                        ["f"] = { vim.lsp.buf.format, "Format current buffer" },
                    },
                    ["K"] = { vim.lsp.buf.hover, "Show hover information" },
                    ["[d"] = { vim.diagnostic.goto_prev, "Go to previous diagnostic" },
                    ["]d"] = { vim.diagnostic.goto_next, "Go to next diagnostic" },
                    ["g"] = {
                        ["d"] = { vim.lsp.buf.definition, "Go to definition" },
                        ["D"] = { vim.lsp.buf.declaration, "Go to declaration" },
                        ["i"] = { vim.lsp.buf.implementation, "Go to implementation" },
                        ["r"] = { vim.lsp.buf.references, "Go to references" },
                    },
                }, { buffer = opts.buffer })

                whichkey.register({
                    ["<C-h>"] = { vim.lsp.buf.signature_help, "Show signature help" },
                }, { mode = "i", buffer = opts.buffer })
            end
        })

        local lspconfig = require("lspconfig")
        local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

        require("mason-lspconfig").setup_handlers({
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = lsp_capabilities,
                })
            end,
        })

        lspconfig.lua_ls.setup({
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                        },
                    },
                },
            },
        })
    end
}
