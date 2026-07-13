// ============================================================================
//  tutorial.rs — becoming a neovim power user, drilled on real Rust
// ============================================================================
//
//  Open it:   nvim nvim/tutorial.rs
//
//  This is a practice range. Every section explains an idea, then gives you
//  TRY IT exercises against the real Rust code sitting right below it. Do them
//  in order — the order IS the roadmap, most leverage first.
//
//  ---------------------------------------------------------------------------
//  THE DAILY LOOP  (10 minutes, every morning)
//  ---------------------------------------------------------------------------
//    1. Open this file.
//    2. Work top to bottom. Do the exercises, don't just read them.
//    3. You WILL wreck the code below. That's the point.
//    4. Reset it with  :e!   (reload from disk, discard everything).
//
//  `:e!` is what makes this repeatable forever. Wreck it, reset it, again
//  tomorrow. Never save this file — if you do, `git checkout nvim/tutorial.rs`
//  brings it back.
//
//  Undo one step with `u`, redo with <C-r>. Undo often; it's free.
//
//
// ============================================================================
//  HOW TO THINK IN VIM
// ============================================================================
//
//  This is the part that matters. The keybindings are trivia; the model below
//  is what makes people fast. Internalise it and the rest is lookup.
//
//  1. VIM IS A LANGUAGE, NOT A SET OF SHORTCUTS.
//     Other editors give you one key per action, so you memorise a phrasebook
//     and you're capped at whatever someone else thought of. Vim gives you a
//     grammar, and you compose sentences with it:
//
//         [count] {operator} {text object or motion}
//            2         d            a w             = "delete 2 words"
//                      c            i (             = "change inside parens"
//                      y            i p             = "yank inside paragraph"
//
//     Operators: d(elete) c(hange) y(ank) > < = gu gU
//     Objects:   iw aw i( a( i" a" i{ a{ ip ap
//     Motions:   w b e f{c} t{c} 0 ^ $ % / ? G { }
//
//     The payoff is MULTIPLICATIVE. Learn one new operator and you instantly
//     get it against every object you already know. Never memorise `ci(` as
//     "the change-arguments command" — read it as a sentence: change, inside,
//     parens. When you want a command that doesn't exist, you're usually one
//     composition away from it.
//
//  2. NORMAL MODE IS HOME. INSERT MODE IS A VISIT.
//     Beginners live in insert mode and pop out to navigate. Invert that. You
//     sit in normal mode — a command console over your text — and drop into
//     insert only to type a burst of characters, then leave (`jk` here). If
//     you're sitting in insert mode with your hands still, you're in the wrong
//     mode.
//
//  3. DON'T MOVE. AIM.
//     Every `hjkl` press is an admission you didn't know where you were going.
//     Before touching a key, NAME the target — "the opening paren", "the word
//     `total`", "seven lines down", "the end of the block" — then pick the ONE
//     motion that lands there: `f(`, `/total`, `7j`, `}`. Holding a key down is
//     always a bug. If a target is far away it has a name, and if it has a name
//     you can search for it.
//
//  4. MAKE EVERY EDIT REPEATABLE, THEN REPEAT IT.
//     `.` replays your last change. It's the highest-leverage key on the
//     keyboard, and it rewards you for structuring edits well:
//
//         BAD:   fix occurrence 1, fix occurrence 2, fix occurrence 3
//         GOOD:  ciwnew<Esc>  then  n.  n.  n.
//
//     After any edit, ask "will I need this again?" If yes, make it a single
//     dot-repeatable unit (one operator + one object), hop to the next site,
//     press `.`. When the edits differ per line, that's a macro (`qq…q`, `@q`).
//     When even a macro is clumsy, it's `:%s///` or `:g//`. Use the smallest
//     tool that fits — but never do the same edit by hand twice.
//
//  5. USE THE LOWEST RUNG THAT REACHES.
//         within a line     ->  f t ; , 0 ^ $ %
//         within a file     ->  / ? n * { } gg G marks
//         within a project  ->  telescope   (<leader>ff, <leader>fg)
//         files you live in ->  harpoon     (<leader>1..4)
//         within the code   ->  LSP         (gd, gr, K, <leader>rn)
//     Opening a fuzzy finder to move three lines is as wrong as pressing `j`
//     forty times to cross a project.
//
//  6. UNDO IS A UNIT OF THOUGHT.
//     One `u` undoes one insert session or one operator. So the way you chunk
//     your edits is the way you can un-chunk them. Small deliberate edits give
//     a clean undo history; a 200-character insert-mode splurge gives one blob.
//     Edit in sentences.
//
//  The mantra, in four words:  AIM, COMPOSE, REPEAT, AUTOMATE.
//
//
// ============================================================================
//  THE ROADMAP  (this file's section order — do not skip ahead)
// ============================================================================
//
//  Tiers 1-4 are where nearly all the speed lives. Most people skip them to go
//  install plugins, then plateau forever as a fast-ish beginner. A plugin gives
//  you a new capability; the GRAMMAR makes everything you already do faster.
//  That's why plugins are last.
//
//    TIER  1  motions ....... aim instead of walking
//    TIER  2  text objects .. THE BIG ONE — operator + object = the grammar
//    TIER  3  repeat ........ `.` and structuring edits so it works
//    TIER  4  counts ........ 7j, d2j, d3w — quantify the sentence
//    TIER  5  insert ........ A I o O cc C — enter insert already in position
//    TIER  6  registers ..... yank vs delete, "0p, <C-r>0, "+y
//    TIER  7  visual ........ v V <C-v> — blockwise editing is a superpower
//    TIER  8  macros ........ qq…q, @q, 3@q — when `.` isn't enough
//    TIER  9  ex ............ :%s///g and :g// — project-scale edits in one line
//    TIER 10  marks ......... ma, `a, ``, <C-o>/<C-i> — leave and come back
//    TIER 11  telescope ..... <leader>ff / fg / fb / fh
//    TIER 12  harpoon ....... <leader>a, <leader>1..4
//    TIER 13  lsp ........... gd gr K <leader>rn <leader>ca ]d [d
//    TIER 14  cmp ........... completion + snippets (least important: typing
//                             was never your bottleneck)
//
// ============================================================================


