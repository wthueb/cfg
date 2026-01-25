---@module "lazy"
---@type LazySpec
return {
    "cbochs/grapple.nvim",
    opts = {
        scope = "static",
    },
    keys = {
        { "<leader>a", "<cmd>Grapple toggle<CR>", desc = "Grapple tag current buffer", silent = true },
        { "<C-h>", "<cmd>Grapple toggle_tags<CR>", desc = "Grapple show tags", silent = true },
        { "<C-j>", "<cmd>Grapple select index=1<CR>", desc = "Grapple goto tag 1", silent = true },
        { "<C-k>", "<cmd>Grapple select index=2<CR>", desc = "Grapple goto tag 2", silent = true },
        { "<C-l>", "<cmd>Grapple select index=3<CR>", desc = "Grapple goto tag 3", silent = true },
        { "<C-1>", "<cmd>Grapple select index=1<CR>", desc = "Grapple goto tag 1", silent = true },
        { "<C-2>", "<cmd>Grapple select index=2<CR>", desc = "Grapple goto tag 2", silent = true },
        { "<C-3>", "<cmd>Grapple select index=3<CR>", desc = "Grapple goto tag 3", silent = true },
        { "<C-4>", "<cmd>Grapple select index=4<CR>", desc = "Grapple goto tag 4", silent = true },
        { "<C-5>", "<cmd>Grapple select index=5<CR>", desc = "Grapple goto tag 5", silent = true },
        { "<C-6>", "<cmd>Grapple select index=6<CR>", desc = "Grapple goto tag 6", silent = true },
        { "<C-7>", "<cmd>Grapple select index=7<CR>", desc = "Grapple goto tag 7", silent = true },
        { "<C-8>", "<cmd>Grapple select index=8<CR>", desc = "Grapple goto tag 8", silent = true },
        { "<C-9>", "<cmd>Grapple select index=9<CR>", desc = "Grapple goto tag 9", silent = true },
        { "<C-0>", "<cmd>Grapple select index=10<CR>", desc = "Grapple goto tag 10", silent = true },
    },
}
