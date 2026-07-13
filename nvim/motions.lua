-- ============================================================================
--  motions.lua — get around as fast as possible
-- ============================================================================
--
--  Open in nvim:   nvim nvim/motions.lua
--
--  This is a hands-on drill file for MOVING, not editing. Every section has a
--  `TRY IT` with a real target in this buffer. Do them in normal mode (press
--  `jk` or <Esc> first). Stay off the arrow keys — the whole point is to reach
--  for these instead.
--
--  The golden rule: NEVER press `hjkl` more than a couple times in a row. If a
--  target is far, there's a faster motion below to get there in one jump.
--
--  TIP: counted jumps like `5j` are aimed by READING the gutter, never by
--  counting rows. init.lua sets hybrid line numbers (number + relativenumber),
--  so the cursor line shows its absolute number and every other line shows how
--  far away it is — the number you type. `:Drill counts` drills exactly this.
-- ============================================================================


-- ----------------------------------------------------------------------------
--  1. WITHIN A LINE  — stop walking with `l`
-- ----------------------------------------------------------------------------
--    w / W   forward to start of next word  (W = ignore punctuation)
--    b / B   back to start of previous word
--    e / ge  end of word (forward / backward)
--    0       first column      ^   first non-blank      $   end of line
--    f{c}    jump forward ONTO the next {c} on this line
--    t{c}    jump forward UP TO (just before) the next {c}
--    F / T   same, backwards            ;  repeat last f/t      ,  reverse it
--    %       jump to the matching ) ] }
--
--  TRY IT on the line below (put cursor at its start with `0`):
--    * press `w` a few times to hop word-to-word
--    * press `$` to shoot to the end, `^` to come back to the first word
--    * press `f(` to land on the paren, then `%` to bounce to its match
--    * press `t,` to stop right before the comma, then `;` for the next one
local sample = "choose(alpha, beta, gamma, delta)"   -- targets: ( ) , , words


-- ----------------------------------------------------------------------------
--  2. FIND-CHAR IS YOUR FASTEST HORIZONTAL MOVE
-- ----------------------------------------------------------------------------
--  `f` / `t` beat mashing `w`. Think "I want to be AT the x" -> `fx`.
--  Overshot? `,` steps back. Wrong char? just `f{other}`.
--
--  TRY IT: from column 0 of the line below, reach the word "needle" in ONE
--  press with `fn` (then `;` if it lands on the wrong n). Then `$` and `Fh`
--  to fly back to the "h" in "haystack".
--    haystack haystack haystack needle haystack haystack