// ############################################################################
//  TIER 1 — MOTIONS: aim, don't walk
// ############################################################################
//
//    w / W    forward to start of next word   (W ignores punctuation)
//    b / B    back a word          e / ge     end of word forward / back
//    0        column zero          ^          first non-blank
//    $        end of line          %          jump to the matching ) ] }
//    f{c}     jump forward ONTO the next {c}      F{c}  same, backwards
//    t{c}     jump forward UP TO (just before) {c}  T{c}  same, backwards
//    ;        repeat the last f/t/F/T           ,     repeat it in reverse
//    gg / G   top / bottom of file            {  }   paragraph up / down
//    <C-d> / <C-u>   half-page down / up  (keeps your bearings; beats <C-f>)
//    H  M  L  top / middle / bottom of the VISIBLE screen
//    zz       recentre the screen on the cursor (reframe without moving)
//    /text    search forward    ?text  back    n / N  next / previous match
//    *        search for the WORD under the cursor — no typing at all
//
//  `f` and `/` are the two you should reach for by reflex. `f` for anything you
//  can see on the line; `/` for anything you can name in the file.
//
//  TRY IT ▸ on the `parse_config` line below:
//    a) put the cursor at column 0 with `0`, then `f(` to land ON the paren
//    b) press `%` — you bounce to its matching `)`
//    c) press `0`, then `t:` to stop just BEFORE the first colon, `;` for the next
//    d) press `$` to shoot to the end, `^` to come back to the first word
//
//  TRY IT ▸ put the cursor on `retries` in the struct below and press `*`.
//    You jump to its next use. Keep pressing `n` to cycle through every one.
//    This is how you chase a symbol without typing its name.

pub struct Config {
    pub host: String,
    pub port: u16,
    pub retries: u32,
    pub verbose: bool,
}

fn parse_config(raw: &str, strict: bool, retries: u32) -> Result<Config, ParseError> {
    let host = extract(raw, "host")?;
    let port = extract(raw, "port")?.parse::<u16>()?;
    Ok(Config { host, port, retries, verbose: !strict })
}


