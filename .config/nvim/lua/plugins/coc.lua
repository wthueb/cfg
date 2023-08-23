return {
    {
        "neoclide/coc.nvim",
        branch = "master",
        build = "yarn install --frozen-lockfile",
        config = function()
            vim.opt.updatetime = 100
            vim.g.coc_global_extensions = {
                "coc-css",
                "coc-html",
                "coc-json",
                "coc-lua",
                "coc-pyright",
                "coc-sh",
                "coc-tsserver",
                "coc-vimlsp",
                "coc-yaml",
            }

            local map = require("keys").map

            map("n", "<leader>f", "<Plug>(coc-format)", "Format current file")
            map("v", "<leader>f", "<Plug>(coc-format-selected)", "Format selection")

            map("n", "<leader>r", "<Plug>(coc-rename)", "Rename symbol")

            map("n", "gd", "<Plug>(coc-definition)", "Go to definition")
            map("n", "gi", "<Plug>(coc-implemention)", "Go to implementation")
            map("n", "gr", "<Plug>(coc-references)", "See references")
        end
    }
}
