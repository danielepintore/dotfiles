return {
	{ "vimwiki/vimwiki",
	init = function()
		-- Restrict vimwiki to only the path specified in the vimwiki_list global var
		vim.g.vimwiki_global_ext = 0
		-- Configure a list of vimwiki wiki
		vim.g.vimwiki_list = {
			{
				path = '~/Documents/cybersecurity/wiki/',
				path_html = '~/Documents/cybersecurity/wiki/dist',
				template_path = '~/.config/vimwiki/templates/cybersecurity/',
				template_default = 'default',
				template_ext = 'html',
				css_name = 'css/styles.css',
				syntax = 'markdown',
				ext = '.md',
				custom_wiki2html = '~/.config/vimwiki/parse_wiki.py',
			},
		}
	end,
	}
}
