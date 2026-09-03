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
  -- Jump anywhere on screen by naming it. Type `s` then two characters and every
  -- match gets a label; press the label to teleport. This is the tool for the
  -- range between "on this line" (f/t) and "somewhere in the project"
  -- (telescope) -- which is exactly where hjkl-mashing happens.
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
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
  -- Git hunks in the gutter, and everything you want to do to one from there.
  -- This is the *inline* half of "show me the diff": what changed on this line,
  -- answered without leaving the line. The other half -- what changed across a
  -- branch -- wants a file list and a two-pane view, and is a different tool.
  --
  -- Earns its place here because the files change underneath this editor: a
  -- claude in the next tmux window, a formatter, a rebase. The gutter is what
  -- makes "which lines did something else touch, and do I agree" a glance
  -- rather than a `git diff` in another pane.
  {
    'lewis6991/gitsigns.nvim',
  },
  -- The other half of "show me the diff": what changed across a BRANCH, or a
  -- commit, or the whole working tree -- the question gitsigns' gutter cannot
  -- answer because the answer spans files. File panel on the left, two-pane
  -- diff on the right.
  --
  -- In nvim rather than a TUI in another tmux window for one reason: reviewing
  -- is not a read-only activity. Half of "what did that change" ends in staging
  -- a hunk, jumping to a definition, or fixing it there and then -- and in here
  -- <leader>gs, gd and the rest are all still under the hand.
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  -- Copilot, as GHOST TEXT only -- never as a cmp source.
  --
  -- Mixing the two makes both worse: AI entries push real LSP completions out
  -- of the list, cmp's fuzzy matching fights multi-line suggestions, and you
  -- lose the ability to tell a guess from a fact. The LSP knows the method
  -- exists; copilot thinks it probably does. Different keys, different colour.
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
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

-- <leader>fw -- pick a git worktree and work in it.
--
-- The problem this solves is specific to agent worktrees. Claude puts them at
-- <repo>/.claude/worktrees/<name> and excludes that path in .git/info/exclude,
-- so <leader>ff cannot see into one from the main checkout -- fd honours the
-- exclude, and the directory is hidden besides. That exclusion is RIGHT: a
-- worktree is a second full checkout, so without it every file in the project
-- would appear once per worktree in every search. The fix is therefore not a
-- flag on the finder; it is to be in the worktree in the first place.
--
-- No plugin. vim.ui.select goes through telescope-ui-select (see the telescope
-- block above), so this is a fuzzy picker for free -- the same trick the
-- Makefile target pickers use.
local function git_worktrees()
  local out = vim.fn.systemlist({ 'git', 'worktree', 'list', '--porcelain' })
  if vim.v.shell_error ~= 0 then return nil end
  local list, cur = {}, nil
  for _, line in ipairs(out) do
    local path = line:match('^worktree (.+)$')
    if path then
      cur = { path = path }
      table.insert(list, cur)
    elseif cur then
      cur.branch = line:match('^branch refs/heads/(.+)$') or cur.branch
      if line == 'detached' then cur.branch = '(detached)' end
      if line:match('^locked') then cur.locked = true end
    end
  end
  return list
end

vim.keymap.set('n', '<leader>fw', function()
  local list = git_worktrees()
  if not list then return vim.notify('not in a git repository', vim.log.levels.WARN) end
  if #list < 2 then return vim.notify('no worktrees besides the main checkout') end

  -- `git worktree list` always puts the main checkout first, which is what
  -- makes it the thing every other path is shown relative to.
  local root = list[1].path
  local width = 0
  for _, w in ipairs(list) do width = math.max(width, #(w.branch or '?')) end

  vim.ui.select(list, {
    prompt = 'worktree',
    format_item = function(w)
      -- Full path for the main checkout, and relative for the rest: an agent
      -- worktree's identity is `.claude/worktrees/<name>`, and repeating the
      -- repo root in front of every row buries it past the edge of the popup.
      local where = w.path == root and w.path or w.path:sub(#root + 2)
      return string.format('%-' .. width .. 's  %s%s',
        w.branch or '?', where, w.locked and '  [locked]' or '')
    end,
  }, function(w)
    if not w then return end
    vim.cmd.cd(w.path)
    vim.notify('cwd: ' .. w.path)
    -- Straight into the finder, since "browse that worktree" is the reason you
    -- came. <Esc> backs out of it if the cd was all you wanted.
    require('telescope.builtin').find_files()
  end)
end)

-- Flash. `s` in normal/visual/operator-pending is the jump; it shadows the
-- built-in `s` (substitute character), which is no loss -- `cl` is the same
-- thing and one key longer. `S` stays as-is: flash's treesitter jump is not
-- worth losing `cc`'s shorthand for. Neo-tree's own `s` (open in vsplit) is
-- buffer-local and so still wins inside the tree.
require('flash').setup()
vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'flash jump' })
vim.keymap.set({ 'o', 'x' }, 'R', function() require('flash').treesitter_search() end, { desc = 'flash treesitter search' })

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

