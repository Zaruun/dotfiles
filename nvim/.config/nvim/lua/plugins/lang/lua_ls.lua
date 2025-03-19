-- Konfiguracja dla języka Lua
local M = {}

-- Określenie narzędzi potrzebnych dla Lua
local tools = {
    "lua-language-server",  -- LSP
    "stylua",               -- Formatter
    "luacheck",             -- Linter
}

-- Rejestracja narzędzi do instalacji przez mason-tool-installer
if register_language_tools then
    register_language_tools(tools)
end

-- Konfiguracja serwerów LSP
M.servers = {
    lua_ls = {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                diagnostics = {
                    globals = { 
                        "vim", 
                        "require",
                        -- Dla testowania
                        "describe", 
                        "it", 
                        "before_each", 
                        "after_each",
                        -- Dla konfiguracji Neovim
                        "use",
                    },
                },
                workspace = {
                    library = {
                        vim.env.VIMRUNTIME,
                        "${3rd}/luv/library",
                        "${3rd}/busted/library",
                        -- Pomaga z pluginami
                        "~/.local/share/nvim/lazy",
                    },
                    checkThirdParty = false,
                },
                completion = {
                    callSnippet = "Replace",
                },
                telemetry = {
                    enable = false,
                },
            },
        },
        on_attach = function(client, bufnr)
            -- Najpierw wywołaj domyślny on_attach
            lsp_default_on_attach(client, bufnr)
            
            -- Wyłącz formatowanie LSP - używamy stylua przez conform.nvim
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end,
    }
}

-- Rejestruj server LSP jeśli funkcja jest dostępna
if register_lsp then
    register_lsp("lua_ls", M.servers.lua_ls)
end

-- Rejestruj formatery jeśli funkcja jest dostępna
if register_formatters then
    register_formatters("lua", { "stylua" })
end

-- Rejestruj lintery jeśli funkcja jest dostępna
if register_linters then
    register_linters("lua", { "luacheck" })
end

-- Upewnij się, że treesitter jest skonfigurowany dla języka
local has_treesitter, treesitter = pcall(require, "nvim-treesitter.configs")
if has_treesitter then
    local configs = treesitter.get_module("ensure_installed")
    if configs and type(configs) == "table" then
        table.insert(configs, "lua")
        table.insert(configs, "luadoc")
    end
end

return M