// ############################################################################
//  TIER 2 — TEXT OBJECTS: the grammar. This is the big one.
// ############################################################################
//
//  An operator needs a target. A text object is a target that understands
//  STRUCTURE — a word, a string, the inside of a paren, a whole block.
//
//    iw / aw    inner word / a word (aw takes the trailing space too)
//    i( / a(    inside the parens / including them   (also i) — same thing)
//    i{ / a{    inside the braces / including them
//    i" / a"    inside the quotes / including them
//    i[ / a[    inside the brackets
//    ip / ap    inner / a paragraph (blank-line delimited)
//
//  Compose them with d, c, y:
//    ciw   change the word you're standing anywhere in  <- the workhorse
//    ci(   change an argument list without touching the brackets
//    ci"   change a string's contents
//    da(   delete the parens AND everything in them
//    yi{   yank a whole block body
//    dt,   delete up to the next comma (operator + motion, same idea)
//
//  The i/a distinction: `i`nner is the thing itself, `a`round includes its
//  delimiters or trailing space. `diw` on a word leaves two spaces; `daw`
//  leaves one. That's the whole difference, and it matters.
//
//  TRY IT ▸ on `fn connect` below:
//    a) cursor ANYWHERE inside the word `timeout_ms` -> `ciw` -> type `deadline_ms`
//       -> `jk`. Note you did NOT have to aim at the start of the word.
//    b) cursor anywhere between the parens of `connect(...)` -> `ci(` ->
//       type `addr: &str` -> `jk`. The whole signature's args, replaced.
//    c) cursor on the `"tcp"` string -> `ci"` -> type `udp` -> `jk`.
//    d) cursor on the word `stale` -> `daw` -> it and its space vanish.
//    e) cursor inside the `{ }` body of connect -> `di{` -> the body empties.
//       Then `u` to bring it back.
//
//  WALKTHROUGH for (a), keystroke by keystroke:
//        ciw           c=change  i=inner  w=word   -> word is gone, you're in insert
//        deadline_ms   type the replacement
//        jk            back to normal mode
//    Six keys of intent, not twelve of arrow-keying.

fn connect(host: &str, timeout_ms: u64, protocol: &str) -> Result<Socket, IoError> {
    let proto = "tcp";
    let stale = compute_backoff(timeout_ms);
    let sock = Socket::open(host, proto, timeout_ms)?;
    Ok(sock)
}


// ############################################################################
//  TIER 3 — REPEAT: `.` is the best key on the keyboard
// ############################################################################
//
//  `.` replays your last CHANGE (not motion). The skill isn't pressing `.` —
//  it's structuring the edit so that `.` can replay it. One operator, one
//  object, done. Then hop and press `.`.
//
//  Pair it with `n` (next search match) and you have a manual, reviewable
//  find-and-replace where you approve every site:
//
//        /old<CR>      find the first one
//        ciwnew<Esc>   fix it — this is now the "last change"
//        n.            next match, replay.   n.   n.   n.
//
//  Why not just `:%s/old/new/g`? Because `n.` lets you SKIP the ones that
//  shouldn't change. Press `n` alone to skip, `n.` to fix. That's the move.
//
//  TRY IT ▸ below, rename every `buf` to `chunk` — but ONLY the standalone
//  ones, skipping `buffer_size` (that's the whole point):
//        /\<buf\><CR>    search for `buf` as a whole word
//        ciwchunk<Esc>   change the first
//        n.  n.          next, repeat — three times total
//    (`\<` and `\>` are word boundaries. Without them you'd hit buffer_size.)
//
//  TRY IT ▸ delete three whole lines with `dd` then `..` — `.` repeats
//  operators, not just insertions.

fn drain(buf: &mut Vec<u8>, buffer_size: usize) -> usize {
    let n = buf.len().min(buffer_size);
    buf.truncate(n);
    n
}


// ############################################################################
//  TIER 4 — COUNTS: say how many
// ############################################################################
//
//  A count multiplies the sentence.  [count]{operator}{motion}
//
//    7j     down seven lines            d3w    delete three words
//    d2j    delete this line + 2 more   3dd    same idea, three lines
//    2ci(   ...counts compose with everything
//
//  init.lua turns on HYBRID line numbers (`number` + `relativenumber`): the
//  cursor line shows its absolute number, every other line shows its DISTANCE.
//  So you never count rows by eye — you READ the number in the gutter and type
//  it. That gutter exists to make counted jumps aimable. Use it.
//
//  TRY IT ▸ put the cursor on the `fn retry` line below. Look at the gutter,
//  find the line with `panic!` in it, read off how far it is (say it's 5), and
//  press `5j`. One move. No counting rows with your finger.
//
//  TRY IT ▸ cursor on the first `let a` line, then `d2j` — deletes that line
//  and the two below it (three lines total). `u` to undo.

