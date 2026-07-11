-- ============================================================================
--  tutorial.lua — a guided tour of the new LSP + autocompletion setup
-- ============================================================================
--
--  Open this file in nvim:   nvim nvim/tutorial.lua
--
--  Because it's a Lua file, the `lua_ls` language server (auto-installed by
--  mason on first launch) will attach automatically. Give it a second — you'll
--  see "lua_ls" show up in `:LspInfo`. Then walk through the sections below.
--
--  If nothing works yet, run `:Mason` and confirm `lua-language-server` is
--  installed, then `:LspInfo` to confirm it attached to this buffer.
-- ============================================================================


-- ----------------------------------------------------------------------------
--  1. AUTOCOMPLETION  (nvim-cmp)
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
--  2. HOVER + GO-TO-DEFINITION + REFERENCES  (LSP)
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
--  3. DIAGNOSTICS  (LSP)
-- ----------------------------------------------------------------------------
--  lua_ls flags problems inline. The two locals below are intentional:
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
--  4. SNIPPETS  (LuaSnip, surfaced through cmp)
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
