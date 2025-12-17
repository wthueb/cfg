---@module "lazy"
---@type LazySpec
return {
    "neovim/nvim-lspconfig",

    dependencies = {
        {
            "mason-org/mason.nvim",
            version = "^2.0.0",
            opts = {
                registries = {
                    "github:mason-org/mason-registry",
                    "github:Crashdummyy/mason-registry",
                },
            },
        },
        { "mason-org/mason-lspconfig.nvim", version = "^2.0.0", opts = {} },
        {
            "WhoIsSethDaniel/mason-tool-installer",
            opts = {
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
            },
        },
        { "j-hui/fidget.nvim", opts = {} },
        { "creativenull/efmls-configs-nvim", version = "^1.0.0" },
        {
            "seblyng/roslyn.nvim",
            ft = { "cs", "razor" },
            dependencies = { { "tris203/rzls.nvim", opts = {} } },
            init = function()
                vim.filetype.add({ extension = { razor = "razor", cshtml = "razor" } })
            end,
            opts = {
                broad_search = true,
            },
        },
        {
            "folke/lazydev.nvim",
            ft = "lua",
            dependencies = {
                "DrKJeff16/wezterm-types",
                lazy = true,
                version = false,
            },
            opts = {
                library = {
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    { path = "wezterm-types", mods = { "wezterm" } },
                },
            },
        },
        { "marilari88/twoslash-queries.nvim", opts = {} },
    },

    config = function()
        local cmd = {}
        local mason_registry = require("mason-registry")
        local roslyn_package = mason_registry.get_package("roslyn")
        if roslyn_package:is_installed() then
            vim.list_extend(cmd, {
                "roslyn",
                "--stdio",
                "--logLevel=Information",
                "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
            })

            local rzls_package = mason_registry.get_package("rzls")
            if rzls_package:is_installed() then
                local rzls_path = vim.fn.expand("$MASON/packages/rzls/libexec")
                table.insert(
                    cmd,
                    "--razorSourceGenerator=" .. vim.fs.joinpath(rzls_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll")
                )
                table.insert(
                    cmd,
                    "--razorDesignTimePath="
                        .. vim.fs.joinpath(rzls_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets")
                )
                vim.list_extend(cmd, {
                    "--extension",
                    vim.fs.joinpath(rzls_path, "RazorExtension", "Microsoft.VisualStudioCode.RazorExtension.dll"),
                })
            end
        end

        vim.lsp.config("roslyn", {
            cmd = cmd,
            handlers = require("rzls.roslyn_handlers"),
        })
        vim.lsp.enable("roslyn")

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
                                and vim.lsp.buf_is_attached(event.buf, c.id)
                        end, vim.lsp.get_clients({ buffer = event.buf }))
                    )

                    if #formatters == 0 then
                        return
                    end

                    local format = function(name)
                        vim.lsp.buf.format({ name = name })

                        -- this only uses the first LSP that supports organizeImports, fine for now
                        for _, c in
                            pairs(vim.lsp.get_clients({ buffer = event.buf, method = "textDocument/codeAction" }))
                        do
                            if
                                c.server_capabilities.codeActionProvider
                                and c.server_capabilities.codeActionProvider.codeActionKinds
                            then
                                for _, kind in pairs(c.server_capabilities.codeActionProvider.codeActionKinds) do
                                    if kind:match("^source%.organizeImports") then
                                        vim.lsp.buf.code_action({
                                            ---@diagnostic disable-next-line: missing-fields
                                            context = { only = { "source.organizeImports" } },
                                            apply = true,
                                        })
                                        break
                                    end
                                end
                            end
                        end

                        vim.schedule(function()
                            print("formatted with " .. name)
                        end)
                    end

                    if #formatters == 1 then
                        format(formatters[1])
                        return
                    end

                    -- if vim.tbl_contains(formatters, "efm") then
                    --     return vim.lsp.buf.format({ name = "efm" })
                    -- end

                    table.sort(formatters)

                    if vim.tbl_contains(formatters, "efm") then
                        formatters = vim.tbl_filter(function(c)
                            return c ~= "efm"
                        end, formatters)

                        table.insert(formatters, 1, "efm")
                    end

                    return vim.ui.select(formatters, {
                        prompt = "Select formatter",
                    }, function(choice)
                        choice = choice or formatters[1]
                        format(choice)
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
                    vim.diagnostic.jump({ count = -1, float = true })
                end, { silent = true, desc = "Go to previous diagnostic", buffer = true })

                vim.keymap.set("n", "]d", function()
                    vim.diagnostic.jump({ count = 1, float = true })
                end, { silent = true, desc = "Go to next diagnostic", buffer = true })

                vim.keymap.set("n", "[D", function()
                    vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
                end, { silent = true, desc = "Go to previous error", buffer = true })

                vim.keymap.set("n", "]D", function()
                    vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
                end, { silent = true, desc = "Go to next error", buffer = true })

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

        vim.lsp.config("*", {
            capabilities = capabilities,
        })

        local prettier = require("efmls-configs.formatters.prettier")

        local languages = {
            astro = { prettier },
            typescript = { prettier },
            typescriptreact = { prettier },
            javascript = { prettier },
            javascriptreact = { prettier },
            html = { prettier },
            htmlangular = { prettier },
            css = { prettier },
            scss = { prettier },
            json = { prettier },
            jsonc = { prettier },
            lua = { require("efmls-configs.formatters.stylua") },
        }

        vim.lsp.config("efm", {
            filetypes = vim.tbl_keys(languages),

            init_options = {
                documentFormatting = true,
                documentRangeFormatting = true,
            },

            settings = {
                languages = languages,
            },
        })

        vim.lsp.config("emmet_language_server", {
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

        vim.lsp.config("rust_analyzer", {
            settings = {
                ["rust-analyzer"] = {
                    check = {
                        command = "clippy",
                    },
                    files = {
                        exclude = {
                            ".direnv",
                        },
                    },
                },
            },
        })

        vim.lsp.config("vtsls", {
            settings = {
                implicitProjectConfiguration = { checkJs = true },
            },
            on_attach = function(client, bufnr)
                require("twoslash-queries").attach(client, bufnr)
            end,
        })

        vim.lsp.config("sqlls", {
            root_dir = lspconfig.util.root_pattern(".git", ".gitignore", ".gitmodules"),
        })

        vim.lsp.config("angularls", {
            filetypes = {
                "typescript",
                "htmlangular",
            },
        })

        vim.lsp.config("nil_ls", {
            settings = {
                ["nil"] = {
                    formatting = {
                        command = { "nixfmt" },
                    },
                },
            },
        })

        vim.lsp.config("cssls", {
            filetypes = {
                "css",
                "scss",
            },
        })

        vim.lsp.config("pyright", {
            settings = {
                python = {
                    analysis = {
                        typeCheckingMode = "basic",
                        diagnosticMode = "workspace",
                    },
                },
            },
        })

        vim.lsp.enable("nushell")
    end,
}
