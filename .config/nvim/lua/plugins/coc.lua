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

            -- returns true if we're on the beginning of the line
            -- or the character prior to the cursor is a space/tab
            local function should_indent()
                local col = vim.fn.col(".") - 1
                return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
            end

            local opts = { silent = true, remap = false, expr = true }

            vim.keymap.set("i", "<Tab>", function()
                if vim.fn['coc#pum#visible']() == 1 then
                    return vim.fn['coc#pum#confirm']()
                end
                if should_indent() then
                    return "<Tab>"
                end
                return vim.fn['coc#refresh']()
            end, opts)
            vim.keymap.set("i", "<CR>", function()
                if vim.fn['coc#pum#visible']() == 1 then
                    return vim.fn['coc#pum#confirm']();
                end
                return "<CR>"
            end, opts)

            map("n", "<leader>f", "<Plug>(coc-format)", "Format current file")
            map("v", "<leader>f", "<Plug>(coc-format-selected)", "Format selection")

            map("n", "<leader>r", "<Plug>(coc-rename)", "Rename symbol")

            map("n", "gd", "<Plug>(coc-definition)", "Go to definition")
            map("n", "gi", "<Plug>(coc-implemention)", "Go to implementation")
            map("n", "gr", "<Plug>(coc-references)", "See references")

            map("n", "[e", "<Plug>(coc-diagnostic-prev)", "Go to previous diagnostic")
            map("n", "]e", "<Plug>(coc-diagnostic-next)", "Go to next diagnostic")

            map("n", "K", function()
                local cw = vim.fn.expand('<cword>')
                if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
                    vim.api.nvim_command('h ' .. cw)
                elseif vim.api.nvim_eval('coc#rpc#ready()') then
                    vim.fn.CocActionAsync('doHover')
                else
                    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
                end
            end, "Show docs of symbol")

            -- scroll floating windows
            opts = { silent = true, nowait = true, expr = true }
            vim.keymap.set("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
            vim.keymap.set("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
            vim.keymap.set("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
            vim.keymap.set("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
            vim.keymap.set("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
            vim.keymap.set("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
        end
    }
}
