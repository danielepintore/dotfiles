return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim', opts = {} },
            'williamboman/mason-lspconfig.nvim',
        },
        config = function()
            vim.diagnostic.config({ float = { border = 'rounded' }, virtual_text = false })

            -- Define Servers
            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                -- Recognize the `vim` global variable
                                globals = { "vim" }
                            },
                            workspace = {
                                -- Make the server aware of Neovim runtime files
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            telemetry = {
                                enable = false,
                            },
                        }
                    }
                },
                pylsp = {},
                ts_ls = {},
                rust_analyzer = {},
                eslint = {},
                clangd = {},
            }

            -- Prepare Native Capabilities
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true

            -- Setup Servers
            require('mason-lspconfig').setup({
                ensure_installed = vim.tbl_keys(servers),
                handlers = {
                    function(server_name)
                        local opts = servers[server_name] or {}
                        opts.capabilities = capabilities
                        vim.lsp.config(server_name, opts)
                        vim.lsp.enable(server_name)
                    end,
                },
            })

            -- LspAttach (Keybindings & Activation)
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    local client = vim.lsp.get_client_by_id(ev.data.client_id)

                    if client and client:supports_method('textDocument/completion') then
                        vim.lsp.completion.enable(true, client.id, ev.buf, {
                            autotrigger = true,
                            autoselect = false,
                        })
                    end

                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
                    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)

--                    vim.keymap.set('i', '<CR>', function()
--                        return vim.fn.pumvisible() ~= 0 and '<C-y>' or '<CR>'
--                    end, { expr = true, buffer = ev.buf })
--
--                     vim.keymap.set('i', '<Tab>', function()
--                         return vim.fn.pumvisible() ~= 0 and '<C-n>' or '<Tab>'
--                     end, { expr = true, buffer = ev.buf })
-- 
--                     vim.keymap.set('i', '<S-Tab>', function()
--                         return vim.fn.pumvisible() ~= 0 and '<C-p>' or '<S-Tab>'
--                     end, { expr = true, buffer = ev.buf })

                    vim.keymap.set('i', '<C-k>', function()
                        vim.api.nvim_feedkeys(
                            vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true),
                            'n', false
                        )
                    end, { buffer = ev.buf })


                    -- Check if the server supports signature help and show function
                    -- signature when typing
                    -- Inside LspAttach:
                    -- if client and client:supports_method('textDocument/signatureHelp') then
                    --     -- Wrap the CursorMovedI in a group to prevent duplicates
                    --     local sig_group = vim.api.nvim_create_augroup('UserSignatureHelp', { clear = false })
                    --     vim.api.nvim_clear_autocmds({ group = sig_group, buffer = ev.buf })

                    --     vim.api.nvim_create_autocmd("CursorMovedI", {
                    --         group = sig_group,
                    --         buffer = ev.buf,
                    --         callback = function()
                    --             pcall(vim.lsp.buf.signature_help, { focusable = false, silent = true })
                    --         end,
                    --     })
                    -- end
                end,
            })
        end,
    }
}
