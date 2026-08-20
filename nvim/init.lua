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
  -- Colorscheme. Loaded eagerly and before everything else (priority) so no
  -- other plugin paints a window against the default palette first.
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
  },
  -- Treesitter: real parse tree per buffer, which is what lets highlighting
  -- tell a call from a definition from a plain variable. `master` is the
  -- branch that builds parsers with a C compiler alone (no tree-sitter CLI).
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
  },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' }
  },
  -- Routes vim.ui.select() through telescope. That hook is what nvim asks
  -- whenever *anything* needs a choice made -- LSP code actions, the Makefile
  -- target picker below -- and its built-in implementation is a numbered
  -- inputlist in the command area with no filtering. One extension upgrades
  -- every caller at once, including ones added later.
  {
    'nvim-telescope/telescope-ui-select.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' }
  },
  -- Sidebar file tree with expandable directories, VS Code style. Complements
  -- telescope rather than replacing it: telescope finds a file you can name,
  -- neo-tree shows you the shape of a directory you can't.
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons', -- wezterm falls back to bundled nerd symbols
    },
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
  -- Debugging (DAP). nvim-dap speaks the same wire protocol VS Code's debugger
  -- does, against the same debugpy adapter — so breakpoints, stepping and
  -- inspection behave identically. What VS Code adds on top is only the UI,
  -- which dap-ui supplies (scopes, stacks, breakpoints, watches, repl).
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',           -- dap-ui's async runtime
      'theHamsta/nvim-dap-virtual-text', -- inline variable values beside the code
      'mfussenegger/nvim-dap-python',    -- python configs + debug-the-test-under-the-cursor
      'jay-babu/mason-nvim-dap.nvim',    -- installs adapters, the way mason installs servers
    },
  },
})

-- Colorscheme.
-- Syntax colour comes from three stacked layers, each seeing more than the last:
--   1. treesitter  -- grammar: this name is a call / a definition / a parameter
--   2. LSP semantic tokens -- types: this name is a class / a module / self
--   3. this colorscheme -- maps the groups those two produce onto actual colours
-- A colorscheme that doesn't define the treesitter + semantic-token groups
-- leaves most of the file as undifferentiated foreground text, which is the
-- failure mode the stock colorscheme has. tokyonight defines all of them.
require('tokyonight').setup({
  style = 'moon',
  styles = {
    keywords = { italic = false },  -- italics render as blurry in most terminals
    comments = { italic = false },
  },
})
vim.cmd.colorscheme('tokyonight')

-- Treesitter.
-- ensure_installed pulls the grammars; highlight.enable is what actually swaps
-- the old regex :syntax engine out for tree-based highlighting.
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'python', 'lua', 'rust', 'toml', 'json', 'yaml', 'markdown', 'vim', 'vimdoc', 'c_sharp' },
  auto_install = true,   -- grab a missing grammar on first open of that filetype
  highlight = {
    enable = true,
    -- Running the old regex engine alongside treesitter double-highlights and
    -- the regex result frequently wins. Off.
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
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
-- File browser: an extension, not a builtin, so it loads and is called separately.
-- setup() before load_extension(): the extension reads its config out of this
-- table when it loads, so the order is not cosmetic. The dropdown theme suits a
-- short list of named choices -- centred, no preview pane, which a list of code
-- actions or make targets has nothing to fill.
require('telescope').setup({
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
})
require('telescope').load_extension('ui-select')
require('telescope').load_extension('file_browser')
vim.keymap.set('n', '<leader>fe', function()
  require('telescope').extensions.file_browser.file_browser({ path = '%:p:h' })
end)

-- Neo-tree. `reveal` opens the sidebar with the current file already selected
-- and its parent directories expanded, so <leader>e always answers "where am I".
require('neo-tree').setup({
  close_if_last_window = true, -- don't leave a lone sidebar behind when you :q the file
  filesystem = {
    follow_current_file = { enabled = true }, -- tree tracks the buffer you switch to
    use_libuv_file_watcher = true,            -- pick up files created outside nvim
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = true,
    },
  },
})
vim.keymap.set('n', '<leader>e', '<Cmd>Neotree toggle reveal left<CR>')

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
  --
  -- Python is split across two servers on purpose:
  --   basedpyright -- types, completion, and *semantic tokens*. Plain `pyright`
  --                   does not serve semantic tokens at all, so it cannot tell
  --                   the editor that a name is a class vs a module vs self.
  --                   That difference is the whole reason for the `based` fork.
  --   ruff         -- lint + format, far faster than pyright at both.
  --
  -- rust_analyzer and roslyn_ls are deliberately NOT here: each comes from its
  -- own language toolchain instead of mason, so its version tracks the compiler
  -- it analyses rather than drifting on mason's own schedule. Both are enabled
  -- by hand below.
  ensure_installed = { 'lua_ls', 'basedpyright', 'ruff' },
})

