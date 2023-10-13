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
        vim.api.nvim_create_autocmd("LspAttach", {
            desc = "LSP actions",
            callback = function(_, opts)
                opts = opts or {}

                vim.keymap.set("n", "<leader>dca", vim.lsp.buf.code_action, { silent = true, desc = "Apply code action", buffer = true })
                vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { silent = true, desc = "Open diagnostic", buffer = true })
                vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { silent = true, desc = "Format current buffer", buffer = true })
                vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { silent = true, desc = "Rename symbol", buffer = true })
                vim.keymap.set("n", "K", vim.lsp.buf.hover, { silent = true, desc = "Show hover", buffer = true })
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { silent = true, desc = "Go to previous diagnostic", buffer = true })
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { silent = true, desc = "Go to next diagnostic", buffer = true })
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, { silent = true, desc = "Go to definition", buffer = true })
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { silent = true, desc = "Go to declartion", buffer = true })
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { silent = true, desc = "Go to implementation", buffer = true })
                vim.keymap.set("n", "gr", function() require("trouble").open("lsp_references") end, { silent = true, desc = "Go to references", buffer = true })

                vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { silent = true, desc = "Show signature help", buffer = true })
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
                if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                    client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
                        Lua = {
                            runtime = {
                                version = "LuaJIT"
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
