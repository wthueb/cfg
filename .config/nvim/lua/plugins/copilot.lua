return {
    {
        "github/copilot.vim",
        config = function()
            vim.g.copilot_no_tab_map = true
            vim.keymap.set("i", "<S-Tab>", [[copilot#Accept("")]],
                { silent = true, expr = true, replace_keycodes = false, desc = "Accept copilot suggestion" })
        end
    }
}