-- Gitsigns. The signs and the blame are the passive half; the hunk keymaps
-- below are the half that makes it a diff tool rather than a decoration.
--
-- Prefix is <leader>g, not gitsigns' own suggested <leader>h -- that one is
-- harpoon's quick menu here, and harpoon is used far more often than any hunk
-- operation. `g` for git costs nothing and is the more obvious letter anyway.
require('gitsigns').setup({
  -- Blame the current line as virtual text at end of line. Off by default in
  -- gitsigns, and it is the single most useful thing it does: "who wrote this
  -- and why" answered continuously instead of on request. 400ms so it follows
  -- the cursor without flickering during a motion.
  current_line_blame = true,
  current_line_blame_opts = { delay = 400, virt_text_pos = 'eol' },
  current_line_blame_formatter = '  <author>, <author_time:%Y-%m-%d> — <summary>',

  -- Sign a file git has never seen, not just changed lines in a tracked one.
  -- Off by default upstream because on some repos it is noise -- but not here:
  -- gitsigns looks untracked files up with `ls-files --others --exclude-standard`,
  -- and --exclude-standard means anything .gitignore covers returns nothing.
  -- So build output and venvs stay dark and only genuinely-new files light up.
  --
  -- Worth having because of how these files get written: a claude in the next
  -- tmux window creating a file is exactly the case where "this exists but git
  -- has never heard of it" needs to be visible before the commit that misses it.
  -- The untracked sign is `┆` -- dashed, against the solid `┃` of an added line,
  -- so "new file" and "new lines" stay distinguishable at a glance.
  attach_to_untracked = true,

  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local function map(mode, lhs, rhs, desc, opts)
      vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('keep', opts or {}, { buffer = bufnr, desc = desc }))
    end

    -- Hunk motion. ]c/[c are vim's own diff-mode motions, and inside a real
    -- diff split that is what they must stay -- so fall through when diffmode
    -- is on and only take over in an ordinary buffer.
    --
    -- expr = true is load-bearing, not decoration: it is what makes the RETURN
    -- VALUE the keys to press. Without it the string is discarded and the
    -- fallthrough silently does nothing inside a diff.
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.nav_hunk('next') end)
      return '<Ignore>'
    end, 'next hunk', { expr = true })
    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.nav_hunk('prev') end)
      return '<Ignore>'
    end, 'previous hunk', { expr = true })

    -- Reading a hunk.
    map('n', '<leader>gp', gs.preview_hunk_inline, 'preview hunk inline')
    map('n', '<leader>gP', gs.preview_hunk,        'preview hunk in a float')
    map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'blame this line, full')
    map('n', '<leader>gB', gs.toggle_current_line_blame, 'toggle the inline blame')
    map('n', '<leader>gd', gs.diffthis,                  'diff this file against the index')
    map('n', '<leader>gD', function() gs.diffthis('~') end, 'diff this file against the last commit')
    map('n', '<leader>gq', gs.setqflist, 'every hunk in this buffer to the quickfix list')
    map('n', '<leader>gQ', function() gs.setqflist('all') end, 'every hunk in the REPO to the quickfix list')

    -- Changing a hunk. Staging one hunk at a time is the point of the whole
    -- plugin: a buffer with three unrelated fixes in it becomes three commits
    -- without a single `git add -p`.
    map('n', '<leader>gs', gs.stage_hunk,  'stage this hunk')
    map('n', '<leader>gr', gs.reset_hunk,  'discard this hunk')
    map('n', '<leader>gS', gs.stage_buffer, 'stage the whole buffer')
    map('n', '<leader>gR', gs.reset_buffer, 'discard every change in the buffer')
    -- Same two over a visual selection -- PART of a hunk, down to one line.
    map('v', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'stage selected lines')
    map('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'discard selected lines')
    -- No unstage key: <leader>gs on an already-staged hunk unstages it, which
    -- is why gitsigns deprecated undo_stage_hunk. One key, both directions.

    -- A hunk as a TEXT OBJECT, which is the part that makes this feel like vim
    -- rather than like a git client: `dih` deletes the hunk under the cursor,
    -- `vih` selects it to stage part of it, `=ih` reindents just it.
    map({ 'o', 'x' }, 'ih', gs.select_hunk, 'inner hunk')
  end,
})

-- Diffview. The question gitsigns' gutter cannot answer, because the answer
-- spans files: what changed across the working tree, a commit, or a branch.
--
-- It uses NEOVIM'S OWN diff engine rather than shelling out to a formatter,
-- which is why `diffopt+=linematch:60` (set with the editor options below)
-- shows up here too -- a line with one word changed renders as a line with one
-- word changed, instead of a delete plus an add.
require('diffview').setup({
  -- Highlight the changed REGION within a changed line, not just the line.
  -- Off by default. On a review of someone else's edit it is the difference
  -- between "this line moved" and "this argument moved".
  enhanced_diff_hl = true,
  view = {
    -- Explicit rather than inherited: a merge wants three panes (ours, base,
    -- theirs) and an ordinary review wants two.
    default = { layout = 'diff2_horizontal' },
    merge_tool = { layout = 'diff3_horizontal', disable_diagnostics = true },
  },
})

-- The default branch, asked of the repo rather than assumed. `main` here and
-- `master` on anything older, and neither is a safe guess -- origin/HEAD is the
-- one place git actually records it.
local function default_branch()
  local ref = vim.fn.systemlist('git symbolic-ref --quiet --short refs/remotes/origin/HEAD')[1]
  if vim.v.shell_error == 0 and ref and ref ~= '' then
    return ref                                    -- e.g. `origin/main`
  end
  for _, guess in ipairs({ 'origin/main', 'origin/master', 'main', 'master' }) do
    vim.fn.system({ 'git', 'rev-parse', '--verify', '--quiet', guess })
    if vim.v.shell_error == 0 then return guess end
  end
  return nil
end

-- <leader>gg -- in and out on one key, three states, the same shape as the
-- dap-ui panes and tmux's <prefix>C. Diffview opens in its own TAB, so without
-- the middle case a second press would silently stack a second review tab on
-- top of the first rather than returning you to it.
local function diffview_toggle(args)
  local lib = require('diffview.lib')
  if lib.get_current_view() then
    return vim.cmd('DiffviewClose')               -- looking at it -> shut it
  end
  local open = lib.views[1]
  if open and vim.api.nvim_tabpage_is_valid(open.tabpage) then
    return vim.api.nvim_set_current_tabpage(open.tabpage)   -- exists -> go to it
  end
  vim.cmd('DiffviewOpen ' .. (args or ''))        -- nothing -> make one
end

vim.keymap.set('n', '<leader>gg', function() diffview_toggle() end)

-- One rule for every entry point below: pressed from INSIDE a view, they close
-- it. Whichever key got you in, any of them gets you out -- rather than having
-- to remember that gg toggles and the other three are one-way, or falling back
-- to :DiffviewClose because the key you reached for did nothing.
local function diffview_cmd(cmd)
  return function()
    if require('diffview.lib').get_current_view() then
      return vim.cmd('DiffviewClose')
    end
    if type(cmd) == 'function' then return cmd() end
    vim.cmd(cmd)
  end