fn retry(attempts: u32) -> Result<(), RetryError> {
    let a = 1;
    let b = 2;
    let c = 3;
    if attempts == 0 {
        panic!("attempts must be non-zero");
    }
    Ok(())
}


// ############################################################################
//  TIER 5 — INSERT MODE: arrive already in position
// ############################################################################
//
//    i / a    insert before / after the cursor
//    I / A    insert at first non-blank / at END of line   <- use these
//    o / O    open a new line below / above, and insert
//    cc / S   change the whole line (keeps indent)
//    C        change from cursor to end of line
//    s        delete the char and insert
//
//  NEVER press `$` then `a`. That's `A`. Never press `0` then `i`. That's `I`.
//  Two keys where one will do, every single time you do it.
//
//  While IN insert mode, these save you from bailing out to normal:
//    <C-w>    delete the word behind you
//    <C-u>    delete to the start of the line
//    <C-r>0   paste the last yank (see Tier 6)
//
//  TRY IT ▸ on `let total = a + b` below:
//    a) cursor anywhere on it -> `A` -> type `;` -> `jk`. Semicolon appended,
//       and you never navigated to the end.
//    b) cursor on it -> `o` -> type `let scaled = total * 2;` -> `jk`. New line
//       below, correctly indented, already in insert.
//    c) cursor on it -> `cc` -> the line's contents vanish, indent kept, you're
//       in insert. Type something else. `u` to undo.

fn totals(a: i64, b: i64) -> i64 {
    let total = a + b
    total
}


// ############################################################################
//  TIER 6 — REGISTERS: yank and delete do NOT share a bin
// ############################################################################
//
//  Every delete AND yank goes to the unnamed register `"`. That's why this
//  classic move betrays you:
//
//        yiw          yank a word
//        (move)       ...
//        viwp         paste over another word — WORKS, but now the register
//                     holds the word you just overwrote, so the next `viwp`
//                     pastes the wrong thing.
//
//  The fix: register `0` always holds your last YANK, and deletes never touch
//  it. So:
//        yiw          yank
//        (move)       ...
//        viw"0p       paste from register 0 — repeatable forever
//        ciw<C-r>0    or: change the word and paste reg 0 while in insert
//
//    "+y / "+p    the SYSTEM clipboard (talks to Windows through WSL)
//    p / P        paste after / before the cursor
//    ddp          swap two lines (delete, then put it back below) — three keys
//    :reg         look inside every register
//
//  TRY IT ▸ below, copy `MAX_RETRIES` onto the `let limit = TODO;` line:
//        cursor on MAX_RETRIES -> `yiw`
//        move to TODO          -> `ciw<C-r>0jk`
//    You just pasted a yank from inside insert mode. That's the move to keep.
//
//  TRY IT ▸ cursor on `let x = 1;` -> `ddp` -> it swaps with the line below.

const MAX_RETRIES: u32 = 5;

fn limits() {
    let x = 1;
    let y = 2;
    let limit = TODO;
}


// ############################################################################
//  TIER 7 — VISUAL MODE: select, then operate
// ############################################################################
//
//    v        charwise visual      V    LINEwise visual
//    <C-v>    BLOCKWISE visual — a rectangle. This is the superpower.
//    gv       reselect whatever you had selected last
//    o        jump to the other end of the selection (extend the other way)
//
//  In blockwise mode:
//    I        insert at the left edge of the block, ON EVERY LINE
//    A        append at the right edge, on every line
//    d        delete the rectangle (kill a column)
//
//  Visual mode is also the escape hatch: when the text object you want doesn't
//  exist, just select it by hand and operate on the selection.
//
//  TRY IT ▸ comment out all four `step_*` lines below in one motion:
//        cursor at column 0 of the first `step_one` line
//        <C-v>     enter blockwise
//        3j        extend down over all four lines
//        I         insert at the left edge
//        //        type the comment marker
//        jk        -> all four lines are commented. Four lines, nine keys.
//    Then `u` to undo, and try `<C-v>3j$A  // done<Esc>` to append instead.
//
//  TRY IT ▸ `V` on a line, then `j` a couple of times, then `>` to indent the
//  selection. Then `gv` to reselect it and `>` again.