-- ----------------------------------------------------------------------------
--  3. UP AND DOWN THE FILE
-- ----------------------------------------------------------------------------
--    gg      top of file            G       bottom of file
--    {count}G / :{count}   go to an absolute line number  (e.g. 120G)
--    {count}j / {count}k   jump N lines (5j = down 5) — pair with relativenumber
--    {  }    previous / next blank-line paragraph  (great for code blocks)
--    Ctrl-d  half page down         Ctrl-u  half page up   (keeps context)
--    Ctrl-f  full page forward      Ctrl-b  full page back
--    H M L   jump to the top / middle / bottom of the VISIBLE screen
--    zz zt zb  scroll current line to center / top / bottom (reframe, don't move)
--
--  TRY IT:
--    * press `G` to hit the bottom of the file, then `gg` to snap back here
--    * press `}` a few times to skip paragraph-by-paragraph through this file
--    * press `L` to drop to the bottom of the screen, `H` for the top, `M` mid
--    * press `Ctrl-d`, then `zz` to recenter what you land on


-- ----------------------------------------------------------------------------
--  4. SEARCH — teleport to anything by name
-- ----------------------------------------------------------------------------
--    /text<CR>   search forward       ?text<CR>   search backward
--    n / N       next / previous match (N = opposite direction)
--    *  / #      search for the WORD under the cursor, forward / back
--    (with hlsearch, `:noh` clears the highlight when you're done)
--
--  Searching is usually the FASTEST way to cross a file — if you can see it or
--  name it, `/` gets you there without counting a single line.
--
--  TRY IT: put the cursor on the word `waypoint` below and press `*` — you'll
--  jump straight to its next occurrence; keep pressing `n` to cycle them.
local waypoint = 1
-- ... some distance later ...
local reuse_the_waypoint = waypoint + waypoint   -- * from above lands here


-- ----------------------------------------------------------------------------
--  5. MARKS & THE JUMP LIST — leave, then come back
-- ----------------------------------------------------------------------------
--    m{a-z}   drop a named mark here      `{a-z}   jump back to that mark
--    ``       jump back to where you were BEFORE the last big jump
--    Ctrl-o   go back through your jump history (older positions)
--    Ctrl-i   go forward again (Tab)      :jumps   see the whole list
--    gd / gr  (this config, LSP) jump to a symbol's definition / references
--    ]d / [d  (this config, LSP) jump to the next / previous diagnostic
--    K        (this config, LSP) peek hover docs without leaving your spot
--
--  This is how you bounce between two spots without pinning them in harpoon.
--
--  TRY IT: press `ma` here to set mark 'a'. Now `G` to the bottom, poke
--  around, then press `` `a `` to teleport back to this exact line. Try `Ctrl-o`
--  / `Ctrl-i` to walk your jump history.


-- ----------------------------------------------------------------------------
--  6. MOTIONS + OPERATORS = editing at the same speed
-- ----------------------------------------------------------------------------
--  Every motion above doubles as a target for an operator. Same keys, now they
--  DO something over the distance they'd move:
--    d{motion}  delete   c{motion}  change   y{motion}  yank
--    dw  d$  d^        ci(  "change inside ()"      di"  yi{
--    daw "delete a word"    dt,  "delete up to the comma"    d/foo  to a search
--    ciw is the workhorse: change the whole word the cursor is on, anywhere in it
--
--  TRY IT: put the cursor anywhere inside the parens below and press `ci(` —
--  the args vanish and you're in insert mode ready to retype. Or `diw` on a
--  word to nuke just that word.
local edit_me = "build(one, two, three)"


-- ----------------------------------------------------------------------------
--  7. PROJECT-WIDE — when the target isn't in this file (this config)
-- ----------------------------------------------------------------------------
--  Once you're fast within a file, jumping BETWEEN files is the next win.
--  Rule of thumb: within a file use `/` and `f`; across files use telescope;
--  for the 2-4 files you live in, pin them with harpoon.
--
--  TELESCOPE  (nvim-telescope/telescope.nvim, powered by plenary.nvim)
--    <leader>ff   find files by name
--    <leader>fg   live grep — search file *contents* across the project
--    <leader>fb   jump between open buffers
--    <leader>fh   search neovim's :help docs
--
--  HARPOON  (ThePrimeagen/harpoon, branch harpoon2)
--    <leader>a    pin the current file to the list
--    <leader>h    toggle the quick menu (reorder / remove pins)
--    <leader>1    teleport to pinned file 1
--    <leader>2    teleport to pinned file 2
--    <leader>3    teleport to pinned file 3
--    <leader>4    teleport to pinned file 4


-- ----------------------------------------------------------------------------
--  8. THE REST OF YOUR KEYMAPS — every custom binding in init.lua
-- ----------------------------------------------------------------------------
--  Not strictly "motions", but this is the full set so nothing's a surprise.
--
--  LSP  (neovim/nvim-lspconfig; servers installed by mason.nvim +
--        mason-lspconfig.nvim — lua_ls is auto-installed)
--    gd           go to definition        (opens a telescope picker)
--    gr           find references         (opens a telescope picker)
--    K            hover docs
--    ]d / [d      next / previous diagnostic
--    <leader>rn   rename the symbol everywhere
--    <leader>ca   code actions (quick fixes)
--
--  COMPLETION  (hrsh7th/nvim-cmp + sources cmp-nvim-lsp, cmp-buffer, cmp-path;
--               snippets via L3MON4D3/LuaSnip + saadparwaiz1/cmp_luasnip)
--    <C-Space>    force the completion menu open
--    <Tab> / <S-Tab>   next / prev item (and hop between snippet fields)
--    <CR>         confirm the highlighted item
--    <C-f> / <C-b>     scroll the docs popup down / up
--
--  CORE  (no plugin)
--    jk           (insert mode) escape to normal mode — the one you added
--
--  See tutorial.lua for a guided, hands-on tour of these plugins.


-- ----------------------------------------------------------------------------
--  CHEAT SHEET — the 12 that matter most
-- ----------------------------------------------------------------------------
--    f{c} ;      jump onto a char on the line, repeat
--    w  b  e     word forward / back / end
--    0  ^  $     line start / first word / end
--    /  n        search, next match           *   search word under cursor
--    gg  G       top / bottom of file         {count}G  absolute line
--    {  }        paragraph up / down
--    Ctrl-d/u    half page down / up
--    H  M  L     screen top / middle / bottom
--    zz          recenter the screen
--    `` Ctrl-o   back to previous spot / jump history
--    ci(  ciw    change inside parens / word (operator + motion)
--    %           matching bracket
--
--  Practice loop: pick a visible target, ask "what's the ONE motion that gets
--  me there?", use it. When you catch yourself holding `j`, stop and count.
-- ----------------------------------------------------------------------------

return { sample = sample, waypoint = waypoint, reuse = reuse_the_waypoint, edit_me = edit_me }