end

-- <leader>gm -- everything this branch did that the default branch didn't.
-- `A...B` (three dots) is the crucial part: it diffs against the MERGE BASE, so
-- commits that landed on main after you branched don't show up as your changes.
-- Two dots would show those too and make a week-old branch unreadable.
vim.keymap.set('n', '<leader>gm', diffview_cmd(function()
  local base = default_branch()
  if not base then
    return vim.notify('no default branch found (origin/HEAD unset?)', vim.log.levels.WARN)
  end
  vim.cmd('DiffviewOpen ' .. base .. '...HEAD')
end))

-- History. `%` is this file's, bare is the whole repo's. This is the good
-- version of `git log -p`: every commit that touched it, navigable, with the
-- diff in the pane beside rather than paged past.
vim.keymap.set('n', '<leader>gh', diffview_cmd('DiffviewFileHistory %'))
vim.keymap.set('n', '<leader>gH', diffview_cmd('DiffviewFileHistory'))
-- Visual: the history of just the SELECTED LINES -- `git log -L`, which is the
-- query you actually want ("who last touched this function") and the one that
-- is unusable on the command line.
vim.keymap.set('v', '<leader>gh', "<Esc><Cmd>'<,'>DiffviewFileHistory<CR>")

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

-- Copilot. Ghost text beside the cursor, and deliberately NOT a cmp source.
--
-- The panel is off: it is a separate split of ten alternative completions,
-- which is a different activity from typing, and <leader>ff already exists for
-- when you want to go looking for something.
--
-- hide_during_completion is the plugin's own default and is left on -- it
-- suppresses the ghost text while the cmp menu is open, so the two never draw
-- over each other. That is the whole of the interference problem, handled
-- upstream; nothing here needs to hook cmp's events.
-- copilot.lua wants node >= 22 and errors out on anything older. nvm keeps
-- several versions side by side and only puts ONE of them on PATH, so the
-- usable binary is frequently installed and simply not active -- and switching
-- the nvm default to satisfy an editor plugin would change the node every
-- other tool on this box runs, which is the wrong trade.
--
-- So: use PATH's node when it is new enough, otherwise find the newest nvm
-- version that is, and point only copilot at it. Nothing else moves. Resolved
-- rather than hardcoded so the path survives a node upgrade and a different
-- machine.
local function node_for_copilot()
  local function major(v) return tonumber((v or ''):match('^v?(%d+)')) or 0 end

  local on_path = vim.fn.system({ 'node', '--version' }):gsub('%s+$', '')
  if vim.v.shell_error == 0 and major(on_path) >= 22 then
    return nil                      -- nil means "just use `node`"
  end

  -- Bound to a local first: `a or b .. c` parses as `a or (b .. c)` in lua,
  -- because .. binds tighter than or -- so inlining this drops the suffix
  -- whenever NVM_DIR is set, and the glob silently matches nothing.
  local nvm = vim.env.NVM_DIR or (vim.env.HOME .. '/.nvm')
  local best, best_ver = nil, 0
  for _, dir in ipairs(vim.fn.glob(nvm .. '/versions/node/v*', true, true)) do
    local v = major(vim.fs.basename(dir))
    local bin = dir .. '/bin/node'
    if v >= 22 and v > best_ver and vim.uv.fs_stat(bin) then
      best, best_ver = bin, v
    end
  end
  return best                       -- nil if none: copilot says so itself
end

-- :CopilotWhy -- why copilot is or is not live in this buffer. `:Copilot status`
-- says only "not attached based on should_attach config", which is the one
-- thing you already knew; this names the rule.
vim.api.nvim_create_user_command('CopilotWhy', function()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local off = require('copilot.config').filetypes[ft] == false
  local why =
      not vim.bo[buf].buflisted and 'buffer is not buflisted'
      or vim.bo[buf].buftype ~= '' and ("buftype is '" .. vim.bo[buf].buftype .. "', not a file")
      or off and ("filetype '" .. ft .. "' is excluded")
      or nil
  vim.notify(('copilot %s: %s'):format(why and 'OFF' or 'ON', why or 'attached'),
    why and vim.log.levels.WARN or vim.log.levels.INFO)
end, { desc = 'why copilot is or is not attached to this buffer' })

require('copilot').setup({
  copilot_node_command = node_for_copilot(),
  panel = { enabled = false },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    -- Keys chosen around two things already using the obvious ones.
    --
    -- Copilot's default accept is <M-l>, which CANNOT work here: tmux binds
    -- M-l to select-pane -R with `bind -n`, so tmux consumes it and nvim never
    -- sees the key at all. Same for <M-Right>/<M-Down> (the usual accept_word
    -- and accept_line), which tmux takes for pane movement.
    --
    -- <Tab> is cmp's, and stays cmp's. <C-y> is cmp's confirm via
    -- preset.insert. So accept is <M-y> -- free in both tmux and nvim, and
    -- `y` for yes reads the same as <C-y> did.
    keymap = {
      accept      = '<M-y>',
      accept_word = '<M-w>',   -- take just the next word; the rest is usually wrong
      accept_line = false,
      next        = '<M-]>',
      prev        = '<M-[>',
      dismiss     = '<C-]>',
    },
  },

  -- Filetypes where a suggestion is either useless or actively unwanted. The
  -- dotenv/secret ones matter for the same reason as the repo list above:
  -- everything in the buffer is context, and a .env is nothing but secrets.
  filetypes = {
    ['*'] = true,
    gitcommit = false,     -- write your own commit messages
    gitrebase = false,
    hgcommit = false,
    dotenv = false,
    ['dap-repl'] = false,  -- a live frame, not a file
  },
})