-- rust_analyzer, from rustup rather than mason (`rustup component add rust-analyzer`).
-- mason-lspconfig only auto-enables what mason itself installed, so enable it by
-- hand; lspconfig's default cmd finds `rust-analyzer` on PATH.
vim.lsp.enable('rust_analyzer')

-- roslyn_ls, C#/.NET. Preferred over omnisharp, which is now in maintenance mode.
-- lspconfig already ships the full roslyn_ls config (solution/project detection,
-- inlay hints, code lens); all that's missing is the server binary and a runtime
-- new enough to run it. install.sh handles both (see its roslyn section):
--   * the server itself isn't in the SDK, mason has no package, and the community
--     dotnet-tool repackage is broken -- so it's pulled from Microsoft's vs-impl
--     NuGet feed, into ~/.local/share/roslyn-ls/.
--   * that server is framework-dependent and wants a newer .NET than the system
--     has, so install.sh drops a private SDK in ~/.dotnet and a `run` launcher
--     that scopes it (DOTNET_ROOT) to this server alone -- the system dotnet is
--     left untouched. cmd points at that launcher.
-- The default cmd here is only a fallback for the rare box that already has a
-- new-enough system runtime; install.sh overwrites `run` to match what it fetched.
-- Unlike lspconfig's bare `{exe, '--stdio'}`, this server also *requires*
-- --logLevel and --extensionLogDirectory, so pass them explicitly.
local roslyn_log = vim.fn.stdpath('log') .. '/roslyn-ls'
vim.fn.mkdir(roslyn_log, 'p')

-- roslyn serves diagnostics by *pull*, and nvim won't pull them for this server
-- on its own, so they only appear if something asks. lspconfig's roslyn_ls does
-- ask -- but it looks the server's registrations up under
-- `dynamic_capabilities.capabilities.diagnosticProvider`, a server-capability
-- name. On nvim 0.11 that table is keyed by LSP *method* instead, so the lookup
-- is always nil, vim.iter() errors on every InsertLeave and write, and no
-- diagnostic ever arrives. Same logic, right key, until upstream catches up.
local function roslyn_refresh_diagnostics(client)
  local regs = client.dynamic_capabilities.capabilities['textDocument/diagnostic']
  if not regs then return end   -- registration only lands once the project is loaded
  for buf in pairs(client.attached_buffers) do
    if vim.api.nvim_buf_is_loaded(buf) then
      for _, reg in ipairs(regs) do
        client:request(vim.lsp.protocol.Methods.textDocument_diagnostic, {
          identifier = reg.registerOptions and reg.registerOptions.identifier,
          textDocument = vim.lsp.util.make_text_document_params(buf),
        }, nil, buf)
      end
    end
  end
end
local roslyn_group = vim.api.nvim_create_augroup('roslyn_ls_diagnostics', { clear = true })

vim.lsp.config('roslyn_ls', {
  cmd = {
    vim.env.HOME .. '/.local/share/roslyn-ls/run',
    '--stdio',
    '--logLevel', 'Information',
    '--extensionLogDirectory', roslyn_log,
  },
  -- Both of lspconfig's call sites into the broken refresh, replaced: the
  -- project-load handler (first diagnostics) and the autocmd (refresh on edit).
  handlers = {
    ['workspace/projectInitializationComplete'] = function(_, _, ctx)
      roslyn_refresh_diagnostics(assert(vim.lsp.get_client_by_id(ctx.client_id)))
      return vim.NIL
    end,
  },
  on_attach = function(client, bufnr)
    if vim.api.nvim_get_autocmds({ buffer = bufnr, group = roslyn_group })[1] then return end
    vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
      group = roslyn_group,
      buffer = bufnr,
      callback = function() roslyn_refresh_diagnostics(client) end,
      desc = 'roslyn_ls: refresh diagnostics',
    })
  end,
})
vim.lsp.enable('roslyn_ls')

