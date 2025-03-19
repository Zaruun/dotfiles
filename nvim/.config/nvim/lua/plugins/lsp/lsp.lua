return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        opts = {
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
        },
        config = function(_, opts)
            require("mason").setup(opts)
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        lazy = false,
        config = function()
            require("mason-lspconfig").setup({
                -- Automatyczne pobieranie LSP zdefiniowanych w plikach językowych
                automatic_installation = true,
            })
        end
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            "williamboman/mason.nvim",
        },
        lazy = false,
        config = function()
            -- Zbieramy narzędzia z modułów językowych
            local registry = {}

            -- Funkcja do rejestrowania narzędzi z modułów językowych
            function _G.register_language_tools(tools)
                for _, tool in ipairs(tools) do
                    table.insert(registry, tool)
                end
            end

            -- Instrukcje dla każdego modułu językowego do rejestracji narzędzi
            for _, lang_file in ipairs(vim.fn.glob("lua/plugins/lang/*.lua", false, true)) do
                local lang_module = string.match(lang_file, "lua/plugins/lang/(.+)%.lua$")
                if lang_module then
                    -- Próbuj załadować moduł i pobrać narzędzia
                    pcall(function()
                        require("plugins.lang." .. lang_module)
                    end)
                end
            end

            -- Konfiguracja mason-tool-installer z zebranymi narzędziami
            require("mason-tool-installer").setup({
                ensure_installed = registry,
                auto_update = true,
                run_on_start = true,
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            "folke/neodev.nvim",
        },
        lazy = false,
        config = function()
            -- Konfiguracja neodev dla LuaLS
            require("neodev").setup({})

            -- Ikony dla diagnostyki
            local signs = {
                { name = "DiagnosticSignError", text = "" },
                { name = "DiagnosticSignWarn", text = "" },
                { name = "DiagnosticSignHint", text = "" },
                { name = "DiagnosticSignInfo", text = "" },
            }

            for _, sign in ipairs(signs) do
                vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
            end

            -- Konfiguracja diagnostyki
            vim.diagnostic.config({
                virtual_text = true,
                signs = { active = signs },
                update_in_insert = false,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })

            -- Konfiguracja okien podpowiedzi
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover,
                { border = "rounded" }
            )

            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                vim.lsp.handlers.signature_help,
                { border = "rounded" }
            )

            -- Standardowa konfiguracja dla wszystkich LSP
            local on_attach = function(client, bufnr)
                -- Skróty klawiaturowe dla LSP
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
                end

                -- Domyślne mappingi
                map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
                map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
                map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
                map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
                map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
                map("K", vim.lsp.buf.hover, "Hover Documentation")
                map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                -- Wyłącz formatowanie LSP jeśli używamy conform
                if vim.fn.exists(":ConformInfo") > 0 then
                    client.server_capabilities.documentFormattingProvider = false
                    client.server_capabilities.documentRangeFormattingProvider = false
                end
            end

            -- Domyślne capabilities dla wszystkich LSP
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Funkcja rejestrująca LSP dostępna globalnie dla modułów językowych
            function _G.register_lsp(server_name, opts)
                opts = opts or {}
                opts.on_attach = opts.on_attach or on_attach
                opts.capabilities = opts.capabilities or capabilities

                require("lspconfig")[server_name].setup(opts)
            end

            -- Zmienne globalne dostępne dla wszystkich modułów językowych
            _G.lsp_default_on_attach = on_attach
            _G.lsp_default_capabilities = capabilities

            -- Automatyczne wczytywanie konfiguracji LSP z modułów językowych
            -- Każdy moduł powinien używać register_lsp() do konfiguracji własnego LSP
            require("mason-lspconfig").setup_handlers({
                function(server_name)
                    -- Sprawdź czy mamy dedykowaną konfigurację dla tego języka
                    local has_custom_config = false
                    for _, lang_file in ipairs(vim.fn.glob("lua/plugins/lang/*.lua", false, true)) do
                        local lang_module = string.match(lang_file, "lua/plugins/lang/(.+)%.lua$")
                        if lang_module then
                            local ok, module = pcall(require, "plugins.lang." .. lang_module)
                            if ok and module and module.servers and module.servers[server_name] then
                                has_custom_config = true
                                break
                            end
                        end
                    end

                    -- Jeśli nie ma dedykowanej konfiguracji, użyj domyślnej
                    if not has_custom_config then
                        register_lsp(server_name)
                    end
                end,
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        dependencies = { "mason.nvim" },
        lazy = true,
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true, lsp_fallback = true })
                end,
                desc = "Format document",
            },
        },
        opts = {
            formatters_by_ft = {},
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        },
        config = function(_, opts)
            -- Funkcja globalna do rejestracji formaterów dla języków
            function _G.register_formatters(ft, formatters)
                opts.formatters_by_ft[ft] = formatters
            end

            require("conform").setup(opts)
        end,
    },
    {
        "mfussenegger/nvim-lint",
        lazy = true,
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")
            
            -- Funkcja globalna do rejestracji linterów dla języków
            function _G.register_linters(ft, linters)
                lint.linters_by_ft[ft] = linters
            end
            
            -- Auto-linting
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end,
    },
}
