return{
    { 
        'echasnovski/mini.pairs', 
        version = '*', 
        event = "VeryLazy",
        config = function()
            require("mini.pairs").setup()
        end, 
    },
    { 
        'echasnovski/mini.ai', 
        version = '*', 
        event = "VeryLazy",
        config = function()
            require("mini.ai").setup()
        end, 
    },
    { 
        'echasnovski/mini.indentscope', 
        version = '*', 
        event = "VeryLazy",
        config = function()
            require("mini.indentscope").setup()
        end, 
    },
    {
        "echasnovski/mini.statusline",
        version = "*",
        config = function()
            require("mini.statusline").setup({ use_icons = vim.g.have_nerd_font })
        end,
    },
    {
        "echasnovski/mini.surround",
        event = "VeryLazy",
        opts = {},
        config = function()
            require("mini.surround").setup()
        end,
    },
    {
        "echasnovski/mini.comment",
        event = "VeryLazy",
        opts = {},
        config = function()
            require("mini.comment").setup()
        end,
    },
}

