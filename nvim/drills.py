# ============================================================================
#  drills.py — a vim speed course. Practice, not explanation.
# ============================================================================
#
#   Open:    nvim nvim/drills.py
#   Reset:   :e!          (wreck the file freely; this puts it back)
#
#  tutorial.rs explains the ideas and motions.lua is the reference. This file is
#  neither: it is a set of DRILLS with pass marks. Ten minutes a day, one
#  session, repeated until the pass mark is comfortable rather than possible.
#
#  THE THREE RULES, which matter more than any key below:
#    1. Never press hjkl more than twice in a row. If you are holding one,
#       stop -- there was a one-press answer. Find it.
#    2. Before moving, ask "how far is the target?" The distance picks the tool.
#       On the line -> f/t. On screen -> s (flash). In the file -> / or a count.
#       Elsewhere -> telescope, harpoon, gd.
#    3. Count keystrokes. Speed is not typing faster; it is pressing fewer keys.
#
#  Leader is <Space>. Blockwise visual is <C-q>, NOT <C-v> -- WezTerm takes
#  <C-v> for paste (see wezterm/.wezterm.lua).
# ============================================================================


# ----------------------------------------------------------------------------
#  SESSION 1 — the line is a ruler, not a road
# ----------------------------------------------------------------------------
#  Keys: f{c} t{c} ; , F T | 0 ^ $ | %
#  Pass mark: land on any character in the line below in <= 2 keypresses.
#
#  DRILL A. Cursor to column 0 of the target line. Now, one key each:
#    1. onto the first (          ->  f(
#    2. onto the matching )       ->  %
#    3. onto the last comma       ->  $ then F,
#    4. just before the =         ->  0 then t=   (t stops BEFORE, f lands ON)
#    5. third comma from the left ->  0 then 3f,
#
#  Pick the target character for RARITY, not for what it belongs to. `t=` works
#  in one press because = appears once; `tc` would stop at the c in "slice",
#  since c occurs four times before "cutoff" does. When the character is common,
#  either repeat with ; (which skips to the next occurrence -- nvim leaves the
#  `;` flag out of cpoptions, so it does not stall) or use a different key: /cu
#  names the target instead of counting hops to it.
#
#  f/t matter most as OPERATOR targets: dt, deletes up to the comma, df, takes
#  the comma with it. ct) retypes the rest of a call's arguments.
#
#  DRILL B. Overshoot on purpose with f, then recover with , (comma).
#  DRILL C. Ten times: 0 -> f= -> $ -> ^ . Aim for under four seconds.

def build_slice(specifications, cutoff, lambda_reg, bootstraps, threads=1):
    return dict(specs=specifications, cutoff=cutoff, lam=lambda_reg, n=bootstraps)


# ----------------------------------------------------------------------------
#  SESSION 2 — text objects: stop navigating, start naming
# ----------------------------------------------------------------------------
#  Keys: ciw caw ci( ci" ci[ ci{ cit | diw da( yi( | vi( va(
#  Pass mark: change any argument, string or bracketed group from ANYWHERE
#  inside it, without first moving to its edge.
#
#  This is the highest-value session in the file. A text object is
#  position-independent: the cursor merely has to be INSIDE the thing.
#
#  DRILL A. On the dict below, cursor anywhere inside the braces: ci{ and type
#           a new body. :e! and repeat until it is reflex.
#  DRILL B. Cursor anywhere in "snapshot": ci" -> deploy. Then caw on delta.
#  DRILL C. Cursor anywhere inside the ( ) of the call: ci( and retype the args.
#  DRILL D. i vs a: di( leaves the parens, da( takes them too. Do both.

CONFIG = {"mode": "snapshot", "delta": -7.5, "confidence": 0.7, "gate": True}

def validate(config, **kwargs):   # defined so basedpyright stays quiet
    return config, kwargs

RESULT = validate(CONFIG, cutoff="2026-05-06", n_days_train=826, bootstraps=100)


