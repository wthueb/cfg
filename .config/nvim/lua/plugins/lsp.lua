return {
    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "williamboman/mason-lspconfig.nvim",
            dependencies = {
                {
                    "williamboman/mason.nvim",
                    opts = {}
                }
            },
            opts = {
                ensure_installed = {
                    "bashls",
                    "cssls",
                    "html",
                    "jsonls",
                    "rust_analyzer",
                    "lua_ls",
                    "pylsp",
                    "tsserver",
                    "yamlls",
                }
            },
        },
        { "j-hui/fidget.nvim", tag = "legacy", opts = {} },
        "folke/neodev.nvim",
    },
    config = function()
        local whichkey = require("which-key")

        vim.api.nvim_create_autocmd("LspAttach", {
            desc = "LSP actions",
            callback = function(_, opts)
                opts = opts or {}

                whichkey.register({
                    ["<leader>"] = {
                        ["d"] = {
                            ["ca"] = { vim.lsp.buf.code_action, "Apply code action" },
                            ["d"] = { vim.diagnostic.open_float, "Open diagnostic" },
                        },
                        ["f"] = { vim.lsp.buf.format, "Format current buffer" },
                        ["r"] = { vim.lsp.buf.rename, "Rename symbol" },
                    },
                    ["K"] = { vim.lsp.buf.hover, "Show hover information" },
                    ["[d"] = { vim.diagnostic.goto_prev, "Go to previous diagnostic" },
                    ["]d"] = { vim.diagnostic.goto_next, "Go to next diagnostic" },
                    ["g"] = {
                        ["d"] = { vim.lsp.buf.definition, "Go to definition" },
                        ["D"] = { vim.lsp.buf.declaration, "Go to declaration" },
                        ["i"] = { vim.lsp.buf.implementation, "Go to implementation" },
                        ["r"] = { function() require("trouble").open("lsp_references") end, "Go to references" },
                    },
                }, { buffer = opts.buffer })

                whichkey.register({
                    ["<C-h>"] = { vim.lsp.buf.signature_help, "Show signature help" },
                }, { mode = "i", buffer = opts.buffer })
            end
        })

        local lspconfig = require("lspconfig")
        local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

        require("mason-lspconfig").setup_handlers({
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = lsp_capabilities,
                })
            end,
        })

        lspconfig.lua_ls.setup({
            on_init = function(client)
                local path = client.workspace_folders[1].name
                if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                    client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
                        Lua = {
                            runtime = {
                                version = 'LuaJIT'
                            },
                            workspace = {
                                checkThirdParty = false,
                                library = vim.api.nvim_get_runtime_file("", true)
                            }
                        }
                    })

                    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                end
                return true
            end
        })

        -- :PylspInstall python-lsp-isort python-lsp-black pylsp-mypy
        lspconfig.pylsp.setup({
            settings = {
                pylsp = {
                    configurationSources = { "flake8" },
                    plugins = {
                        autopep8 = { enabled = false },
                        black = { enabled = true },
                        flake8 = { enabled = true },
                        isort = { enabled = true },
                        mccabe = { enabled = false },
                        pycodestyle = { enabled = false },
                        pyflakes = { enabled = false },
                        yapf = { enabled = false },
                    },
                },
            },
        })
    end
}