-- Ghost text should not look like code you wrote. `Comment` is the plugin's
-- default and is already dim, but tokyonight's comment colour is close enough
-- to the foreground at this contrast that a suggestion reads as real. Italic
-- separates them at a glance without another colour to learn.
vim.api.nvim_set_hl(0, 'CopilotSuggestion', { link = 'Comment', italic = true, default = false })

-- <leader>ct -- suggestions off for this buffer and on again. For reading
-- rather than writing, where a suggestion appearing under the cursor every
-- time you pause is pure noise.
vim.keymap.set('n', '<leader>ct', function()
  require('copilot.suggestion').toggle_auto_trigger()
  vim.notify('copilot: ' .. (vim.b.copilot_suggestion_auto_trigger and 'on' or 'off') .. ' (this buffer)')
end)

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
    -- K is hover docs normally, and the VALUE of the thing under the cursor
    -- while a session is stopped -- at a breakpoint that is the question you
    -- actually have, and it is the key your hands already reach for. The docs
    -- are still there the moment the session ends. <leader>de is the same
    -- evaluation asked for explicitly, and the one that works over a visual
    -- selection.
    vim.keymap.set('n', 'K', function()
      local s = require('dap').session()
      if s and s.stopped_thread_id then
        return require('dapui').eval(nil, { enter = true })
      end
      vim.lsp.buf.hover()
    end, opts)                                                    -- hover docs / value here
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

-- Values printed beside the code that produced them. This is the part that
-- makes a stopped frame readable without looking at the scopes pane at all --
-- the one thing VS Code has no equivalent for.
--
-- Two defaults are worth overriding, both about space:
--
--   * virt_text_pos. On nvim 0.10+ this plugin defaults to `inline`, which
--     INSERTS the value into the line and pushes your actual code rightwards to
--     make room. A dict with six keys can shove the end of the statement off
--     screen. `eol` parks every value past the end of the line instead, in
--     space that was empty anyway, so the code never moves. The cost is that
--     values are no longer adjacent to their variable -- which is why eol mode
--     labels them `name = value` and inline mode doesn't.
--
--   * length. A repr is however long the object is: a dataframe row, a list of
--     500 floats, a nested dict. Truncating is the whole difference between
--     "the line has a hint on it" and "the line is gone".
--
-- The full value is never more than one key away -- K on the variable, or
-- <leader>de over a selection, or <leader>da to pin it in the watches pane --
-- so the virtual text only has to be enough to RECOGNISE a value, not read it.
-- 40 characters is about a short list, a number, a bool, or the head of a
-- string.
local vt_limit = 40
local vt_full = false      -- <leader>dv flips this

require('nvim-dap-virtual-text').setup({
  virt_text_pos = 'eol',
  -- Trailing `, ` between several variables on one line, rather than the
  -- default bare comma -- at end of line they run together otherwise.
  separator = ', ',

  display_callback = function(variable, _, _, _, opts)
    -- Newlines first: a multi-line repr rendered as virtual text silently eats
    -- everything after the first line, so flatten before measuring.
    local value = variable.value:gsub('%s+', ' ')
    -- Count and cut in CHARACTERS, not bytes. A byte-wise :sub() splits a
    -- multibyte codepoint down the middle and the orphaned lead byte renders
    -- as `<c3>`, which is worse than the text it replaced. strcharpart cannot
    -- land mid-codepoint, so the limit also means what it says on a line of
    -- accented or non-latin text.
    if not vt_full and vim.fn.strchars(value) > vt_limit then
      value = vim.fn.strcharpart(value, 0, vt_limit) .. '…'
    end
    if opts.virt_text_pos == 'inline' then
      return ' = ' .. value
    end
    return variable.name .. ' = ' .. value
  end,
})

-- <leader>dv -- expand every value to its full length, and again to collapse.
-- The escape hatch for the one variable that is the whole reason you stopped:
-- flip it on, read it, flip it back, without touching the config.
vim.keymap.set('n', '<leader>dv', function()
  vt_full = not vt_full
  require('nvim-dap-virtual-text').refresh()
  vim.notify('virtual text: ' .. (vt_full and 'full values' or vt_limit .. ' columns'))
end)

-- <leader>dV -- off entirely. For when the line is long enough that even a
-- truncated hint is in the way, and the scopes pane is the better place to read.
vim.keymap.set('n', '<leader>dV', function()
  local vt = require('nvim-dap-virtual-text')
  vt.toggle()
  vim.notify('virtual text: ' .. (vt.is_enabled() and 'on' or 'off'))
end)

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
-- <leader>dR -- rerun the last configuration, skipping the picker.
--
-- nvim-dap keeps that configuration in a module-local (`local last_run`), set
-- inside dap.run(). So it does NOT survive restarting nvim: after a restart the
-- key prints "No configuration available to re-run" at info level, which is
-- quiet enough to read as the key being broken.
--
-- Tracked here by listening for event_initialized -- the flag says whether THIS
-- nvim has ever launched or attached, which is exactly the condition for
-- last_run being set -- and falling back to the picker, so the key always does
-- the thing you wanted rather than nothing.
local dap_has_run = false
dap.listeners.after.event_initialized.track_run_last = function() dap_has_run = true end

vim.keymap.set('n', '<leader>dR', function()
  if dap_has_run then return dap.run_last() end
  vim.notify('nothing to re-run yet -- picking a configuration')
  dap.continue()
end)

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
-- <leader>dw -- straight into the watches pane, and <leader>dW straight into
-- adding one. The pane is the bottom quarter of the sidebar, so reaching it by
-- hand is <C-w>h then <C-w>j then i -- three keystrokes to get to the keystroke
-- that does the work, every time you think of something to watch.
--
-- Falls back to dap-ui's floating watches when the sidebar is closed (you shut
-- it with <leader>du, or there is no session yet): same element, same state,
-- just drawn over the code instead of beside it. `q` closes the float.
--
-- Generic over the element rather than watches-only: scopes, stacks and
-- breakpoints live in the same sidebar and all want the same in-and-out-on-one-
-- key treatment. Only watches takes `add` -- the others have nothing to type
-- into.
local function focus_element(id, add)
  local ft = 'dapui_' .. id
  -- Already there: the same key takes you back, so it is one binding in and the
  -- same binding out rather than <C-w>p as a separate thing to remember.
  if vim.bo.filetype == ft then
    return vim.cmd('wincmd p')
  end
  local win
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == ft then win = w break end
  end
  if win then
    vim.api.nvim_set_current_win(win)
  else
    dapui.float_element(id, { enter = true })
  end
  if not add then return end
  -- The float opens asynchronously (dap-ui runs it through nio), so `i` cannot
  -- be sent straight away -- it would land in whatever buffer is still current
  -- and start editing the FILE. Wait for the watches buffer to arrive instead,
  -- and give up rather than retry forever if it never does.
  local tries = 0
  local function insert()
    if vim.bo.filetype == ft then
      vim.api.nvim_feedkeys('i', 'n', false)
    elseif tries < 20 then
      tries = tries + 1
      vim.defer_fn(insert, 25)
    end
  end
  insert()