-- Advertise nvim-cmp's completion capabilities to every server (nvim 0.11 API)
vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Ruff ships a thin hover that would race basedpyright's much richer one.
-- Silence it so `K` always shows the type-aware result.
vim.lsp.config('ruff', {
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
})

-- basedpyright defaults to typeCheckingMode = 'recommended', which flags every
-- unannotated argument and floods an ordinary codebase with diagnostics.
-- 'standard' is the pyright-equivalent level: real errors, no annotation nagging.
vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = 'standard',
        diagnosticMode = 'openFilesOnly',
      },
    },
  },
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

-- Debugging (nvim-dap + mason-nvim-dap + nvim-dap-python + dap-ui)
-- Same three-layer split as the LSP stack above:
--   nvim-dap        -- the client. Breakpoints, stepping, the DAP wire protocol.
--   mason-nvim-dap  -- installs the *adapters*, as mason installs the servers.
--   nvim-dap-ui     -- the panes VS Code draws for free: scopes, stacks, repl.
--
-- ensure_installed takes mason's own source names, not pip names: 'python' is
-- the debugpy package. There is deliberately no `handlers` key -- with one,
-- mason-nvim-dap also registers its own bare python configuration, which would
-- then sit in the run picker next to dap-python's better ones. Install only;
-- the configuring happens below.
require('mason-nvim-dap').setup({
  ensure_installed = { 'python' },
})

-- Two different interpreters are in play here, and conflating them is the usual
-- reason a session starts but then can't import the project:
--   * the ADAPTER's python -- runs debugpy itself. mason's private venv, below.
--   * the DEBUGGEE's python -- runs your code, so it has to be the venv holding
--     your dependencies. dap-python picks it per session: $VIRTUAL_ENV, else
--     $CONDA_PREFIX, else the first venv/.venv/env/.env directory under the cwd
--     or any attached LSP's root.
-- If that search comes up empty, debugpy falls back to the adapter's own python
-- -- mason's venv, which has debugpy and nothing else, so the session starts and
-- then dies on the first project import. Activate the venv, or keep a .venv in
-- the project root, and it never comes up.
-- debugpy itself does NOT need installing into the project venv: the adapter
-- injects its own copy onto the debuggee's sys.path at launch. That is how the
-- VS Code extension gets away with bundling exactly one debugpy for everything.
local debugpy_python = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python'
require('dap-python').setup(debugpy_python)

local dap = require('dap')

-- dap-python already registers the four everyday configurations -- `file`,
-- `file:args` (prompts for argv), `attach` (prompts for host/port) and
-- `file:doctest`. These are the two gaps in that set.
--
-- justMyCode = false is the interesting one: debugpy defaults it to true, which
-- makes `step into` skip straight over any frame outside your own source. That
-- is the right default right up until the bug is in HOW you call a library
-- rather than in the call site, at which point it hides the only frame that
-- matters. Kept as a separate entry rather than a global override so the cheap
-- default stays one keypress away.
table.insert(dap.configurations.python, {
  type = 'python',
  request = 'launch',
  name = 'file:libs (step into library code)',
  program = '${file}',
  console = 'integratedTerminal',
  justMyCode = false,
})
-- `python -m package.entrypoint`, for a project whose entry point is a module
-- rather than a path -- which `file` cannot express, since it only ever runs
-- the buffer you happen to be looking at.
table.insert(dap.configurations.python, {
  type = 'python',
  request = 'launch',
  name = 'module (python -m …)',
  module = function() return vim.fn.input('Module: ') end,
  args = function()
    return vim.split(vim.fn.input('Arguments: '), ' ', { trimempty = true })
  end,
  console = 'integratedTerminal',
})

-- dap-ui. Left sidebar only: scopes / breakpoints / stacks / watches.
--
-- The default bottom drawer is dropped. It carried two things, neither earning
-- ten rows: a `console` element that never receives anything here (every
-- configuration runs with console = 'integratedTerminal', so the program's
-- output goes to a terminal buffer instead -- and on the <leader>dM route it is
-- already visible in the make split), and the repl, which <leader>dr opens on
-- demand anyway.
--
-- controls off: the play/pause/step buttons dap-ui draws in a winbar. Every one
-- of them has a keymap, and the winbar costs a line of whichever window hosts it.
local dapui = require('dapui')
dapui.setup({
  layouts = {
    {
      elements = {
        { id = 'scopes',      size = 0.25 },
        { id = 'breakpoints', size = 0.25 },
        { id = 'stacks',      size = 0.25 },
        { id = 'watches',     size = 0.25 },
      },
      size = 40,
      position = 'left',
    },
  },
  controls = { enabled = false },
})

