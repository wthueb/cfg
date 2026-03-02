---@module "lazy"
---@type LazySpec
return {
    {
        "mrcjkb/rustaceanvim",
        lazy = false,
        version = "^8",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        ft = { "rust" },
        config = function()
            ---@type rustaceanvim.dap.Config
            local dap_config = {}

            if vim.uv.os_uname().sysname == "Darwin" then
                dap_config = {
                    adapter = {
                        type = "executable",
                        command = "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb-dap",
                    },
                }
            end

            ---@module "rustaceanvim"
            ---@type rustaceanvim.Config
            vim.g.rustaceanvim = {
                server = {
                    default_settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                features = "all",
                            },
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
                },
                dap = dap_config,
            }
        end,
    },
    {
        "saecki/crates.nvim",
        tag = "stable",
        opts = {},
        ft = "toml",
    },
}