fn pipeline() {
    step_one();
    step_two();
    step_three();
    step_four();
}


// ############################################################################
//  TIER 8 — MACROS: when `.` isn't enough
// ############################################################################
//
//    qq       start recording into register q
//    ...      do the work — ONE representative unit of it
//    q        stop recording
//    @q       replay it
//    3@q      replay it three times
//    @@       replay the last macro again
//
//  The discipline that makes macros reliable: make the recorded keys
//  POSITION-INDEPENDENT. Start the recording with `0` or `^` so it doesn't
//  matter where the cursor sits, and END it by moving to the next target
//  (usually `j`). Then it chains cleanly N times.
//
//  TRY IT ▸ turn every `field_*` line below into a struct field — add a
//  trailing comma and capitalise nothing, just append `,`:
//        cursor on the first field line
//        qq        start recording into q
//        A,        append a comma
//        jk        back to normal
//        j         move to the next line  <- this is what makes it chain
//        q         stop recording
//        3@q       do the remaining three lines
//
//  WHY IT WORKS: the macro is "append a comma, go down one". Replayed three
//  times, it walks the rest of the block. If you'd forgotten the `j`, `3@q`
//  would have put three commas on one line. That `j` is the whole trick.
//
//  TRY IT ▸ record a macro that wraps a line in `println!("{}", ...)`. Same
//  shape: `^`, do the edit, `j`, stop. Then `@q` down the file.

struct Record {
    field_alpha: String
    field_beta: u32
    field_gamma: bool
    field_delta: f64
}


// ############################################################################
//  TIER 9 — EX COMMANDS: edit at the scale of the whole file
// ############################################################################
//
//    :%s/old/new/g       replace every `old` with `new`, everywhere
//    :%s/old/new/gc      ...and CONFIRM each one (y/n/a/q)
//    :s/old/new/g        just this line
//    :'<,'>s/old/new/g   just the visual selection (Vim types the '<,'> for you)
//    :g/pattern/d        DELETE every line matching pattern
//    :g/pattern/normal A;    run normal-mode keys on every matching line
//    :v/pattern/d        delete every line NOT matching (v = inVerse)
//
//  `:g` is the most underused power tool in the editor: FILTER, then ACT. It's
//  a macro that finds its own targets.
//
//  Ranges: `%` = whole file, `1,10` = lines 1-10, `.` = current, `$` = last.
//
//  TRY IT ▸ below:
//    a) `:%s/\<tmp\>/scratch/g<CR>` — rename every whole-word `tmp`. (The
//       `\< \>` word boundaries stop it hitting `tmp_dir`.)
//    b) `:g/DEBUG/d<CR>` — every line mentioning DEBUG is gone. One command.
//    c) `u`, then `:g/DEBUG/normal I// <CR>` — instead of deleting them, run
//       the normal-mode keys `I// ` on each. That's :g driving a macro.
//
//  When do you use which? `.` for a few sites you eyeball. A macro when the
//  edit is fiddly but the targets are regular. `:g` when the targets are
//  defined by a PATTERN and there could be hundreds.

fn cleanup(tmp: &str, tmp_dir: &str) {
    let a = load(tmp);
    println!("DEBUG: loaded {}", a);
    let b = load(tmp_dir);
    println!("DEBUG: loaded {}", b);
    commit(tmp, tmp_dir);
}


// ############################################################################
//  TIER 10 — MARKS AND THE JUMP LIST: leave, then come back
// ############################################################################
//
//    m{a-z}   drop a named mark here      `{a-z}   jump back to it
//    ``       jump back to where you were before the last BIG jump (toggle)
//    <C-o>    go BACK through your jump history (older positions)
//    <C-i>    go FORWARD again  (same key as <Tab>)
//    :jumps   see the whole list
//    gi       jump to where you last inserted, and enter insert mode
//    `.       jump to the last change you made
//
//  `<C-o>` is the one to burn in. Every time you `gd` into a definition,
//  telescope into a file, or `/` across the file — `<C-o>` walks you back out.
//  It's the browser back button, and it works across files.
//
//  TRY IT ▸ press `ma` on this line to drop mark `a`. Now `G` to the bottom of
//  the file, poke around, then press `` `a `` — you're back on this exact line.
//
//  TRY IT ▸ press `gg` (top), then `G` (bottom), then `<C-o>` `<C-o>` to walk
//  back through the jumps you just made. Then `<C-i>` to walk forward again.
//
//  TRY IT ▸ edit something anywhere, move far away, then press `` `. `` to fly
//  back to the edit — or `gi` to land there already in insert mode.


