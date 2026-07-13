-- Leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require('lazy').setup({
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  -- LSP: mason installs language servers, mason-lspconfig bridges to lspconfig
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'neovim/nvim-lspconfig' },
  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',   -- LSP source
      'hrsh7th/cmp-buffer',     -- current-buffer words
      'hrsh7th/cmp-path',       -- filesystem paths
      'L3MON4D3/LuaSnip',       -- snippet engine
      'saadparwaiz1/cmp_luasnip', -- snippet source
    },
  },
})

-- Harpoon
local harpoon = require('harpoon')
harpoon:setup()

vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end)
vim.keymap.set('n', '<leader>h', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set('n', '<leader>1', function() harpoon:list():select(1) end)
vim.keymap.set('n', '<leader>2', function() harpoon:list():select(2) end)
vim.keymap.set('n', '<leader>3', function() harpoon:list():select(3) end)
vim.keymap.set('n', '<leader>4', function() harpoon:list():select(4) end)

-- Telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope.find_files)
vim.keymap.set('n', '<leader>fg', telescope.live_grep)
vim.keymap.set('n', '<leader>fb', telescope.buffers)
vim.keymap.set('n', '<leader>fh', telescope.help_tags)

-- Autocompletion (nvim-cmp + LuaSnip)
local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback() end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then luasnip.jump(-1)
      else fallback() end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
})

-- LSP (mason + mason-lspconfig + nvim-lspconfig)
require('mason').setup()
require('mason-lspconfig').setup({
  -- Servers listed here are auto-installed and auto-enabled via vim.lsp.enable
  ensure_installed = { 'lua_ls', 'rust_analyzer' },
})

-- Advertise nvim-cmp's completion capabilities to every server (nvim 0.11 API)
vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Inline diagnostics: message text, gutter signs, and underlines
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
})

-- Buffer-local LSP keymaps, set only once a server attaches.
-- Navigation (definitions/references) goes through telescope so we reuse the
-- picker we already have; the rest are actions telescope can't do.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    local pick = require('telescope.builtin')
    vim.keymap.set('n', 'gd', pick.lsp_definitions, opts)         -- go to definition
    vim.keymap.set('n', 'gr', pick.lsp_references, opts)          -- find references
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)            -- hover docs
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)   -- rename symbol
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts) -- code action
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
  end,
})

-- Editor options
vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true
vim.opt.swapfile = false
vim.opt.termguicolors = true

-- Indentation: use spaces for tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

-- Line numbers: hybrid. The cursor line shows its absolute number (for :123,
-- stack traces, talking to someone else); every other line shows its DISTANCE,
-- which is what makes counted jumps aimable — read `7` in the gutter, press 7j.
vim.wo.number = true
vim.wo.relativenumber = true

-- Keymaps
vim.keymap.set('i', 'jk', '<Esc>')  -- jk to escape insert mode