-- Open on session start, close on session end, so a dead session never leaves
-- panes behind showing variables that no longer exist.
dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

-- Values printed inline at end of line, against the code that produced them.
-- This is the part that makes a stopped frame readable without looking at the
-- scopes pane at all -- the one thing VS Code has no equivalent for.
require('nvim-dap-virtual-text').setup()

-- Signs. Undefined, every dap sign renders as the letter `B`, so a breakpoint
-- and the line you're stopped on look identical in the gutter.
vim.fn.sign_define('DapBreakpoint',          { text = '●', texthl = 'DiagnosticError' })
vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticError' })
vim.fn.sign_define('DapLogPoint',            { text = '◆', texthl = 'DiagnosticInfo' })
vim.fn.sign_define('DapBreakpointRejected',  { text = '○', texthl = 'DiagnosticHint' })
vim.fn.sign_define('DapStopped',             { text = '▶', texthl = 'DiagnosticWarn', linehl = 'Visual' })

-- Keymaps, two sets on purpose. The F-keys are VS Code's exactly, for the
-- muscle memory you already have; <leader>d… covers what VS Code puts behind a
-- mouse click, plus the things it has no button for at all (logpoints, rerun).
vim.keymap.set('n', '<F5>',    dap.continue)    -- start a session, or resume a stopped one
vim.keymap.set('n', '<F10>',   dap.step_over)
vim.keymap.set('n', '<F11>',   dap.step_into)
vim.keymap.set('n', '<S-F11>', dap.step_out)    -- VS Code's step-out; wezterm does send it
vim.keymap.set('n', '<F12>',   dap.step_out)    -- ...and an unshifted fallback for terminals that don't

vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader>dB', function()
  -- Conditional breakpoint: a python expression evaluated in the frame every
  -- time the line is reached, e.g. `i == 4721` -- the cheapest way to skip
  -- 4720 uninteresting iterations without touching the loop.
  dap.set_breakpoint(vim.fn.input('Break when: '))
end)
vim.keymap.set('n', '<leader>dp', function()
  -- Logpoint: prints to the repl and does NOT stop. A print statement you
  -- didn't have to put in the file, and don't have to remember to remove.
  -- {} interpolates an expression: `x is {x}`.
  dap.set_breakpoint(nil, nil, vim.fn.input('Log: '))
end)
vim.keymap.set('n', '<leader>dx', dap.clear_breakpoints)
vim.keymap.set('n', '<leader>dc', dap.continue)
vim.keymap.set('n', '<leader>dC', dap.run_to_cursor) -- one-shot breakpoint here, then resume
vim.keymap.set('n', '<leader>dR', dap.run_last)      -- rerun the last configuration, skipping the picker

-- Stepping on hjkl, with the call stack drawn vertically: callees are BELOW,
-- callers ABOVE, and execution runs left to right along the current line.
--   l  step OVER -- carry on rightwards, calls run without descending
--   j  step INTO -- drop DOWN into the callee
--   k  step OUT  -- come back UP to the caller
-- The F-keys above still work; these are an alias, not a replacement.
--
-- Deliberately behind <leader> rather than bare h/j/k/l while stopped. Plain
-- motions are needed constantly at a breakpoint: to reach a line for
-- <leader>dC, to select an expression for <leader>de, or just to read the code
-- around the stop. Shadowing them would cost more than it saves.
vim.keymap.set('n', '<leader>dl', dap.step_over)
vim.keymap.set('n', '<leader>dj', dap.step_into)
vim.keymap.set('n', '<leader>dk', dap.step_out)