// ############################################################################
//  TIER 11 — TELESCOPE: reach across the project
// ############################################################################
//
//    <leader>ff   find files by NAME     (backed by fd — respects .gitignore)
//    <leader>fg   live grep the CONTENT  (backed by ripgrep — why it's instant)
//    <leader>fb   switch between open buffers
//    <leader>fh   search neovim's :help
//
//  Leader is <Space>, so <leader>ff is literally: space, f, f.
//
//  Inside a picker:  type to fuzzy-filter · <C-n>/<C-p> move · <CR> open
//                    <C-x> open in a split · <C-v> vertical split
//                    <C-q> send ALL results to the quickfix list  <- see below
//
//  THE QUICKFIX LIST is the payoff. `<C-q>` dumps every grep hit into a list,
//  then:
//    :cnext / :cprev    walk the hits one by one
//    :copen             see them all
//    :cdo s/old/new/g | update      RUN A SUBSTITUTION ON EVERY HIT, project-wide
//
//  That last line is a project-wide refactor in one command: grep for it, send
//  it to quickfix, `:cdo` the edit. This is the ceiling of the whole file.
//
//  TRY IT ▸ `<leader>ff`, type "init", open init.lua. Then `<C-o>` to come back.
//  TRY IT ▸ `<leader>fg`, search "harpoon", press `<C-q>`, then `:copen`.


// ############################################################################
//  TIER 12 — HARPOON: the 2-4 files you actually live in
// ############################################################################
//
//    <leader>a    pin the current file to the list
//    <leader>h    toggle the quick menu (reorder / delete entries in it)
//    <leader>1    jump to pinned file 1      <leader>3   file 3
//    <leader>2    jump to pinned file 2      <leader>4   file 4
//
//  Telescope is for SEARCHING — you don't know exactly where the thing is.
//  Harpoon is for RETURNING — you know exactly which file, and you're going to
//  go there forty times today. Fuzzy-typing a name you already know is waste.
//
//  The workflow: at the start of a task, pin the 2-4 files it touches. Then
//  <leader>1 / <leader>2 for the rest of the session, with zero thought.
//
//  TRY IT ▸ `<leader>a` here. Open init.lua, `<leader>a` there too. Now bounce:
//  `<leader>1`, `<leader>2`, `<leader>1`. Press `<leader>h` to see the list.


// ############################################################################
//  TIER 13 — LSP: navigate by MEANING, not by text
// ############################################################################
//
//    gd           go to definition       (opens a telescope picker)
//    gr           find every reference   (opens a telescope picker)
//    K            hover docs — types and signature, without leaving your spot
//    <leader>rn   RENAME the symbol everywhere — semantically, across files
//    <leader>ca   code actions (quick fixes: import it, fill the match arms…)
//    ]d  [d       jump to the next / previous diagnostic
//
//  `/` finds TEXT that looks like the symbol. `gr` finds the symbol — it knows
//  the difference between your `retries` field and someone else's local named
//  `retries`. That's the whole point. And `<leader>rn` beats `:%s///` for the
//  same reason: it won't rename the ones that merely spell the same.
//
//  Pair every `gd` with a `<C-o>` to come back. That loop — dive in, read, pop
//  out — is most of what reading code IS.
//
//  ⚠  SETUP: init.lua auto-installs `lua_ls` only, so these work in .lua files
//  out of the box. For THIS Rust file you need rust-analyzer: run `:Mason`,
//  find `rust-analyzer`, press `i` to install. (Add 'rust_analyzer' to
//  `ensure_installed` in init.lua to make it permanent.) rust-analyzer wants a
//  real cargo project to do its best work — a lone .rs file gets limited
//  results.
//
//  TRY IT (once rust-analyzer is in) ▸ cursor on `extract` in parse_config near
//  the top: `K` for its signature, `gd` to its definition, `gr` for every use,
//  `<C-o>` to come home. Try `<leader>rn` to rename it.
//
//  TRY IT ▸ this file has deliberate errors (the missing semicolon in `totals`,
//  the missing commas in `struct Record`). Press `]d` to jump between them and
//  `<leader>ca` to see what fixes it offers.


