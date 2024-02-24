-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.2',
		-- or                            , branch = '0.1.x',
		requires = { { 'nvim-lua/plenary.nvim' } }
	}

	use({
		"catppuccin/nvim",
		as = "catppuccin",
		config = function()
			require('catppuccin').setup({
				term_colors = false,
				transparent_background = true,
				styles = {
					comments = {},
					conditionals = {},
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
				},

				--[[color_overrides = {
			  mocha = {
				  base = "#000000",
				  mantle = "#000000",
				  crust = "#000000",
			  },
		  } ]] --
			})

			-- set the colorscheme
			vim.cmd('colorscheme catppuccin')
		end
	})

	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate'
	}

	use("ThePrimeagen/harpoon")

	use("mbbill/undotree")

	use("tpope/vim-fugitive")

	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'dev-v3',
		requires = {
			--- Uncomment these if you want to manage LSP servers from neovim
			{ 'williamboman/mason.nvim' },
			{ 'williamboman/mason-lspconfig.nvim' },
			---

			-- LSP Support
			{ 'neovim/nvim-lspconfig' },
			-- Autocompletion
			{ 'hrsh7th/nvim-cmp' },
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'L3MON4D3/LuaSnip' },
		}
	}

	-- Github copilot
	use("github/copilot.vim")

	-- For navigation between vim and tmux
	use("christoomey/vim-tmux-navigator")

	-- Per project custom lsp config
	use("folke/neoconf.nvim")
	use { "vimwiki/vimwiki",
		config = function()
			-- Restrict vimwiki to only the path specified in the vimwiki_list global var
			vim.g.vimwiki_global_ext = 0
			-- Configure a list of vimwiki wiki, need a :PackerCompile to apply
			vim.g.vimwiki_list = {
				{
					path = '~/Documents/cybersecurity/wiki/',
					syntax = 'markdown',
					ext = '.md',
				},
			}
		end,
	}
end)