# ----------------------------------------------------------------------------
#  SESSION 3 — the dot is a force multiplier
# ----------------------------------------------------------------------------
#  Keys: .  |  n.  |  u  |  <C-r>
#  Pass mark: rename every occurrence below with n. and never type the word
#  twice.
#
#  `.` repeats the last CHANGE, not the last motion. Which means the way to
#  make an edit repeatable is to make it a single change: prefer ciw over
#  "move, delete, insert".
#
#  DRILL A. THE SPECIALIST. Cursor on the first `lambda_reg`. Press * (search
#           this word), then cgn and type `l2_penalty`, <Esc>. Now press . four
#           times. cgn = "change the next match", so `.` finds the next one
#           itself: one keypress per rename. Fewest keys when you want them all.
#  DRILL B. THE GENERAL CASE, and the more important habit. * then ciw, retype,
#           <Esc>, then n. n. n. Two keys per site instead of one -- but `n` and
#           `.` are separate, so `n n .` SKIPS an occurrence you don't want to
#           touch. And `.` is not tied to a search at all: it repeats any change
#           anywhere, which is the reflex that pays off everywhere else.
#           Not a legacy alternative to A. A is the special case of this.
#  DRILL C. Do B again, deliberately skipping the occurrence inside `scaled`.
#           A cannot express that; this is the whole reason to know both.
#  DRILL D. Undo it all with u, then redo with <C-r>, and notice `.` survives.

def fit(lambda_reg):
    penalty = lambda_reg * 2
    scaled = lambda_reg / penalty
    return lambda_reg + scaled + lambda_reg


# ----------------------------------------------------------------------------
#  SESSION 4 — counts, read from the gutter
# ----------------------------------------------------------------------------
#  Keys: {count}j {count}k | {count}G | { } | H M L | zz zt zb | <C-d> <C-u>
#  Pass mark: reach any visible line in one jump, without counting rows by eye.
#
#  relativenumber is on: every line shows its DISTANCE. Read the number, type
#  it. If you ever count rows with your finger, you have already lost.
#  M-u / M-d are half-page too, and are the same keys tmux and claude use.
#
#  DRILL A. From this line, jump to the def below by reading its gutter number.
#  DRILL B. } } } to walk the blank-line paragraphs, then { { { back.
#  DRILL C. H M L (screen top/middle/bottom), then zz to recentre. Ten times.
#  DRILL D. :42 and {count}G to the same line. Both, so both are available.

def sweep(deltas):
    out = []
    for d in deltas:
        out.append(d)
    for d in deltas:
        out.append(-d)
    return out


# ----------------------------------------------------------------------------
#  SESSION 5 — search is a motion
# ----------------------------------------------------------------------------
#  Keys: / ? n N | * # | d/pattern<CR> | :%s/old/new/gc
#  Pass mark: delete from the cursor to an arbitrary point 30 lines away in
#  one command.
#
#  / is not just navigation -- it is an operator target. d/foo<CR> deletes
#  everything up to the next "foo". That composability is why search beats a
#  labelled jump when the edit spans distance.
#
#  DRILL A. From the top of this session, d/return<CR> -- gone in one command.
#           :e! and do it with y and c too.
#  DRILL B. * on `threshold` below, then n N to walk the matches both ways.
#  DRILL C. :%s/threshold/cutoff/gc -- confirm each. Then u.
#  DRILL D. Compare: rename with :%s vs with cgn + . -- learn which you prefer.

def gate(threshold, values):
    kept = [v for v in values if v > threshold]
    dropped = [v for v in values if v <= threshold]
    return kept, dropped, threshold


# ----------------------------------------------------------------------------
#  SESSION 6 — visual, and the rectangle
# ----------------------------------------------------------------------------
#  Keys: v V <C-q> | gv | o | I A (in blockwise) | g<C-a>
#  Pass mark: comment out a ragged block, and renumber a column, without
#  touching a line twice.
#
#  <C-q> is blockwise here, not <C-v>. vim aliases them, and WezTerm has taken
#  <C-v> for paste.
#
#  DRILL A. <C-q> down four lines, then I and `# ` and <Esc> -- all commented.
#  DRILL B. <C-q> down four, then $ then A and `  # noqa` -- appended to each.
#  DRILL C. Select the 0s below blockwise and press g<C-a> -- an incrementing
#           sequence. This is worth knowing; almost nobody does.
#  DRILL D. gv to reselect what you just had. o to swap which end you extend.