// ############################################################################
//  TIER 14 — COMPLETION: last, on purpose
// ############################################################################
//
//    <C-Space>         force the completion menu open
//    <Tab> / <S-Tab>   next / previous item (and hop between snippet fields)
//    <CR>              confirm the selection
//    <C-f> / <C-b>     scroll the docs popup
//
//  Sources, in priority order: LSP, snippets (LuaSnip), words already in this
//  buffer, filesystem paths.
//
//  It's last in the roadmap because it saves TYPING, and typing was never your
//  bottleneck — navigating and restructuring were. A fast typist with no
//  grammar is still slow.
//
//  TRY IT ▸ on a blank line, enter insert and type `Config::` and wait. Or type
//  `std::` and <C-Space>. <Tab> to cycle, <CR> to take it.


// ############################################################################
//  THE REST OF THE DOTFILES (what each tool has to do with nvim)
// ############################################################################
//
//    ripgrep   backs <leader>fg. Why grepping the whole project is instant.
//    fd        backs <leader>ff. Respects .gitignore, so no target/ noise.
//    fzf       the fuzzy engine you already have in zsh; telescope is the same
//              idea inside nvim.
//    zoxide    `z myproj` to the directory, then `nvim .` — the step BEFORE
//              telescope takes over.
//    tmux      nvim lives in a tmux pane. Prefix is C-Space; `prefix |` and
//              `prefix -` split; h/j/k/l moves between panes. Editor one side,
//              `cargo watch -x test` the other.
//    zsh       vi mode is ON at the shell (`bindkey -v`), and `jk` escapes to
//              normal mode ON THE COMMAND LINE too. Every Tier 1 motion works
//              at your prompt. Same muscle memory, two places — this doubles
//              the value of everything above.
//    git       EDITOR=nvim, so commit messages open here.
//    lazy      `:Lazy` manages plugins; lazy-lock.json pins them.
//    mason     `:Mason` installs language servers (this is where rust-analyzer
//              comes from).
//
//
// ############################################################################
//  CHEAT SHEET — the 15 that carry you
// ############################################################################
//
//    ciw  ci(  ci"      change inner word / parens / string   <- live here
//    daw  di{           delete a word (+space) / a block body
//    .                  repeat the last change
//    n.                 next match, repeat the change — reviewable refactor
//    f{c}  ;            jump onto a char, repeat
//    /text   *          search / search the word under the cursor
//    7j  d2j            counted jump / counted delete (READ the gutter)
//    A  I  o  cc        insert already in position
//    ddp                swap two lines
//    <C-v>  I           blockwise select, insert on every line
//    qq…q  @q  3@q      record, replay, replay N times
//    :%s/old/new/gc     substitute with confirmation
//    :g/pat/normal ...  run keys on every matching line
//    <C-o>  <C-i>       back / forward through your jumps
//    gd  gr  K          definition / references / docs (LSP)
//
//  Practice loop: pick a target, ask "what's the ONE command that gets me
//  there?", use it. When you catch yourself holding a key down — stop, and look
//  the motion up. That pause is the whole game.
//
//  Reset this file when you're done wrecking it:   :e!
// ############################################################################


// ----------------------------------------------------------------------------
//  Scratch space — stubs so the exercises above have something to point at.
// ----------------------------------------------------------------------------

fn extract(_raw: &str, _key: &str) -> Result<String, ParseError> { todo!() }
fn compute_backoff(_ms: u64) -> u64 { todo!() }
fn load(_path: &str) -> String { todo!() }
fn commit(_a: &str, _b: &str) {}
fn step_one() {}
fn step_two() {}
fn step_three() {}
fn step_four() {}

struct Socket;
impl Socket {
    fn open(_host: &str, _proto: &str, _timeout: u64) -> Result<Socket, IoError> { todo!() }
}
struct ParseError;
struct IoError;
struct RetryError;
