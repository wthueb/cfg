---@module "lazy"
---@type LazySpec
return {
    "nickjvandyke/opencode.nvim",
    dependencies = {
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
        local opencode_cmd = "opencode --port"

        ---@type snacks.terminal.Opts
        local snacks_terminal_opts = {
            win = {
                position = "right",
                enter = false,
                on_win = function(win)
                    require("opencode.terminal").setup(win.win)
                end,
            },
        }

        ---@type opencode.Opts
        vim.g.opencode_opts = {
            server = {
                start = function()
                    require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
                end,
                stop = function()
                    require("snacks.terminal").get(opencode_cmd, snacks_terminal_opts):close()
                end,
                toggle = function()
                    require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
                end,
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