end
vim.keymap.set('n', '<leader>dw', function() focus_element('watches', false) end)  -- toggle in and out
vim.keymap.set('n', '<leader>dW', function() focus_element('watches', true) end)   -- in, adding one
vim.keymap.set('n', '<leader>ds', function() focus_element('scopes') end)          -- locals/globals, in and out
vim.keymap.set('n', '<leader>dS', function() focus_element('stacks') end)          -- the call stack, in and out

-- <leader>dd -- into the sidebar and back out WITHOUT naming an element: the
-- pane you were last in, which is the one you want nine times in ten. The three
-- keys above are for going straight to a named pane; this is for when you just
-- want in, and it is the same key back out.
--
-- Together with <Tab> below it means the sidebar is reachable and traversable
-- without <C-w> anything, which matters because <C-h/j/k/l> cannot be the
-- window keys here: three of the four are stepping commands.
local last_element = 'scopes'
vim.api.nvim_create_autocmd('WinEnter', {
  callback = function()
    local id = vim.bo.filetype:match('^dapui_(.*)')
    if id then last_element = id end
  end,
  desc = 'remember which dap pane you were last in',
})
vim.keymap.set('n', '<leader>dd', function() focus_element(last_element) end)

-- Debug the test the cursor is inside, no configuration and no picker. pytest
-- and unittest both; dap-python reads the enclosing def/class from treesitter.
vim.keymap.set('n', '<leader>dm', function() require('dap-python').test_method() end)

-- ---------------------------------------------------------------------------
-- Moving around a live session.
--
-- Everything above is "what to do"; this is "where to be while doing it". The
-- cost it removes is the window round-trip: a glance at a variable that goes
-- <C-w>h, read, <C-w>p is three keystrokes of overhead wrapped around the one
-- that did the work, and you pay it every time you get curious.
-- ---------------------------------------------------------------------------

-- Stopped, and stopped somewhere we can act on. `dap.session()` alone is also
-- true while the program is RUNNING, and stepping then does nothing visible --
-- so the fall-through keys below ask for the thread as well.
local function dap_stopped()
  local s = dap.session()
  return s ~= nil and s.stopped_thread_id ~= nil
end

-- One-key stepping, from any window including the dap-ui panes.
--
-- <leader>dl/dj/dk stay -- they are the mnemonic set, and the comment above
-- explains the l/j/k geometry they share with these. But three keystrokes is
-- fine for one step and tiring for thirty, and they only fire in the code
-- window, so a step thought of while reading the scopes pane costs a trip back
-- first. These are the same three moves on one keystroke from wherever the
-- cursor happens to be.
--
-- Nothing is shadowed: with no session stopped each key does what it always
-- did, so <C-l> still redraws and clears the search highlight when you are not
-- debugging.
local function when_stopped(action, fallback)
  return function()
    if dap_stopped() then return action() end
    if fallback then fallback() end
  end
end
vim.keymap.set('n', '<C-l>', when_stopped(dap.step_over, function()
  vim.cmd('nohlsearch')
  vim.cmd('mode')          -- the redraw half of what <C-l> normally does
end), { desc = 'dap step over / redraw' })
vim.keymap.set('n', '<C-j>', when_stopped(dap.step_into, function()
  vim.cmd('normal! j')
end), { desc = 'dap step into / line down' })
vim.keymap.set('n', '<C-k>', when_stopped(dap.step_out), { desc = 'dap step out' })

-- The expression the cursor is on. <cexpr> in normal mode, which takes the
-- whole dotted name (`self.cache`, not just `cache`); the selection in visual,
-- for the things <cexpr> cannot see on its own -- `rows[i]['price']`, a slice,
-- a call. Read straight out of the buffer rather than via a yank, so neither
-- the cursor nor any register moves.
local function current_expr()
  local m = vim.fn.mode()
  if m == 'v' or m == 'V' or m == '\22' then
    local a, b = vim.fn.getpos('v'), vim.fn.getpos('.')
    local sr, sc, er, ec = a[2], a[3], b[2], b[3]
    if sr > er or (sr == er and sc > ec) then sr, sc, er, ec = er, ec, sr, sc end
    if m == 'V' then sc, ec = 1, #vim.fn.getline(er) end
    local lines = vim.api.nvim_buf_get_text(0, sr - 1, sc - 1, er - 1, ec, {})
    return (table.concat(lines, ' '):gsub('^%s+', ''):gsub('%s+$', ''))
  end
  return vim.fn.expand('<cexpr>')
end

-- <leader>da -- watch the thing under the cursor WITHOUT leaving the code.
--
-- <leader>dW gets you into the pane to type an expression, which is right when
-- you are inventing one. But most watches are a name already on screen, and for
-- those the round trip is the entire cost of the operation. Here the cursor
-- does not move, the pane is not focused, and the value simply appears in the
-- sidebar -- so watching six things is six keystrokes-worth of `<leader>da`,
-- not six trips.
--
-- Works before a session starts, too: dap-ui keeps watches across sessions
-- (`allow_without_session`), so you can line them all up and then hit <F5>.
local function add_watch(expr)
  local w = dapui.elements.watches
  if not w then
    return vim.notify('dap-ui watches not registered yet', vim.log.levels.WARN)
  end
  expr = expr or current_expr()
  if expr == '' then
    return vim.notify('nothing under the cursor to watch', vim.log.levels.WARN)
  end
  w.add(expr)
  vim.notify('watching  ' .. expr)
  -- Leave visual mode; staying in it over an expression already watched is
  -- never what the next keystroke wants.
  if vim.fn.mode() ~= 'n' then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  end
