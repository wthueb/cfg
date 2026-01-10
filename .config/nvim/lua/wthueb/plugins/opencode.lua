---@module "lazy"
---@type LazySpec
return {
    "NickvanDyke/opencode.nvim",
    dependencies = {
        ---@module "snacks"
        ---@type LazySpec
        {
            "folke/snacks.nvim",
            ---@type snacks.Config
            opts = {
                input = {},
                picker = {},
                terminal = {},
            },
        },
    },
    config = function()
        ---@module "opencode"
        ---@type opencode.Opts
        vim.g.opencode_opts = {
            provider = {
                enabled = "snacks",
                --enabled = "wezterm",
                --wezterm = {
                --    direction = "left",
                --},
            },
        }

        vim.o.autoread = true

        vim.keymap.set({ "n", "x" }, "<leader>oa", function()
            require("opencode").ask(nil, { submit = true })
        end, { desc = "Ask opencode" })
        vim.keymap.set({ "n", "x" }, "<leader>os", function()
            require("opencode").select()
        end, { desc = "Execute opencode action…" })
        vim.keymap.set({ "n", "t" }, "<leader>oo", function()
            require("opencode").toggle()
        end, { desc = "Toggle opencode" })

        vim.keymap.set({ "n", "x" }, "go", function()
            return require("opencode").operator("@this ")
        end, { expr = true, desc = "Add range to opencode" })
        vim.keymap.set("n", "goo", function()
            return require("opencode").operator("@this ") .. "_"
        end, { expr = true, desc = "Add line to opencode" })

        vim.keymap.set("n", "<S-C-u>", function()
            require("opencode").command("session.half.page.up")
        end, { desc = "opencode half page up" })
        vim.keymap.set("n", "<S-C-d>", function()
            require("opencode").command("session.half.page.down")
        end, { desc = "opencode half page down" })
    end,
}
