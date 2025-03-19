-- Konfiguracja dla języka Bash
local M = {}

-- Określenie narzędzi potrzebnych dla Bash
local tools = {
    "bash-language-server",  -- LSP
    "shellcheck",           -- Linter
    "shfmt",                -- Formatter
}

-- Rejestracja narzędzi do instalacji przez mason-tool-installer
if register_language_tools then
    register_language_tools(tools)
end

-- Konfiguracja serwerów LSP
M.servers = {
    bashls = {
        filetypes = { "sh", "bash" },
        settings = {
            bashIde = {
                globPattern = "*@(.sh|.inc|.bash|.command)",
                backgroundAnalysisMaxFiles = 500,
            },
        },
        on_attach = function(client, bufnr)
            -- Najpierw wywołaj domyślny on_attach
            lsp_default_on_attach(client, bufnr)
            
            -- Wyłącz formatowanie LSP - używamy shfmt przez conform.nvim
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end,
    }
}

-- Rejestruj server LSP jeśli funkcja jest dostępna
if register_lsp then
    register_lsp("bashls", M.servers.bashls)
end

-- Rejestruj formatery jeśli funkcja jest dostępna
if register_formatters then
    register_formatters("sh", { "shfmt" })
    register_formatters("bash", { "shfmt" })
end

-- Rejestruj lintery jeśli funkcja jest dostępna
if register_linters then
    register_linters("sh", { "shellcheck" })
    register_linters("bash", { "shellcheck" })
end

-- Upewnij się, że treesitter jest skonfigurowany dla języka
local has_treesitter, treesitter = pcall(require, "nvim-treesitter.configs")
if has_treesitter then
    local configs = treesitter.get_module("ensure_installed")
    if configs and type(configs) == "table" then
        table.insert(configs, "bash")
    end
end

return M
