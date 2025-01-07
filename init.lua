-- init.lua

-- Bootstrap lazy.nvim plugin manager if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

-- Set leader key before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load plugins using lazy.nvim
require("lazy").setup({
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "javascript", "typescript", "lua", "vim", "json", 
          "html", "rust", "tsx", "python", "go", "bash", 
          "java", "c"
        },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
      })
    end
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip"
    },
    config = function()
      local cmp = require('cmp')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Set up nvim-cmp
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
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

      -- LSP Servers setup
      local lspconfig = require('lspconfig')
      local servers = {
        'pyright', 'clangd', 'gopls', 'rust_analyzer', 'bashls'
      }

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          capabilities = capabilities,
        }
      end
    end
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 
        'nvim-telescope/telescope-fzf-native.nvim', 
        build = 'make' 
      }
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-h>"] = actions.which_key,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            }
          },
          file_ignore_patterns = {
            "node_modules/", ".git/", ".cache/", 
            "*.o", "*.a", "*.out", "*.class", 
            "*.pdf", "*.zip"
          },
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = {
              preview_width = 0.6,
              width = 0.9
            }
          }
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case"
          }
        }
      })

      -- Load fzf extension
      telescope.load_extension('fzf')
    end
  },

  -- Autoclose
  {
    'm4xshen/autoclose.nvim',
    config = function()
      require("autoclose").setup({
        keys = {
          ["$"] = { escape = true, close = true, pair = "$$", disabled_filetypes = {} },
        },
      })
    end
  },

  -- Theme
  {
    'navarasu/onedark.nvim',
    config = function()
      require('onedark').setup({
        style = 'darker',
        code_style = {
          comments = 'italic',
          keywords = 'none',
          functions = 'none',
          strings = 'none',
          variables = 'none'
        },
      })
      require('onedark').load()
    end
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon").setup({
        global_settings = {
          save_on_toggle = false,
          save_on_change = true,
          enter_on_sendcmd = false,
          tmux_autoclose_windows = false,
          excluded_filetypes = { "harpoon" },
          mark_branch = false,
        }
      })
    end
  }
})

-- Editor Settings
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true     -- Show relative line numbers
vim.opt.wrap = true               -- Enable line wrapping
vim.opt.tabstop = 4               -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4            -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.encoding = 'utf-8'        -- Set file encoding
vim.opt.ignorecase = true         -- Ignore case in search patterns
vim.opt.smartcase = true          -- Override ignorecase if search contains uppercase
vim.opt.incsearch = true          -- Show search matches as you type

-- Autoindentation
vim.cmd('filetype plugin indent on')

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "Y", '"+Y')

-- Telescope Keymappings
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fc', '<cmd>Telescope commands<cr>', { noremap = true, silent = true })

-- Harpoon Keymappings
vim.keymap.set('n', '<leader>ha', function() require("harpoon.mark").add_file() end, { desc = "Harpoon: Add File" })
vim.keymap.set('n', '<leader>hm', function() require("harpoon.ui").toggle_quick_menu() end, { desc = "Harpoon: Quick Menu" })
vim.keymap.set('n', '<leader>h1', function() require("harpoon.ui").nav_file(1) end, { desc = "Harpoon: Go to File 1" })
vim.keymap.set('n', '<leader>h2', function() require("harpoon.ui").nav_file(2) end, { desc = "Harpoon: Go to File 2" })
vim.keymap.set('n', '<leader>h3', function() require("harpoon.ui").nav_file(3) end, { desc = "Harpoon: Go to File 3" })
vim.keymap.set('n', '<leader>h4', function() require("harpoon.ui").nav_file(4) end, { desc = "Harpoon: Go to File 4" })