SLICE_0 = 0
SLICE_1 = 0
SLICE_2 = 0
SLICE_3 = 0
SLICE_4 = 0


# ----------------------------------------------------------------------------
#  SESSION 7 — macros: the loop you record
# ----------------------------------------------------------------------------
#  Keys: qa ... q | @a | @@ | {count}@a | "ap
#  Pass mark: turn the raw rows below into dict literals with one recorded
#  macro and a count.
#
#  A macro is a repeat for edits `.` cannot express. The rule that makes them
#  reliable: start from a deterministic position (0 or ^), end by moving to the
#  next target (j0), and use motions that cannot overshoot.
#
#  DRILL A. On the first raw line: qa  0  i{"name": "  <Esc>  A"}  <Esc>  j0  q
#           Then 3@a for the rest. :e! and do it again until it is boring.
#  DRILL B. Record a macro that fails halfway. Notice it stops. That is the
#           point -- macros abort on error rather than corrupting the rest.
#  DRILL C. "ap to paste the macro text itself and read what you recorded.

# raw rows
# sig_speed_rating
# sig_days_since_run
# sig_going_delta
# sig_trainer_form


# ----------------------------------------------------------------------------
#  SESSION 8 — marks and the jump list: leave, then come back
# ----------------------------------------------------------------------------
#  Keys: ma `a 'a | `` | <C-o> <C-i> | g; g, | '"
#  Pass mark: read a definition 200 lines away and be back, cursor exact, in
#  two keys.
#
#  DRILL A. ma here. Wander (G, gg, /something). Then `a to come back exactly.
#  DRILL B. Jump somewhere with G, then `` to bounce back. Then `` again.
#  DRILL C. <C-o> repeatedly to walk BACK through your jumps, <C-i> forward.
#  DRILL D. g; walks the CHANGE list -- where you last edited, not where you
#           last looked. Different list, often the one you actually wanted.


# ----------------------------------------------------------------------------
#  SESSION 9 — the project layer
# ----------------------------------------------------------------------------
#  Keys: s{c}{c} (flash) | <leader>ff <leader>fg <leader>fb | <leader>1..4
#        gd gr K | ]d [d | <leader>e
#  Pass mark: open any file in the project, and any symbol in it, without
#  thinking about where it lives.
#
#  Most real movement is between files and symbols, not within a screen. This
#  session is where the working day actually gets faster.
#
#  DRILL A. s + two characters to a target you can SEE. Then ds + two chars --
#           flash is an operator target, not just a motion.
#  DRILL B. <leader>ff and open a file by name. <leader>fg and find it by
#           CONTENT instead. Learn which question you are asking.
#  DRILL C. Pin this file with <leader>a, jump away, <leader>1 to return.
#  DRILL D. gd on a symbol, read, <C-o> back. Then gr for every use.


# ----------------------------------------------------------------------------
#  GRADUATION — the test
# ----------------------------------------------------------------------------
#  You are done when all of these are true without deliberation:
#
#    [ ] You never hold hjkl. Ever.
#    [ ] You reach for ciw / ci( before you reach for a motion.
#    [ ] You rename with cgn and then `.`, not by retyping.
#    [ ] You read the gutter number instead of counting rows.
#    [ ] You use d/pattern<CR> when the edit spans distance.
#    [ ] You record a macro without thinking about how to start it.
#    [ ] `` and <C-o> are reflexes, not things you remember exist.
#    [ ] You notice yourself repeating an edit and stop to make it repeatable.
#
#  THE DAILY LOOP, ten minutes:
#    1. :e! this file.
#    2. One session, in order. Repeat the drills until they are dull.
#    3. Then work normally -- and each time you catch yourself mashing a key,
#       stop and ask what the one-press answer was. That noticing is the
#       whole skill; the drills only make the answer available.
# ============================================================================
