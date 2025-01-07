" Initialize vim-plug
call plug#begin('~/.local/share/nvim/plugged')

" Install necessary plugins
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'm4xshen/autoclose.nvim'
Plug 'navarasu/onedark.nvim'

" For vsnip users
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" For luasnip users
" Plug 'L3MON4D3/LuaSnip'
" Plug 'saadparwaiz1/cmp_luasnip'

" For ultisnips users
" Plug 'SirVer/ultisnips'
" Plug 'quangnguyen30192/cmp-nvim-ultisnips'

" For snippy users
" Plug 'dcampos/nvim-snippy'
" Plug 'dcampos/cmp-snippy'

call plug#end()

" One Dark Theme Configuration
let g:onedark_style = 'darker'
let g:onedark_italic_comments = 1
let g:onedark_bold = 0

" Enable syntax highlighting and set One Dark theme
syntax enable
colorscheme onedark

" Start Lua block for setting up LSP and nvim-cmp
lua <<EOF
  require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-h>"] = "which_key"
      }
    }
  },
  pickers = {},
  extensions = {}
}

  -- Set up nvim-cmp
  local cmp = require('cmp')

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    window = {
      -- Optional: completion window config
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
    }, {
      { name = 'buffer' },
    })
  })

  -- LSP Setup for pyright (Python)
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  require('lspconfig')['pyright'].setup {
    capabilities = capabilities
  }

  -- Setup for other languages (add more LSP servers as needed)
  -- C/C++
  require('lspconfig')['clangd'].setup {
    capabilities = capabilities
  }

  -- Go
  require('lspconfig')['gopls'].setup {
    capabilities = capabilities
  }

  -- Rust
  require('lspconfig')['rust_analyzer'].setup {
    capabilities = capabilities
  }

  -- Bash
  require('lspconfig')['bashls'].setup {
    capabilities = capabilities
  }

  -- Treesitter setup
  require("nvim-treesitter.configs").setup({
    ensure_installed = { "javascript", "typescript", "lua", "vim", "json", "html", "rust", "tsx", "python", "go", "bash", "java", "c" },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
    },
  })

  -- Autoclose setup
  require("autoclose").setup({
    keys = {
      ["$"] = { escape = true, close = true, pair = "$$", disabled_filetypes = {} },
    },
  })

EOF


" Enable line numbers and relative numbers
set number
set relativenumber

" Set the leader key
let mapleader = " "

" Enable line wrapping
set wrap

" Set tab preferences
set tabstop=4
set shiftwidth=4
set expandtab

" Set file encoding to UTF-8
set encoding=utf-8

" Set search settings
set ignorecase
set smartcase
set incsearch

" Enable auto-indentation
filetype plugin indent on
