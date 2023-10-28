return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    config = function()
        require("todo-comments").setup({
            -- keywords = {
            --     TODO = { alt = { "todo" } },
            -- },
            -- pattern = [[(\b(KEYWORDS):)|todo!]]
            -- todo!("test")
            -- TODO: testing
            keywords = {
                TODO = { alt = { "todo", "unimplemented" } },
            },
            highlight = {
                pattern = {
                    [[<(KEYWORDS)\s*:]],
                    [[<(todo|unimplemented)!]],
                },
                comments_only = false,
            },
            search = {
                pattern = [[\b((KEYWORDS)\s*:|\b(todo|unimplemented)!)]],
            },
        })
    end,
}
