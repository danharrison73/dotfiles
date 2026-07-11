-- ============================================================================
--  tutorial.lua — a guided tour of this neovim setup
-- ============================================================================
--
--  Open this file in nvim:   nvim nvim/tutorial.lua
--
--  It walks through every tool wired up in init.lua: the editor defaults,
--  telescope, harpoon, autocompletion, and the LSP. Work top to bottom.
--
--  Because it's a Lua file, the `lua_ls` language server (auto-installed by
--  mason on first launch) attaches automatically — give it a second. If the
--  LSP sections seem dead, run `:Mason` and confirm `lua-language-server` is
--  installed, then `:LspInfo` to confirm it attached to this buffer.
--
--  The leader key is <Space> throughout.
-- ============================================================================


-- ----------------------------------------------------------------------------
--  1. EDITOR BASICS  (options + core keymaps, no plugins)
-- ----------------------------------------------------------------------------
--  init.lua sets a handful of sensible defaults you'll feel immediately:
--    * <Space> is the leader key (prefix for most custom mappings)
--    * `jk` in insert mode escapes to normal mode — try it below
--    * 2-space indentation, expandtab (tabs become spaces), shiftround
--    * absolute line numbers, cursorline highlight, true colour
--    * no swapfile; autoread + autowrite so buffers sync as you jump around
--
--  TRY IT: enter insert mode (i), type a few words on the next line, then
--  press `jk` (quickly) instead of reaching for <Esc>.



-- ----------------------------------------------------------------------------
--  2. TELESCOPE  (fuzzy finder)
-- ----------------------------------------------------------------------------
--  Your main way to move around a project. All pickers are floating windows;
--  type to fuzzy-filter, <CR> opens, <Esc> dismisses, <C-n>/<C-p> move.
--
--    <leader>ff   find files by name
--    <leader>fg   live grep — search file *contents* across the project
--    <leader>fb   switch between open buffers
--    <leader>fh   search neovim's :help docs
--
--  TRY IT: press <leader>ff and type "init" to jump to init.lua. Then come
--  back and press <leader>fg and search for "harpoon" to see grep in action.
--  (telescope also powers `gd`/`gr` in the LSP section below.)


-- ----------------------------------------------------------------------------
--  3. HARPOON  (pin the few files you actually live in)
-- ----------------------------------------------------------------------------
--  Telescope is for searching; harpoon is for the 2-4 files you return to
--  constantly. Mark them once, then teleport by number — no fuzzy typing.
--
--    <leader>a    add the current file to the harpoon list
--    <leader>h    toggle the quick menu (reorder / remove entries here)
--    <leader>1    jump to harpoon file 1
--    <leader>2    jump to harpoon file 2
--    <leader>3    jump to harpoon file 3
--    <leader>4    jump to harpoon file 4
--
--  TRY IT: press <leader>a here to pin this file, open init.lua (<leader>ff),
--  press <leader>a there too, then bounce between them with <leader>1 and
--  <leader>2. Press <leader>h to see and edit the list.


-- ----------------------------------------------------------------------------
--  4. AUTOCOMPLETION  (nvim-cmp)
-- ----------------------------------------------------------------------------
--  Completion pops up as you type. Sources are: LSP, snippets (LuaSnip),
--  words in this buffer, and filesystem paths.
--
--    <Tab> / <S-Tab>   cycle through the menu (and jump between snippet spots)
--    <CR>              confirm the highlighted item
--    <C-Space>         force the menu open
--    <C-f> / <C-b>     scroll the documentation window
--
--  TRY IT: on the blank line below, enter insert mode and type `vim.ls` then
--  wait — the menu offers `vim.lsp`, `vim.list_extend`, ... Press <Tab> to
--  pick one, then keep typing `.` to drill into the module.



-- TRY IT: type `str` on the line below and the buffer source will suggest
-- "string" and other words already used in this file.



-- ----------------------------------------------------------------------------
--  5. HOVER + GO-TO-DEFINITION + REFERENCES  (LSP)
-- ----------------------------------------------------------------------------
--  `greet` is defined here and used twice further down.

local function greet(name)
  return 'hello, ' .. name
end

--  TRY IT — put your cursor on `greet` in either call below, then:
--    K            open a hover doc (signature + inferred types)
--    gd           jump to the definition (opens a telescope picker if ambiguous)
--    gr           browse every reference in a telescope picker
--    <leader>rn   rename the symbol everywhere (leader is <Space>)

local first  = greet('ada')
local second = greet('linus')


-- ----------------------------------------------------------------------------
--  6. DIAGNOSTICS  (LSP)
-- ----------------------------------------------------------------------------
--  Problems show up inline as you go: virtual text on the line, a sign in the
--  gutter, and an underline on the offending code. The two locals below are
--  intentional:
--    * `unused_local` is assigned but never read  -> a warning
--    * calling greet() with no argument            -> a type hint

local unused_local = 42

local oops = greet()

--  TRY IT:
--    ]d / [d      jump to the next / previous diagnostic (its message floats up)
--    <leader>ca   offer code actions (e.g. "disable diagnostics")
--
--  Once you've seen them, delete `unused_local` and pass a name to greet()
--  above — watch the warnings clear as you fix them.


-- ----------------------------------------------------------------------------
--  7. SNIPPETS  (LuaSnip, surfaced through cmp)
-- ----------------------------------------------------------------------------
--  Snippet suggestions appear in the completion menu with a snippet icon.
--  Confirm one with <CR>, then use <Tab> / <S-Tab> to hop between its
--  placeholder fields. lua_ls also ships function-signature snippets, so
--  completing a function call can fill in its arguments for you.


-- ----------------------------------------------------------------------------
--  Done! This file is just a sandbox — edit it freely or delete it. The real
--  configuration lives in nvim/init.lua; see the README's nvim section for the
--  full keymap list.
-- ----------------------------------------------------------------------------

return { greet = greet, first = first, second = second, oops = oops }