-- Capitals are the same directions with nothing executed: they move which frame
-- you are LOOKING at, up towards the caller or down towards the callee, while
-- the program stays exactly where it stopped. Scopes and <leader>de follow the
-- selected frame. So dk and dK both take you to the caller -- dk by running the
-- rest of the function, dK by just looking.
vim.keymap.set('n', '<leader>dK', function() require('dap').up() end)
vim.keymap.set('n', '<leader>dJ', function() require('dap').down() end)
vim.keymap.set('n', '<leader>dt', dap.terminate)
vim.keymap.set('n', '<leader>du', dapui.toggle)
vim.keymap.set('n', '<leader>dr', dap.repl.toggle)   -- a real python repl in the stopped frame
vim.keymap.set({ 'n', 'v' }, '<leader>de', function()
  -- Hover-evaluate: the word under the cursor in normal mode, the selection in
  -- visual mode -- so you can highlight `self.cache[key]` and evaluate that.
  dapui.eval(nil, { enter = true })                  -- enter = put the cursor in the float, to expand children
end)
-- Debug the test the cursor is inside, no configuration and no picker. pytest
-- and unittest both; dap-python reads the enclosing def/class from treesitter.
vim.keymap.set('n', '<leader>dm', function() require('dap-python').test_method() end)

-- <leader>dM -- run a Makefile target under the debugger in one keypress.
-- The convention it relies on is `DEBUG=1`: a target that, given it, runs behind
-- `python -m debugpy --listen $(PORT) --wait-for-client`. signal-engine's
-- Makefile does exactly that (its own header documents it), so the real command
-- starts with the real Makefile parameters and then blocks until we attach.
--
-- Two things this has over <F5> + launch.json:
--   * the parameters are the Makefile's, so a terminal run and a debug run can't
--     drift -- there is one definition of the command, not two.
--   * debugpy comes from the PROJECT's venv, so it's the build matching the
--     interpreter. On signal-engine that's the cp314 free-threaded wheel; the
--     launch path injects mason's cp310 copy, which can't load its compiled
--     tracer under 3.14t and falls back to pure-python tracing.
dap.adapters.make_debugpy = function(cb, config)
  cb({
    type = 'server',
    host = config.connect.host,
    port = config.connect.port,
    options = {
      source_filetype = 'python',
      -- 250ms per retry. `uv run` syncs the venv before the process starts, so
      -- the port can be a long way off on a cold lock; the default 14 (3.5s)
      -- gives up while make is still resolving dependencies.
      max_retries = 240,
    },
  })
end

-- debug=false is the same picker without the debugger: the target just runs in
-- the split. That's the common case -- most runs you only want to watch, and
-- attaching a debugger to a run you aren't stepping through costs tracing
-- overhead for nothing.
local function make_run(debug)
  local from = vim.fn.expand('%:p:h')
  if from == '' then from = vim.fn.getcwd() end
  local makefile = vim.fs.find('Makefile', { upward = true, path = from })[1]
  if not makefile then
    return vim.notify('No Makefile at or above ' .. from, vim.log.levels.WARN)
  end
  local root = vim.fs.dirname(makefile)

  -- Targets and their `## ` help text: the same pairs `make help` prints, so
  -- the picker stays in sync with the Makefile without a second list to update.
  local targets, port = {}, 5678
  for line in io.lines(makefile) do
    local name, desc = line:match('^([%w%-_]+):.*##%s*(.*)$')
    if name then table.insert(targets, { name = name, desc = desc }) end
    local declared = line:match('^PORT%s*%??=%s*(%d+)')
    if declared then port = tonumber(declared) end
  end
  if #targets == 0 then
    return vim.notify('No `## `-documented targets in ' .. makefile, vim.log.levels.WARN)
  end

  vim.ui.select(targets, {
    prompt = debug and 'make <target> DEBUG=1' or 'make <target>',
    format_item = function(t) return string.format('%-22s %s', t.name, t.desc) end,
  }, function(target)
    if not target then return end
    -- Makefile variables are how a target is parameterised, so ask for them
    -- instead of editing the Makefile: `BOOTSTRAPS=5 CONFIDENCE=0.8`.
    local vars = vim.fn.input('make vars (optional): ')
    local cmd = string.format('make -C %s %s %s%s',
      vim.fn.shellescape(root), target.name, debug and 'DEBUG=1 ' or '', vars)

    -- The process gets a terminal split -- its stdout, and the equivalent of VS
    -- Code's integrated terminal. It outlives the session so the run's output
    -- is still there to read afterwards.
    vim.cmd('botright 15new')
    vim.fn.jobstart(cmd, { term = true })
    vim.b.dap_make_terminal = true   -- tagged so <leader>dq can find it again
    vim.cmd('wincmd p')   -- back to the code, so breakpoints stay one keypress away

    if not debug then return end
    -- Fired immediately: the adapter's max_retries above is what waits for the
    -- port, so there's nothing to poll and no delay to guess at.
    dap.run({
      type = 'make_debugpy',
      request = 'attach',
      name = 'make ' .. target.name,
      connect = { host = '127.0.0.1', port = port },
    })
  end)
