---@module "lazy"
---@type LazySpec
return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "petertriho/cmp-git",
        {
            "saadparwaiz1/cmp_luasnip",
            dependencies = {
                "L3MON4D3/LuaSnip",
            },
        },
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            sources = {
                { name = "path", priority = 200 },
                { name = "cmp_git", priority = 150 },
                { name = "lazydev", priority = 120, group_index = 0 },
                { name = "nvim_lsp", priority = 100 },
                { name = "nvim_lua", priority = 100 },
                { name = "luasnip", priority = 50 },
                { name = "buffer", priority = 10, keyword_length = 3 },
            },
            completion = {
                --completeopt = "menu,menuone",
                keyword_length = 2,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.confirm({
                            behavior = cmp.ConfirmBehavior.Replace,
                            select = true,
                        })
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
        })

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "buffer" },
            }),
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "nvim_lua" },
                { name = "cmdline" },
                { name = "path" },
            }),
        })

        cmp.setup.filetype("gitcommit", {
            sources = cmp.config.sources({
                { name = "git" },
                { name = "buffer" },
            }),
        })
    end,
}