end
vim.keymap.set({ 'n', 'v' }, '<leader>da', function() add_watch() end)
vim.keymap.set('n', '<leader>dA', function()
  -- The one <leader>da cannot reach: an expression that is nowhere in the file,
  -- e.g. `len(self.pending)` or `[r.id for r in rows]`. Still no round trip.
  local expr = vim.fn.input('Watch: ')
  if expr ~= '' then add_watch(expr) end
end)
vim.keymap.set('n', '<leader>dX', function()
  -- Watches outlive the session that made them, which is the point -- and the
  -- reason the pane fills up with expressions from three bugs ago.
  local w = dapui.elements.watches
  if not w then return end
  local n = #w.get()
  for i = n, 1, -1 do w.remove(i) end
  vim.notify(string.format('cleared %d watch(es)', n))
end)

-- <leader>dD -- the dataframe under the cursor, in visidata. Evaluates
-- `.to_csv('/tmp/peek.csv', index=False)` in the stopped frame and opens `vd`
-- on the result, which is the two-step repl workflow on one key.
--
-- Written by the debuggee rather than by nvim, because that is where the object
-- lives, and read by a separate `vd` process because visidata is installed as a
-- uv tool with its own venv and is not importable from the project interpreter.
-- Even if it were, the debuggee's stdout is a dap terminal buffer and not a
-- tty, so an in-process viewer would have nothing to draw on.
--
-- A tab, not a split: a spreadsheet wants the whole window, and closing it puts
-- the debug layout back exactly as it was.
vim.keymap.set({ 'n', 'v' }, '<leader>dD', function()
  local session = dap.session()
  if not session then
    return vim.notify('no debug session to dump from', vim.log.levels.WARN)
  end
  local expr = current_expr()
  if expr == '' then
    return vim.notify('nothing under the cursor to dump', vim.log.levels.WARN)
  end

  local path = '/tmp/peek.csv'
  session:evaluate(expr .. ".to_csv('" .. path .. "', index=False)", function(err)
    if err then
      return vim.notify(require('dap.utils').fmt_error(err), vim.log.levels.ERROR)
    end

    -- A vd already open on the file stays open. It holds your sorts, your
    -- selections and your cursor, and Ctrl+R picks the new dump up in place; a
    -- second tab would throw all of that away. So the step-and-re-dump loop is
    -- <leader>dD, Ctrl+R, and you land on the reload keystroke.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.b[buf].vd_peek then
        local win = vim.fn.win_findbuf(buf)[1]
        if win then
          vim.api.nvim_set_current_win(win)   -- switches tabpage too, if it is in another
          vim.cmd('startinsert')
          return vim.notify(expr .. ' -> ' .. path .. ', Ctrl+R to reload')
        end
        vim.api.nvim_buf_delete(buf, { force = true })   -- hidden, and its job is gone
      end
    end

    vim.cmd('tabnew')
    local buf = vim.api.nvim_get_current_buf()
    vim.fn.jobstart({ 'vd', path }, {
      term = true,
      -- Quitting vd takes the tab with it, rather than leaving a dead terminal
      -- buffer showing [Process exited 0] to close by hand.
      on_exit = function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end,
    })
    vim.b.vd_peek = true   -- tagged so the next dump finds this window
    vim.cmd('startinsert')
  end)
end)

-- <Esc> in any debugger pane -- back to the code, one key, no <C-w> anything.
-- The code window is found rather than remembered (`wincmd p` is wrong as soon
-- as you have hopped between two panes): it is the window showing a real file,
-- so not a dap-ui element, not the repl, not the <leader>dM terminal split.
local function focus_source()
  local cur = vim.api.nvim_get_current_win()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if w ~= cur then
      local b = vim.api.nvim_win_get_buf(w)
      if vim.bo[b].buftype == ''
        and not vim.bo[b].filetype:match('^dapui_')
        and vim.bo[b].filetype ~= 'dap-repl' then
        return vim.api.nvim_set_current_win(w)
      end
    end
  end
  vim.cmd('wincmd p')   -- nothing qualified; the old behaviour is still better than nothing
end

-- Moving BETWEEN the panes once you are in one. Sorted by position on screen
-- rather than by creation order, so <Tab> walks the sidebar top to bottom the
-- way it looks, and the repl at the bottom is the last stop before it wraps.
local function cycle_panes(step)
  local wins = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
    if ft:match('^dapui_') or ft == 'dap-repl' then table.insert(wins, w) end
  end
  if #wins < 2 then return end
  table.sort(wins, function(a, b)
    local pa, pb = vim.api.nvim_win_get_position(a), vim.api.nvim_win_get_position(b)
    if pa[1] ~= pb[1] then return pa[1] < pb[1] end
    return pa[2] < pb[2]
  end)
  local cur = vim.api.nvim_get_current_win()
  for i, w in ipairs(wins) do
    if w == cur then
      return vim.api.nvim_set_current_win(wins[(i - 1 + step) % #wins + 1])
    end
  end
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'dapui_scopes', 'dapui_stacks', 'dapui_watches', 'dapui_breakpoints', 'dap-repl' },
  callback = function(ev)
    -- Normal mode only. The watches pane is a prompt buffer, where <Esc> in
    -- INSERT has to keep meaning "stop typing this expression".
    vim.keymap.set('n', '<Esc>', focus_source, { buffer = ev.buf, desc = 'back to the code' })
    -- <Tab> to the next pane, <S-Tab> to the previous, wrapping. Buffer-local,
    -- so <Tab> keeps its global meaning everywhere else, and normal mode only,
    -- so completion in the repl and the watches prompt is untouched.
    vim.keymap.set('n', '<Tab>', function() cycle_panes(1) end, { buffer = ev.buf, desc = 'next dap pane' })
    vim.keymap.set('n', '<S-Tab>', function() cycle_panes(-1) end, { buffer = ev.buf, desc = 'previous dap pane' })
  end,
})

