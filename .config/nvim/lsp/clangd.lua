local cmp_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_lsp.default_capabilities()

vim.lsp.config('clangd', {
	capabilities = capabilities,
})
