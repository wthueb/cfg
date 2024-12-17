return {
    "neovim/nvim-lspconfig",

    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer",
        { "folke/neodev.nvim", opts = {} },
        { "j-hui/fidget.nvim", opts = {} },
        { "creativenull/efmls-configs-nvim", version = "1.x.x" },
    },

    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup()
        require("mason-tool-installer").setup({
            ensure_installed = {
                "angularls",
                "cssls",
                "efm",
                "emmet_language_server",
                "eslint",
                "html",
                "jsonls",
                "prettier",
                "pyright",
                "ruff",
                "rust_analyzer",
                "lua_ls",
                "stylua",
                "vtsls",
                "yamlls",
            },
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            desc = "LSP actions",
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)

                vim.keymap.set(
                    "n",
                    "<leader>dca",
                    vim.lsp.buf.code_action,
                    { silent = true, desc = "Apply code action", buffer = true }
                )
                vim.keymap.set(
                    "n",
                    "<leader>dd",
                    vim.diagnostic.open_float,
                    { silent = true, desc = "Open diagnostic", buffer = true }
                )

                vim.keymap.set("n", "<leader>f", function()
                    local formatters = vim.tbl_map(
                        function(c)
                            return c.name
                        end,
                        vim.tbl_filter(function(c)
                            return c.server_capabilities.documentFormattingProvider
                        end, vim.lsp.get_clients({ buffer = event.buf }))
                    )

                    if #formatters == 0 then
                        return
                    end

                    if #formatters == 1 then
                        return vim.lsp.buf.format({ name = formatters[1] })
                    end

                    -- if vim.tbl_contains(formatters, "efm") then
                    --     return vim.lsp.buf.format({ name = "efm" })
                    -- end

                    table.sort(formatters)

                    return vim.ui.select(formatters, {
                        prompt = "Select formatter",
                    }, function(choice)
                        vim.lsp.buf.format({ name = choice })
                    end)
                end, { silent = true, desc = "Format current buffer", buffer = true })

                vim.keymap.set("n", "<leader>r", function()
                    local renamers = vim.tbl_map(
                        function(c)
                            return c.name
                        end,
                        vim.tbl_filter(function(c)
                            return c.server_capabilities.renameProvider
                        end, vim.lsp.get_clients({ bufnr = event.buf }))
                    )

                    if #renamers == 0 then
                        return
                    end

                    if #renamers == 1 then
                        return vim.lsp.buf.rename(nil, { name = renamers[1] })
                    end

                    table.sort(renamers)

                    return vim.ui.select(renamers, {
                        prompt = "Select renamer",
                    }, function(choice)
                        vim.lsp.buf.rename(nil, { name = choice })
                    end)
                end, { silent = true, desc = "Rename symbol", buffer = true })

                vim.keymap.set("n", "K", vim.lsp.buf.hover, { silent = true, desc = "Show hover", buffer = true })
                vim.keymap.set(
                    "i",
                    "<C-k>",
                    vim.lsp.buf.signature_help,
                    { silent = true, desc = "Show signature help", buffer = true }
                )

                vim.keymap.set(
                    "n",
                    "gd",
                    vim.lsp.buf.definition,
                    { silent = true, desc = "Go to definition", buffer = true }
                )
                vim.keymap.set(
                    "n",
                    "gD",
                    vim.lsp.buf.declaration,
                    { silent = true, desc = "Go to declaration", buffer = true }
                )
                vim.keymap.set(
                    "n",
                    "gt",
                    vim.lsp.buf.type_definition,
                    { silent = true, desc = "Go to type definition", buffer = true }
                )
                vim.keymap.set(
                    "n",
                    "gi",
                    vim.lsp.buf.implementation,
                    { silent = true, desc = "Go to implementation", buffer = true }
                )
                vim.keymap.set("n", "gr", function()
                    require("trouble").open("lsp_references")
                end, { silent = true, desc = "Go to references", buffer = true })

                vim.keymap.set("n", "[d", function()
                    -- vim.diagnostic.jump({ count = -1 })
                    vim.diagnostic.goto_prev()
                end, { silent = true, desc = "Go to previous diagnostic", buffer = true })

                vim.keymap.set("n", "]d", function()
                    -- vim.diagnostic.jump({ count = 1 })
                    vim.diagnostic.goto_next()
                end, { silent = true, desc = "Go to next diagnostic", buffer = true })

                if client and client.server_capabilities.documentHighlightProvider then
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        desc = "Highlight symbol under cursor",
                        buffer = event.buf,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd("CursorMoved", {
                        buffer = event.buf,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
            end,
        })

        vim.api.nvim_create_autocmd("LspDetach", {
            desc = "LSP actions",
            callback = function()
                vim.lsp.buf.clear_references()
            end,
        })

        local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

        require("mason-lspconfig").setup_handlers({
            function(server_name)
                lspconfig[server_name].setup({ capabilities = capabilities })
            end,

            efm = function()
                local prettier = require("efmls-configs.formatters.prettier")

                local languages = {
                    astro = { prettier },
                    typescript = { prettier },
                    typescriptreact = { prettier },
                    javascript = { prettier },
                    html = { prettier },
                    htmlangular = { prettier },
                    css = { prettier },
                    json = { prettier },
                    jsonc = { prettier },
                    lua = { require("efmls-configs.formatters.stylua") },
                }

                lspconfig.efm.setup({
                    capabilities = capabilities,

                    filetypes = vim.tbl_keys(languages),

                    init_options = {
                        documentFormatting = true,
                        documentRangeFormatting = true,
                    },

                    settings = {
                        languages = languages,
                    },
                })
            end,

            emmet_language_server = function()
                lspconfig.emmet_language_server.setup({
                    capabilities = capabilities,
                    filetypes = {
                        "html",
                        "htmlangular",
                        "css",
                        "scss",
                        "javascriptreact",
                        "typescriptreact",
                        "astro",
                        "svelte",
                    },
                })
            end,

            lua_ls = function()
                lspconfig.lua_ls.setup({
                    capabilities = capabilities,

                    on_init = function(client)
                        local path = client.workspace_folders[1].name
                        if
                            not vim.loop.fs_stat(path .. "/.luarc.json")
                            and not vim.loop.fs_stat(path .. "/.luarc.jsonc")
                        then
                            client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
                                Lua = {
                                    runtime = {
                                        version = "LuaJIT",
                                    },
                                    workspace = {
                                        checkThirdParty = false,
                                        library = vim.api.nvim_get_runtime_file("", true),
                                    },
                                },
                            })

                            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                        end
                        return true
                    end,
                })
            end,

            rust_analyzer = function()
                lspconfig.rust_analyzer.setup({
                    capabilities = capabilities,

                    settings = {
                        ["rust-analyzer"] = {
                            checkOnSave = {
                                command = "clippy",
                            },
                        },
                    },
                })
            end,

            vtsls = function()
                lspconfig.vtsls.setup({
                    capabilities = capabilities,
                    settings = {
                        implicitProjectConfiguration = { checkJs = true },
                    },
                })
            end,
        })

        lspconfig.nil_ls.setup({
            capabilities = capabilities,
            settings = {
                ["nil"] = {
                    formatting = {
                        command = { "nixfmt" },
                    },
                },
            },
        })

        lspconfig.nushell.setup({
            capabilities = capabilities,
        })

        lspconfig.eslint.setup({
            capabilities = capabilities,
        })
    end,
}