-- <leader>df -- back to the frame the program is actually stopped in, from
-- wherever reading the code took you. The counterpart to <leader>dK/<leader>dJ:
-- those change which frame you are looking at, this one puts the cursor back on
-- the line that is about to execute in the frame you have selected.
vim.keymap.set('n', '<leader>df', dap.focus_frame)

-- <leader>dL -- every breakpoint in the session, in the quickfix list, so
-- `:cnext` walks them. The breakpoints PANE shows the same set but cannot jump
-- you to one; this is the version you can navigate.
vim.keymap.set('n', '<leader>dL', function() dap.list_breakpoints(true) end)

-- Stop on the line that threw -- what VS Code does when a run blows up.
--
-- debugpy can break on an exception, but nvim-dap asks for 'default' filters
-- unless told otherwise, and debugpy's default is to break on NOTHING. So a
-- traceback ends the session and you are left reading it after the frame is
-- gone, which is the one moment the locals were worth having.
--
-- `uncaught` and not `raised`: raised stops on EVERY exception, including the
-- ones a library throws and swallows on purpose -- a StopIteration per loop, a
-- KeyError inside a dict.get. Unusable in anything with pandas underneath.
-- <leader>dE adds raised for the session when you actually want it.
--
-- Set on defaults rather than per-run: session.lua applies these at
-- initialisation, so it covers every route in -- <F5>, <leader>dm, <leader>dM.
dap.defaults.python.exception_breakpoints = { 'uncaught' }

-- <leader>dE -- cycle what stops the program, mid-session. `raised` is how you
-- find the exception that something upstream is catching and hiding.
local exc_modes = { { 'uncaught' }, { 'raised', 'uncaught' }, {} }
local exc_names = { 'uncaught', 'raised + uncaught', 'none' }
local exc_i = 1
vim.keymap.set('n', '<leader>dE', function()
  if not dap.session() then
    return vim.notify('no session -- exception filters are set at launch', vim.log.levels.WARN)
  end
  exc_i = exc_i % #exc_modes + 1
  dap.set_exception_breakpoints(exc_modes[exc_i])
  vim.notify('break on: ' .. exc_names[exc_i])
end)

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

-- One terminal split, reused. Every run below -- make, make DEBUG=1, and a bare
-- python file -- goes through here, so a session of ten runs leaves one 9-row
-- split at the bottom rather than ten stacked ones fighting over the screen.
--
-- A terminal buffer is bound to its job for life: you cannot restart a command
-- in one. So reuse is of the WINDOW -- a fresh buffer is opened in place and the
-- previous one deleted, which also kills a run still going. That is the intent:
-- <leader>dM twice in a row means "replace that run with this one", not "have
-- both". Read the output before rerunning, or :split the buffer to keep it.
--
-- 9 rows: enough to read the tail of a run and see it is progressing, without
-- taking a third of the screen off the code the whole time.
local function run_in_terminal(cmd)
  -- Every tagged buffer, not just one: a config reloaded mid-session, or splits
  -- made by hand, can leave more than one behind, and they all go.
  local old = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.b[buf].dap_make_terminal then
      table.insert(old, buf)
    end
  end

  -- Prefer a window that is already showing one -- that is the split to take
  -- over. If they are all hidden, there is nothing on screen to reuse.
  local win
  for _, buf in ipairs(old) do
    win = vim.fn.win_findbuf(buf)[1]
    if win then break end
  end

  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd('enew')          -- fresh, empty, unmodified: what jobstart needs
  else
    vim.cmd('botright 9new')
  end
  for _, buf in ipairs(old) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })   -- force: kills a live job
    end
  end

  vim.fn.jobstart(cmd, { term = true })
  vim.b.dap_make_terminal = true   -- tagged so <leader>dq can find it again
  vim.cmd('wincmd p')   -- back to the code, so breakpoints stay one keypress away
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
    run_in_terminal(cmd)

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

-- <leader>rr -- run the current python file directly, no Makefile. The gap
-- <leader>mm leaves: make_run needs a `## `-documented Makefile above the file,
-- which a one-script project doesn't have. Same terminal-split behaviour as
-- make_run (9 rows, outlives the run, focus back on the code), but the command
-- is just `python <file>`. The interpreter is the nearest .venv above the file
-- -- the same one dap-python picks for a debug session, so a run and a debug of
-- the same file use the same dependencies -- falling back to python3 if none.
vim.keymap.set('n', '<leader>rr', function()
  local file = vim.fn.expand('%:p')
  if vim.bo.filetype ~= 'python' or file == '' then
    return vim.notify('Not a saved python file', vim.log.levels.WARN)
  end
  vim.cmd('write')   -- run what's on screen, not the last save
  local venv = vim.fs.find('.venv', { upward = true, path = vim.fs.dirname(file), type = 'directory' })[1]
  local py = venv and (venv .. '/bin/python') or 'python3'
  -- Script args, the way make_run asks for make vars: e.g. `--no-cache`. Enter for none.
  local args = vim.fn.input('args (optional): ')
  local cmd = vim.fn.shellescape(py) .. ' ' .. vim.fn.shellescape(file) .. ' ' .. args
  run_in_terminal(cmd)
end)   -- run the current python file, no Makefile