end
vim.keymap.set('n', '<leader>dM', function() make_run(true) end)   -- debug it
vim.keymap.set('n', '<leader>mm', function() make_run(false) end)  -- just run it

-- <leader>dq -- put the editor back how it was. dap-ui's panes already close
-- themselves when a session ends (the listeners above fire on event_terminated
-- and event_exited), so this is for the two things that outlive a session on
-- purpose: the <leader>dM terminal split, kept so the run's output is still
-- readable afterwards, and a repl opened by hand with <leader>dr.
local function debug_cleanup()
  if dap.session() then dap.terminate() end
  dapui.close()
  dap.repl.close()

  -- Two ways to recognise the split, because the tag is only set at creation:
  -- a terminal opened before this config was reloaded doesn't carry it, and
  -- "the pane is still there" is exactly what that looks like. The name is the
  -- fallback -- `term://<cwd>//<pid>:make …`, which nvim builds from the command.
  local closed = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      local is_make_term = vim.b[buf].dap_make_terminal
        or (vim.bo[buf].buftype == 'terminal' and name:match('^term://') and name:match(':.*%f[%w]make%f[%W]'))
      if is_make_term then
        for _, win in ipairs(vim.fn.win_findbuf(buf)) do
          -- never close the last window; nvim would have nothing left to show
          if #vim.api.nvim_list_wins() > 1 then
            vim.api.nvim_win_close(win, true)
          end
        end
        vim.api.nvim_buf_delete(buf, { force = true })
        closed = closed + 1
      end
    end
  end
  -- Say so rather than failing silently: 0 means nothing matched, which is a
  -- different problem from "it matched and the window survived".
  vim.notify(string.format('debug cleanup: closed %d make terminal(s)', closed))
end
vim.api.nvim_create_user_command('DebugCleanup', debug_cleanup, {})
vim.keymap.set('n', '<leader>dq', debug_cleanup)

-- Editor options
vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true
-- CursorHold's delay, and so how long an idle nvim waits before noticing a file
-- changed underneath it. The 4s default is too long to feel automatic.
vim.opt.updatetime = 250
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

-- Python indents 4, not 2. The global 2-space default above is fine for lua and
-- rust, but PEP 8 (and therefore ruff, which will reformat against you) wants 4.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- Reload buffers edited outside nvim -- by claude in another tmux pane, by a
-- git checkout, by a formatter. `autoread` above only re-reads on nvim's own
-- schedule, which is to say when something happens to prompt it; :checktime is
-- the prompt. FocusGained needs `set -g focus-events on` in tmux/.tmux.conf to
-- ever fire, so the two halves of this live in different files.
-- vim.schedule is load-bearing, not tidiness: :checktime called straight from an
-- autocmd callback is silently ignored -- it returns without error and without
-- reloading, because the callback runs under textlock. Deferring it to the next
-- event-loop tick is what makes it actually run.
-- The mode() guard keeps it off the command line, where :checktime is an error.
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'TermLeave' }, {
  callback = function()
    if vim.fn.mode() ~= 'c' and vim.bo.buftype == '' then
      vim.schedule(function() vim.cmd('checktime') end)
    end
  end,
  desc = 'reload buffers changed on disk',
})

-- Say when it happens. A buffer silently changing under the cursor is worse
-- than a stale one: you need to know the undo history you are looking at is a
-- different file's.
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  callback = function()
    vim.notify('Buffer reloaded from disk', vim.log.levels.WARN)
  end,
})

-- Keymaps
-- Half-page scroll on M-u/M-d as well as C-u/C-d. tmux copy mode and the claude
-- TUI both scroll on M-u/M-d now, so this makes one pair of keys scroll every
-- pane whatever is running in it. C-u/C-d are kept, not replaced: they're what
-- every vim doc, every plugin help file and every muscle memory assumes.
vim.keymap.set({ 'n', 'x' }, '<M-u>', '<C-u>', { desc = 'half page up' })
vim.keymap.set({ 'n', 'x' }, '<M-d>', '<C-d>', { desc = 'half page down' })

vim.keymap.set('i', 'jk', '<Esc>')  -- jk to escape insert mode
