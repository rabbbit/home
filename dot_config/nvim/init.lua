-- Plugins {{{1

-- Setup plugin loader {{{2
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = ' ' -- space is leader

require('lazy').setup({
	-- Completion and snippets {{{2
	'andersevenrud/cmp-tmux',
	'honza/vim-snippets',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-cmdline',
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/cmp-nvim-lsp-signature-help',
	'hrsh7th/cmp-omni',
	'hrsh7th/cmp-path',
	'hrsh7th/nvim-cmp',
	'quangnguyen30192/cmp-nvim-ultisnips',
	'SirVer/ultisnips',

	-- Editing {{{2
	{
		'echasnovski/mini.nvim',
		version = false,
		config = function()
			require('mini.align').setup()
			require('mini.comment').setup()
			require('mini.jump').setup({
				-- Already repeats with 'f' and 't'.
				-- Leave this free for treesitter.
				repeat_jump = '',
			})
			require('mini.surround').setup()
			require('mini.trailspace').setup()
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter-textobjects', -- {{{3
		config = function()
			local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
			vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
			vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
		end,
	},
	{
		'mg979/vim-visual-multi', -- {{{3
		keys = {
			{'<M-S-j>', '<Plug>(VM-Add-Cursor-Down)', 'n', desc = "Add cursor (down)"},
			{'<M-S-k>', '<Plug>(VM-Add-Cursor-Up)', 'n', desc = "Add cursor (up)"},
			{'<C-n>', '<Plug>(VM-Find-Under)', {'n', 'v'}, desc = "Add cursor (matching)"},
			{'<S-Right>', '<Plug>(VM-Select-l)', 'n', desc = "Select (right)"},
			{'<S-Left>', '<Plug>(VM-Select-h)', 'n', desc = "Select (left)"},
			{'\\A', '<Plug>(VM-Visual-All)', 'n', desc = "Select all matching"},
			{'\\/', '<Plug>(VM-Visual-Regex)', 'n', desc = "Select all matching regex"},
			{'\\f', '<Plug>(VM-Visual-Find)', 'n', desc = "Select all matching '/' register"},
		},
	},
	'machakann/vim-highlightedyank',
	{
		'nvim-treesitter/nvim-treesitter', -- {{{3
		build = ':TSUpdate',
		dependencies = {'nvim-treesitter/nvim-treesitter-textobjects'},
		config = function()
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*",
				callback = function()
					local buf = vim.api.nvim_get_current_buf()
					local highlighter = require("vim.treesitter.highlighter")
					if highlighter.active[buf] then
						-- If treesitter is enabled for
						-- the current buffer,
						-- use it also for folding.
						vim.wo.foldmethod = 'expr'
						vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
						vim.wo.foldlevel = 5
						vim.wo.foldenable = false
					end
				end,
			})
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter-context',
		dependencies = {'nvim-treesitter/nvim-treesitter'},
		config = function()
			require('treesitter-context').setup {
				enable = true,
			}
		end,
	},
	{'tpope/vim-abolish', command = "S"},
	'tpope/vim-repeat',
	'tpope/vim-sleuth',
	'vim-scripts/visualrepeat',
	'wsdjeg/vim-fetch',

	-- Filetype-specific {{{2
	'alker0/chezmoi.vim',
	{'cappyzawa/starlark.vim', ft = 'starlark'},
	'direnv/direnv.vim',
	{'habamax/vim-asciidoctor', ft = {'asciidoc', 'asciidoctor'}},
	{
		'iamcco/markdown-preview.nvim', -- {{{3
		ft = 'markdown',
		build = function()
			vim.fn['mkdp#util#install']()
		end,
		config = function()
			vim.g.mkdp_auto_close = 0
			vim.g.mkdp_filetypes = {'markdown'}
		end,
	},
	{'lervag/wiki.vim', ft = 'markdown'},
	{'NoahTheDuke/vim-just', ft = 'just'},
	{
		'rafaelsq/nvim-goc.lua',
		ft = 'go',
		config = function()
			require('nvim-goc').setup()
		end,
	},
	{'rust-lang/rust.vim', ft = 'rust'},
	{'vim-pandoc/vim-pandoc-syntax', ft = {'markdown', 'pandoc'}},
	{'ziglang/zig.vim', ft = {'zig'}},

	-- Git {{{2
	{'rhysd/git-messenger.vim', keys = '<leader>gm'},
	{
		'tpope/vim-fugitive', -- {{{3
		dependencies = {'tpope/vim-rhubarb'},
		cmd = {"G", "Git", "GBrowse", "GRename"},
	},

	-- Look and feel {{{2
	'edkolev/tmuxline.vim',
	{
		'justinmk/molokai', -- {{{3
		lazy = false,
		priority = 1000,
	},
	{
		'vim-airline/vim-airline', -- {{{3
		dependencies = {'vim-airline/vim-airline-themes'},
		config = function()
			vim.cmd [[
				let g:airline_theme = "molokai"
				let g:airline#extensions#branch#displayed_head_limit = 10

				" We want to do this manually with,
				"   :Tmuxline airline | TmuxlineSnapshot ~/.tmux-molokai.conf
				let g:airline#extensions#tmuxline#enabled = 0
			]]
		end,
	},

	-- LSP and language features {{{2
	'folke/trouble.nvim',
	{
		'neovim/nvim-lspconfig', -- {{{3
		dependencies = {
			'folke/lsp-colors.nvim',
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
		},
		-- Table of options for each language server.
		-- Items can be key-value pairs to specify configuration,
		-- and strings to use default configuration.
		-- The configuration can be a function.
		opts = {
			gopls = function()
				if vim.env.VIM_GOPLS_DISABLED then
					return nil
				end

				local init_opts = {
					gofumpt = not vim.env.VIM_GOPLS_NO_GOFUMPT,
					staticcheck = true,
				}
				if vim.env.VIM_GOPLS_BUILD_TAGS then
					init_opts.buildFlags = {
						'-tags', vim.env.VIM_GOPLS_BUILD_TAGS,
					}
				end

				return {
					cmd = {'gopls', '-remote=auto'},
					init_options = init_opts,
				}
			end,
			omnisharp = {optional = true},
			'pylsp',
			rust_analyzer = {
				settings = {
					['rust-analyzer'] = {
						completion = {
							postfix = {
								enable = false,
							},
						},
						checkOnSave = {
							command = "clippy",
						},
					},
				},
			},
			tsserver = {
				init_options = {
					disableAutomaticTypingAcquisition = true,
				},
			},
			'zls',
		},
		config = function(_, opts)
			local nvim_lsp = require('lspconfig')
			local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

			ensure_installed = {}
			for name, cfg in pairs(opts) do
				if type(name) == "number" then
					name = cfg
					cfg = {}
				end
				if type(cfg) == "function" then
					cfg = cfg()
				end
				if cfg ~= nil then
					cfg.capabilities = lsp_capabilities
					cfg.flags = {
						-- Don't spam LSP with changes. Wait a second between updates.
						debounce_text_changes = 1000,
					}
					opts[name] = cfg
					if not cfg.optional then
						table.insert(ensure_installed, name)
					end
				end
			end

			local mason_lspconfig = require('mason-lspconfig')
			mason_lspconfig.setup({
				ensure_installed = ensure_installed,
			})
			mason_lspconfig.setup_handlers({
				function(name)
					local cfg = opts[name]
					if cfg ~= nil then
						nvim_lsp[name].setup(opts[name])
					end
				end
			})
		end,
	},
	{
		'jose-elias-alvarez/null-ls.nvim', -- {{{3
		dependencies = {
			'nvim-lua/plenary.nvim',
			'williamboman/mason.nvim',
		},
		config = function()
			local null_ls = require('null-ls')
			null_ls.setup({
				sources = {
					null_ls.builtins.code_actions.shellcheck,
					null_ls.builtins.diagnostics.shellcheck,
					null_ls.builtins.formatting.jq,
					null_ls.builtins.formatting.shfmt,
				},
			})
		end,
	},
	{
		'williamboman/mason.nvim',
		opts = {
			ensure_installed = {
				'shellcheck', 'shfmt',
				'jq',
			},
		},
		config = function(_, opts)
			require('mason').setup(opts)

			local mr = require('mason-registry')
			for _, tool in ipairs(opts.ensure_installed) do
				local p = mr.get_package(tool)
				if not p:is_installed() then
					p:install()
				end
			end
		end,
	},

	-- Navigation and window management {{{2
	{
		'camspiers/lens.vim', -- {{{3
		config = function()
			vim.g['lens#disabled_buftypes'] = {'quickfix'}
			vim.g['lens#animate']           = 0
		end,
	},
	'justinmk/vim-dirvish',
	{
		'mhinz/vim-grepper', -- {{{3
		config = function()
			vim.g.grepper = {
				tools        = {'rg', 'ag', 'git'},
				side         = 1,
				side_cmd     = 'new',
				prompt_text  = '$t> ',
				prompt_quote = 2,
				quickfix     = 1,
				switch       = 1,
				jump         = 0,
				dir          = 'filecwd',
				prompt_mapping_tool = '<leader>g',
			}
		end,
		keys = {
			{'<leader>gg', ':Grepper<cr>', 'n', noremap = true, desc = "Grepper (interactive)"},
			{'gs', '<plug>(GrepperOperator)', {'n', 'x'}, desc = "Grepper (operator)"},
		},
	},
	{
		'nvim-telescope/telescope.nvim', -- {{{3
		tag = '0.1.1',
		dependencies = {'nvim-lua/plenary.nvim'},
	},
	'nvim-telescope/telescope-ui-select.nvim',
	'rbgrouleff/bclose.vim',
	{
		'folke/which-key.nvim', -- {{{3
		opts = {
			spelling = {
				enabled = true,
			},
			-- ignore_missing = false,
		},
		config = function(_, opts)
			local wk = require('which-key')
			wk.setup()

			wk.register({
				mode = {'n', 'v'},
				["<leader>f"] = {name = "+find"},
				["<leader>l"] = {
					name = "+language",
					g    = "+goto",
					f    = "+find",
				},
				["<leader>b"] = {name = "+buffer"},
				["<leader>t"] = {name = "+tabs"},
				["<leader>q"] = {name = "+quit"},
				["<leader>w"] = {name = "+windows"},
				["<leader>x"] = {name = "+diagnostics"},
			})
		end,
	},

	-- Terminal integration {{{2
	{
		'christoomey/vim-tmux-navigator', -- {{{3
		config = function()
			-- We'll use our own mappings.
			vim.g.tmux_navigator_no_mappings = 1
		end,
		keys = {
			{'<C-J>', ':TmuxNavigateDown', 'n', noremap = true, silent = true},
			{'<C-K>', ':TmuxNavigateUp', 'n', noremap = true, silent = true},
			{'<C-L>', ':TmuxNavigateRight', 'n', noremap = true, silent = true},
			{'<C-H>', ':TmuxNavigateLeft', 'n', noremap = true, silent = true},
		},
	},
	{
		'ojroques/vim-oscyank', -- {{{3
		config = function()
			-- oscyank {{{2
			-- https://github.com/ojroques/vim-oscyank/issues/26#issuecomment-1179722561
			vim.g.oscyank_term = 'default'

			-- Set up a hook to send an OSC52 code if the system register is used.
			vim.api.nvim_create_autocmd("TextYankPost", {
				pattern = "*",
				callback = function(args)
					local ev = vim.v.event
					if ev.operator == 'y' and ev.regname == '+' then
						vim.cmd.OSCYankReg('+')
					end
				end,
			})
		end,
	},
	'vim-utils/vim-husk',
	{
		'voldikss/vim-floaterm', -- {{{3
		build = 'pip install --upgrade neovim-remote',
		config = function()
			let_g('floaterm_', {
				keymap_prev   = '<F4>',
				keymap_next   = '<F5>',
				autoclose     = 1,
				wintype       = 'floating',
			})
		end,
		keys = {
			{'<F6>', ':FloatermNew --height=0.4 --width=0.98 --cwd=<buffer> --position=bottom<CR>', 'n', silent = true, noremap = true},
			{'<F9>', ':FloatermToggle<CR>', 'n', silent = true, noremap = true},
		},
	},
})

-- General {{{1
if vim.env.VIM_PATH then
	vim.env.PATH = vim.env.VIM_PATH
end

local options = {
	compatible = false, -- no backwards compatibility with vi

	backup      = false, -- don't backup edited files
	writebackup = true, -- but temporarily backup before overwiting

	backspace = {'indent', 'eol', 'start'}, -- sane backspace handling

	ruler      = true, -- show the cursor position
	laststatus = 2,    -- always show status line
	showcmd    = true, -- display incomplete commands
	hidden     = true, -- allow buffers to be hidden without saving

	history    = 50, -- history of : commands
	wildmenu = true, -- show options for : completion

	number         = true, -- show line number of the current line and
	relativenumber = true, -- relative numbers of all other lines

	-- Use 8 tabs for indentation.
	expandtab   = false,
	softtabstop = 0,
	shiftwidth  = 8,
	tabstop     = 8,

	textwidth   = 79,    -- default to narrow text
	virtualedit = 'all', -- use virtual spaces
	scrolloff   = 5,     -- lines below cursor when scrolling

	-- Preserve existing indentation as much as possible.
	copyindent     = true,
	preserveindent = true,
	autoindent     = true,

	incsearch = true, -- show search results incrementally
	wrap      = false, -- don't wrap long lines

	-- Don't add two spaces after a punctuation when joining lines with J.
	joinspaces = false,

	ignorecase = true,        -- ignore caing during search
	smartcase  = true,        -- except if uppercase characters were used
	tagcase    = 'followscs', -- and use the same for tag searches

	inccommand = 'split', -- show :s results incrementally
	hlsearch = true, -- highlight search results

	lazyredraw = true,  -- don't redraw while running macros
	visualbell = true, -- don't beep
	mouse = 'a', -- support mouse

	background = 'dark',

	-- New splits should go below or to the right of the current window.
	splitbelow = true,
	splitright = true,

	foldmethod = 'marker', -- don't fold unless there are markers

	-- Timeout for partial key sequences.
	-- Needed for which-key.
	timeout = true,
	timeoutlen = 500,

	-- Show tabs and trailing spaces.
	list = true,
	listchars = {tab = '» ', trail = '.'},

	-- Patterns to ignore in wildcard expansions.
	wildignore = {
		'*/cabal-dev', '*/dist', '*.o', '*.class', '*.pyc', '*.hi',
	},

	completeopt = {'noinsert', 'menuone', 'noselect', 'preview'},
}

for name, val in pairs(options) do
	vim.opt[name] = val
end

-- Use true colors if we're not on Apple Terminal.
if vim.env.TERM_PROGRAM ~= 'Apple_Terminal' then
	vim.opt.termguicolors = true
end

-- let_g(table)
-- let_g(prefix, table)
--
-- Sets values on g:*. If prefix is non-empty, it's added to every key.
function let_g(prefix, opts)
	if opts == nil then
		opts, prefix = prefix, ''
	end

	for key, val in pairs(opts) do
		if prefix ~= '' then
			key = prefix .. key
		end
		vim.g[key] = val
	end
end

vim.cmd [[
colorscheme molokai

" Use terminal background for performance.
highlight Normal ctermbg=NONE guibg=NONE

" Make line numbers in terminal more readable
highlight LineNr ctermfg=245

" Invisible vertical split
highlight VertSplit guibg=bg guifg=bg

" Add a line below the treesitter context.
hi TreesitterContextBottom gui=underline guisp=gray
]]

-- Quit
vim.keymap.set('n', '<leader>qq', ':qa<cr>', {desc = "Quit all"})

-- Disable ex mode from Q.
vim.keymap.set('n', 'Q', '<Nop>', {noremap = true})

-- Yank and paste operations preceded by <leader> should use system clipboard.
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', {
	noremap = true,
	desc = "Yank to clipboard",
})
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p', {
	noremap = true,
	desc = "Paste from clipboard (above)",
})
vim.keymap.set({'n', 'v'}, '<leader>P', '"+P', {
	noremap = true,
	desc = "Paste from clipboard (below)",
})

-- Split navigation inside :terminal
vim.keymap.set('t', '<C-M-J>', [[<C-\><C-n><C-W><C-J>]], {
	noremap = true,
	desc = 'Move to split below',
})
vim.keymap.set('t', '<C-M-K>', [[<C-\><C-n><C-W><C-K>]], {
	noremap = true,
	desc = 'Move to split above',
})
vim.keymap.set('t', '<C-M-L>', [[<C-\><C-n><C-W><C-L>]], {
	noremap = true,
	desc = 'Move to split right',
})
vim.keymap.set('t', '<C-M-H>', [[<C-\><C-n><C-W><C-H>]], {
	noremap = true,
	desc = 'Move to split left',
})

-- Clear highlight after search.
vim.keymap.set('n', '<CR>', ':nohlsearch<CR><CR>', {
	silent = true,
	noremap = true,
})

-- Edit the current vimrc
vim.keymap.set('n', '<leader>evf', ':e $MYVIMRC<cr>', {
	noremap = true,
	silent = true,
	desc = "Edit my vimrc",
})

-- Tab shortcuts
vim.keymap.set('n', '<leader>tt', ':tabnew<CR>', {
	desc = 'New tab',
	silent = true,
})
vim.keymap.set('n', '<leader>tn', ':tabnext<CR>', {
	desc = 'Next tab',
	silent = true,
})
vim.keymap.set('n', '<leader>tp', ':tabprev<CR>', {
	desc = 'Previous tab',
	silent = true,
})
vim.keymap.set('n', '<leader>td', ':tabclose<CR>', {
	desc = 'Close tab',
	silent = true,
})

-- Buffer shortcuts
vim.keymap.set('n', '<leader>bd', ':bd<CR>', {
	desc = "Delete buffer",
	silent = true,
})
vim.keymap.set('n', '<leader>bD', ':bd!<CR>', {
	desc = "Delete buffer (force)",
	silent = true,
})
vim.keymap.set('n', '<leader>bn', ':bn<CR>', {
	desc = "Next buffer",
	silent = true,
})
vim.keymap.set('n', '<leader>bN', ':bN<CR>', {
	desc = "Previous buffer",
	silent = true,
})

-- Window shortcuts
vim.keymap.set('n', '<leader>wd', '<C-W>c', {
	desc = "Delete window",
	silent = true,
})
vim.keymap.set('n', '<leader>wv', '<C-W>v', {
	desc = "Split window vertically",
	silent = true,
})
vim.keymap.set('n', '<leader>ws', '<C-W>s', {
	desc = "Split window horizontally",
	silent = true,
})
vim.keymap.set('n', '<leader>ws', '<C-W>o', {
	desc = "Hide all other windows",
	silent = true,
})

vim.cmd [[
" Don't show line numbers in terminal.
autocmd TermOpen * setlocal nonu nornu

" Auto-reload files {{{2

" Trigger :checktime when changing buffers or coming back to vim.
augroup AutoReload
	autocmd!
	autocmd FocusGained,BufEnter * :checktime
augroup end
]]

-- Neovide {{{2
if vim.g.neovide then
	vim.opt.guifont = "Iosevka Term:h10"
	let_g('neovide_', {
		cursor_animation_length = 0,
	})
end

--  Plugin {{{1

-- lspconfig {{{2

local function lsp_on_attach(client, bufnr)
	local function lsp_nmap(key, fn, desc)
		vim.keymap.set('n', key, fn, {
			noremap = true,
			silent = true,
			desc = desc,
		})
	end

	vim.bo.omnifunc =  'v:lua.vim.lsp.omnifunc'
	local opts = { noremap = true, silent = true }

	-- Keybindings
	--  K            Documentation
	--  gd           Go to definition
	--  Alt-Enter    Code action

	lsp_nmap('K', vim.lsp.buf.hover, "Documentation")
	lsp_nmap('gd', vim.lsp.buf.definition, "Go to definition")

	local telescopes = require('telescope.builtin')
	-- lgr  Language go-to references
	-- lgi  Language go-to implementation
	-- lfr  Language find references
	-- lfd  Language find definitions
	-- lfw  Language find workspace
	lsp_nmap('<leader>lgr', vim.lsp.buf.references, "Go to references")
	lsp_nmap('<leader>lgi', vim.lsp.buf.implementation, "Go to implementation")
	lsp_nmap('<leader>lfr', telescopes.lsp_references, "Find references")
	lsp_nmap('<leader>lfd', telescopes.lsp_document_symbols, "Find symbols (document)")
	lsp_nmap('<leader>lfw', telescopes.lsp_workspace_symbols, "Find symbols (workspace)")

	-- Mneomonics:
	-- cr   Code rename
	-- cf   Code format
	-- ca   Code action
	lsp_nmap('<leader>ca', vim.lsp.buf.code_action, "Code action")
	lsp_nmap('<leader>cf', vim.lsp.buf.format, "Reformat file")
	lsp_nmap('<leader>cr', vim.lsp.buf.rename, "Rename")
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local buffer = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		lsp_on_attach(client, buffer)
	end,
})

-- nvim-cmp {{{2
local cmp = require 'cmp'
local cmp_ultisnips_mappings = require 'cmp_nvim_ultisnips.mappings'

local handleTab = function(fallback)
	if cmp.visible() then
		if cmp.get_selected_entry() ~= nil then
			cmp.confirm()
		else
			cmp.select_next_item()
		end
	elseif vim.fn['UltiSnips#CanJumpForwards']() == 1 then
		cmp_ultisnips_mappings.jump_forwards(fallback)
	else
		fallback()
	end
end

cmp.setup {
	completion = {
		keyword_length = 3,
	},
	snippet = {
		expand = function(args)
			vim.fn["UltiSnips#Anon"](args.body)
		end,
	},
	preselect = cmp.PreselectMode.None,
	mapping = cmp.mapping.preset.insert({
		-- Ctrl-u/d: scroll docs of completion item if available.
		['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
		['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),

		-- tab: If completion menu is visible and nothing has been selected,
		-- select first item. If something is selected, start completion with that.
		-- If in the middle of the completion, jump to next snippet position.

		-- Tab/Shift-Tab:
		-- If completion menu is not visible,
		--  1. if we're in the middle of a snippet, move forwards/backwards
		--  2. Otherwise use regular key behavior
		--
		-- If completion menu is visible and,
		--  1. no item is selected, select the first/last one
		--  2. an item is selected, start completion with it
		['<Tab>'] = cmp.mapping({
			i = handleTab,
			s = handleTab,
		}),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif vim.fn['UltiSnips#CanJumpBackwards']() == 1 then
				cmp_ultisnips_mappings.jump_backwards(fallback)
			else
				fallback()
			end
		end, {'i', 's'}),

		-- Ctrl-Space: force completion
		['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),

		-- Ctr-e: cancel completion
		['<C-e>'] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),

		-- Enter: confirm completion
		['<CR>'] = cmp.mapping.confirm({select = false}),
	}),
	sources = cmp.config.sources({
		{name = 'nvim_lsp'},
		{name = 'nvim_lsp_signature_help'},
		{name = 'ultisnips'},
	}, {
		{name = 'path'},
		{name = 'buffer'},
		{name = 'tmux'},
	}),
}

cmp.setup.filetype('markdown', {
	sources = cmp.config.sources({
		{
			name = 'omni',
			trigger_characters = {"[["},
			keyword_length = 0,
			keyword_pattern = "\\w+",
		},
		{name = 'ultisnips'},
		{name = 'buffer'},
		{name = 'tmux'},
	}),
})

-- netrw {{{2
vim.g.netrw_liststyle = 3

-- telescope {{{2
local telescope = require('telescope')
local telescopes = require('telescope.builtin')
local teleactions = require('telescope.actions')
local telethemes = require('telescope.themes')
local teletrouble = require('trouble.providers.telescope')

telescope.setup {
	defaults = {
		mappings = {
			i = {
				-- Show help.
				["<C-h>"] = teleactions.which_key,
				-- Open in trouble.
				["<M-t>"] = teletrouble.open_with_trouble,
			},
		},
	},
	pickers = {
		buffers = {
			mappings = {
				i = {
					-- Ctrl-D in buffers to delete.
					["<C-d>"] = teleactions.delete_buffer,
				},
			},
		},
	},
	extensions = {
		["ui-select"] = {
			telethemes.get_dropdown {
			}
		},
	}
}

telescope.load_extension('ui-select')

-- All keys preceded by <leader>:
--
-- Mneomonics:
-- ff  find files
-- fF  find local files (buffer directory)
-- fb  find buffers
-- fh  find help
-- fr  find recent
-- ft  find treesitter
-- f?  "I forgot"
--
-- Others:
-- /  find in files
-- :  find ":" commands
vim.keymap.set('n', '<leader>f<leader>', telescopes.resume, {
	desc = "Find (resume)",
})
vim.keymap.set('n', '<leader>ff', telescopes.find_files, {desc = "Find files"})
vim.keymap.set('n', '<leader>fF', function()
	telescopes.find_files({
		cwd = require('telescope.utils').buffer_dir(),
	})
end, {desc = "Find files (bufdir)"})

local function find_buffers()
	telescopes.buffers {
		ignore_current_buffer = true,
	}
end
vim.keymap.set('n', '<leader>fb', find_buffers, {desc = "Find buffers"})
vim.keymap.set('n', '<leader>bf', find_buffers, {desc = "Find buffers"})

vim.keymap.set('n', '<leader>fh', telescopes.help_tags, {
	desc = "Find help",
})
vim.keymap.set('n', '<leader>fr', telescopes.oldfiles, {
	desc = "Find recent files",
})
vim.keymap.set('n', '<leader>ft', telescopes.treesitter, {
	desc = "Find treesitter",
})
vim.keymap.set('n', '<leader>f?', telescopes.builtin, {
	desc = "Find telescopes",
})
vim.keymap.set('n', '<leader>/', telescopes.live_grep, {
	desc = "Find all files (grep)",
})
vim.keymap.set('n', '<leader>:', telescopes.commands, {
	desc = "Find commands",
})

-- tree-sitter {{{2
require 'nvim-treesitter.configs'.setup {
	ensure_installed = {
		"bash", "c", "cpp", "css", "dot", "gitignore", "go", "gomod",
		"gowork", "graphql", "html", "java", "javascript", "json",
		"lua", "make", "markdown", "markdown_inline", "perl", "php",
		"proto", "python", "regex", "rust", "ruby", "sql", "toml",
		"typescript", "vim", "yaml", "zig",
	},
	auto_install = true,
	highlight = {
		enable = true,
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				['af'] = {query = '@function.outer', desc = "a function"},
				['if'] = {query = '@function.inner', desc = "in function"},
				['ab'] = {query = '@block.outer', desc = "a block"},
				['ib'] = {query = '@block.inner', desc = "in block"},
			},
		},
		move = {
			enable = true,
			goto_next_start = {
				["]a"] = {query = "@parameter.inner", desc = "Next argument start"},
				["]f"] = {query = "@function.outer", desc = "Next function start"},
			},
			goto_next_end = {
				["]A"] = {query = "@parameter.inner", desc = "Next argument end"},
				["]F"] = {query = "@function.outer", desc = "Next function end"},
			},
			goto_previous_start = {
				["[a"] = {query = "@parameter.inner", desc = "Previous argument start"},
				["[f"] = {query = "@function.outer", desc = "Previous function start"},
			},
			goto_previous_end = {
				["[A"] = {query = "@parameter.inner", desc = "Previous argument end"},
				["[F"] = {query = "@function.outer", desc = "Previous function end"},
			},
		},
	},
}


-- trouble {{{2
local diagnostic_signs = {
	Error = '🚫',
	Warn  = '⚠️',
	Hint  = '💡',
	Info  = 'ℹ️',
}

for type, icon in pairs(diagnostic_signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, {
		text   = icon,
		texthl = hl,
		numhl  = hl,
	})
end

require('trouble').setup {
	auto_open = false,
	auto_close = true,
	auto_preview = false,

	action_keys = {
		close = "q",
		cancel = "<esc>",
		toggle_preview = "P",
	},

	-- Non-patched font:
	fold_open = "▼",
	fold_closed = "▶",
	icons = false,
	padding = false,
	indent_lines = false,
	group = true,
	signs = {
		error       = diagnostic_signs.Error,
		warning     = diagnostic_signs.Warn,
		hint        = diagnostic_signs.Hint,
		information = diagnostic_signs.Info,
	},
	use_lsp_diagnostic_signs = false,
}

-- Don't use virtual text to display diagnostics.
-- Signs in the gutter + trouble is enough.
vim.diagnostic.config({
	virtual_text = true,
})

vim.keymap.set('n', '<leader>xx', ':TroubleToggle<cr>', {desc = "Diagnostics list"})
vim.keymap.set('n', '<leader>xl', ':lopen<cr>', {desc = "Location list"})
vim.keymap.set('n', '<leader>xq', ':copen<cr>', {desc = "Quickfix list"})
vim.keymap.set('n', '<leader>xn', function()
	vim.diagnostic.goto_next({float = false, wrap = false})
end, {desc = "Next diagnostic"})

vim.keymap.set('n', '<leader>xp', function()
	vim.diagnostic.goto_prev({float = false, wrap = false})
end, {desc = "Previous diagnostic"})

--  File Types {{{1

-- markdown {{{2
vim.g['pandoc#syntax#conceal#use'] = 0

-- rust {{{2
vim.g.rustfmt_autosave = 1

-- wiki.vim {{{2
let_g('wiki_', {
	filetypes = {'md'},
	index_name = 'README',
	link_extension = '.md',
	link_target_type = 'md',
	mappings_use_defaults = 'local',
	mappings_local = {
		['<plug>(wiki-link-follow)'] = '<leader><CR>',
	},
})