-- <leader>re -- the last traceback in the run split, as a quickfix list, cursor
-- on the line that actually threw.
--
-- The other half of what VS Code does with a crash: <leader>dE covers a run
-- under the debugger, but <leader>rr and <leader>mm are the everyday case and
-- their traceback is dead text in a terminal buffer. gf cannot follow it --
-- python's `File "x.py", line 42` is not a format vim knows.
--
-- Parsed with a lua pattern rather than 'errorformat'. An efm capable of
-- python's multi-line traceback is a write-only expression of backslashes, and
-- this needs to do one more thing than efm can anyway: prefer the LAST
-- traceback in the buffer (the most recent run) over the first.
local function traceback_to_quickfix()
  local buf
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == 'terminal' then
      buf = b   -- last one wins: the run split is reused, so it is the newest
    end
  end
  if not buf then return vim.notify('no terminal buffer', vim.log.levels.WARN) end

  local raw = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local start
  for i = #raw, 1, -1 do
    if raw[i]:match('^Traceback %(most recent call last%)') then start = i break end
  end
  if not start then return vim.notify('no traceback in the run output', vim.log.levels.WARN) end

  -- Joined with no separator before parsing, because a terminal HARD-WRAPS at
  -- the pane width: one traceback line becomes two buffer lines with the break
  -- anywhere, including the middle of a path. Read line by line, any path
  -- longer than the split is wide simply never matches -- and the run split is
  -- nine rows of an 80-column pane, so that is most real paths here.
  -- Joining means the pattern need not know where the wrap fell: `", line `
  -- cannot occur inside a filename, so the lazy capture still stops correctly.
  local blob = table.concat(vim.list_slice(raw, start + 1), '')
  local items = {}
  for file, lnum, fn in blob:gmatch('File "(.-)", line (%d+), in ([%w_<>.]+)') do
    table.insert(items, { filename = file, lnum = tonumber(lnum), text = 'in ' .. fn })
  end
  if #items == 0 then return vim.notify('traceback had no frames', vim.log.levels.WARN) end

  -- The exception line is the last unindented line naming a type. Scanned over
  -- the raw lines, not the blob: joining destroys the line starts that identify
  -- it, and a wrapped message still carries its type in the first segment,
  -- which is the half worth having.
  local message
  for i = #raw, start, -1 do
    if raw[i]:match('^%a[%w.]*:%s') or raw[i]:match('^%a[%w.]*Error') then message = raw[i] break end
  end

  -- The exception belongs to the innermost frame, which is where you want to
  -- land, so it replaces that frame's text rather than becoming a frameless
  -- entry the quickfix list cannot jump to.
  if message then items[#items].text = message end
  vim.fn.setqflist({}, ' ', { title = message or 'traceback', items = items })
  vim.cmd('copen | cbottom')
  vim.cmd('cc ' .. #items)   -- innermost frame: the line that actually threw
  vim.notify(message or 'traceback')
end
vim.keymap.set('n', '<leader>re', traceback_to_quickfix)

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
-- Always reserve the sign column. On the default 'auto' it only exists while
-- something is in it, so the first gitsigns hunk shifts the whole file two
-- columns right and undoing it shifts back -- text that jitters sideways as you
-- edit. Reserving it costs two columns permanently and never moves.
vim.opt.signcolumn = 'yes'
vim.opt.autoread = true
-- CursorHold's delay, and so how long an idle nvim waits before noticing a file
-- changed underneath it. The 4s default is too long to feel automatic.
vim.opt.updatetime = 250
vim.opt.swapfile = false
vim.opt.termguicolors = true
-- linematch is neovim's own diff refinement, off by default: without it a line
-- with one word changed shows as a whole line deleted and a whole line added.
-- 60 is the cap on how many lines within a hunk it will try to align. Applies
-- to every diff nvim draws -- :diffthis, and gitsigns' hunk previews.
vim.opt.diffopt:append('linematch:60')

-- Keep 8 lines of context above and below the cursor. This does more for how
-- scrolling FEELS than any animation setting: with scrolloff at 0 the view only
-- moves once the cursor hits the very edge, so reading down a file is a series
-- of lurches. At 8 the window slides continuously and you are never reading the
-- last visible line with the next one hidden.
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Scroll by screen row rather than buffer line. With wrap on, a long line
-- occupies several rows, and without this the whole line snaps in or out at
-- once -- the jerkiest thing scrolling does in a file with long strings.
vim.opt.smoothscroll = true

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
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'TermLeave', 'InsertLeave' }, {
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.schedule(function() vim.cmd('checktime') end)
    end
  end,
  desc = 'reload buffers changed on disk',
})

-- The autocmds above all need something to HAPPEN: a focus change, a buffer
-- switch, the cursor going idle after a move. They all miss the case this setup
-- is actually built around, which is nvim sitting in one tmux pane, visible and
-- focused, while claude edits the file in the pane next door. No focus change,
-- no keystroke, so nothing ever asks, and the buffer stays stale until you
-- happen to touch it.
--
-- libuv watches the file itself, so the reload happens the moment it changes
-- and costs no interaction at all. One fd per file buffer.
--
-- The watch is restarted after every event: a writer that saves by writing a
-- temp file and renaming it over the original leaves the watch pointing at an
-- inode nothing will ever touch again, so a single-shot watch reloads once and
-- then goes quiet. inotify under WSL also only covers the Linux filesystem, so
-- a file under /mnt/c never fires and the autocmds above remain its fallback.
local watchers = {}

local function unwatch(buf)
  local w = watchers[buf]
  if w then
    w:stop()
    watchers[buf] = nil
  end
end

local function watch(buf)
  unwatch(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= '' then return end
  local path = vim.api.nvim_buf_get_name(buf)
  if path == '' or vim.fn.filereadable(path) == 0 then return end

  local w = vim.uv.new_fs_event()
  if not w then return end
  watchers[buf] = w
  w:start(path, {}, function()
    -- Callback lands on the libuv thread, where the nvim API is off limits.
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then return unwatch(buf) end
      vim.cmd('checktime')
      watch(buf)
    end)
  end)
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
  callback = function(ev) watch(ev.buf) end,
  desc = 'watch the file on disk for outside edits',
})
vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
  callback = function(ev) unwatch(ev.buf) end,
  desc = 'drop the file watcher with the buffer',
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
