# Brevity

Be as concise as possible. Skip all pleasantries, introductory remarks, and
concluding fluff. Provide direct answers only, maximizing signal to noise.

Concretely: no "Great question", no "I'll now …" before doing it, no "Let me know if
you'd like …" after. Don't restate my question, don't summarise what you just said,
don't list what you considered and rejected unless the rejection is the answer. One
sentence of framing at most, then the substance.

This trades against nothing above — being brief never licenses dropping a symbol
definition (§ Define every symbol) or a caveat that would change my decision.

# Math notation

Which notation to use depends entirely on **where the maths ends up**. Decide that
first, every time:

| Destination | Notation |
|---|---|
| Your reply in the terminal | **Unicode** (§ Unicode) |
| A file on disk: `.md`, `.tex`, `.ipynb`, `.rst`, `.qmd` | **LaTeX** (§ LaTeX in files) |
| Code comments, docstrings, commit messages, PR bodies | **Unicode** |
| I explicitly ask for "the latex" | **LaTeX**, raw, in a fenced block |

The two are not interchangeable and never appear together — pick one per
destination. A single task often needs both: if you explain a derivation to me and
then write it into `notes.md`, the reply is Unicode and the file is LaTeX, carrying
the same content.

# Define every symbol

Holds everywhere maths appears — replies, files, code comments, commit messages —
whichever notation the destination takes. **Never leave me to infer what a symbol
means.**

- Gloss every symbol **at first use**, in half a line, inline with the maths. Once
  each — don't re-define it later in the same reply.
- **Before sending, read back every equation and account for every symbol in it,
  one by one.** Not "did I write some definitions" — did I define *each* of them.
  A partially-glossed equation is worse than an unglossed one: defining three of
  four symbols signals the fourth was too obvious to mention, so I won't ask.
- **The left-hand side counts.** The quantity being defined or solved for is the
  one most often skipped and usually the one I most need — I can often infer an
  input from context, never the output. "fᵢ = qᵢ − R(S)/Bᵢ, where qᵢ is … and Bᵢ
  is …" is a failure if it never says what fᵢ is.
- **"Once each" is per reply, not per conversation.** Every reply stands on its own:
  if an equation carries a symbol I was told about ten messages ago, gloss it again.
  Never assume a definition from earlier in the conversation is still loaded.
- **Never rebind a symbol.** One meaning per symbol for the whole conversation, not
  just the current reply. If π is implied probability in one message it cannot be
  expected profit in the next — pick a different letter, or write the word out. A
  silent rebind is worse than a missing gloss, because I have no reason to ask.
- Where a quantity has a plain-English name that fits, prefer it to a Greek letter.
  "EV per £1 staked" beats introducing another symbol I have to carry.
- The gloss says what the quantity *is*, with units or index set where those aren't
  obvious: "λ (ridge penalty, per-feature)", "n_k (races in partition k)",
  "θ̂ᵢ (fitted coefficient for signal i)".
- This includes symbols that look standard. σ, β, ρ, ε, α mean different things in
  different contexts — say which one you mean.
- Several new symbols in one equation: define them in a run-on clause after it, not
  as a bulleted glossary.
- Indices are symbols too: say what i ranges over.
- If a symbol maps to something in the codebase, name it: "θ (the `thetas` vector in
  `partitions.json`)".

Bad:  the estimator is θ̂ = (XᵀX + λI)⁻¹Xᵀy

Good: the estimator is θ̂ = (XᵀX + λI)⁻¹Xᵀy, where X is the n×p design matrix
      (n races, p signals), y the outcome vector, and λ the ridge penalty.

# Unicode

I read Claude Code's output in a terminal, so raw LaTeX (`\frac{\partial L}{\partial w}`)
is unreadable noise there. In replies, write mathematics with the actual glyphs.

## Inline math

Use the actual glyphs:

- Greek: α β γ δ ε ζ η θ ι κ λ μ ν ξ π ρ σ τ φ χ ψ ω  Γ Δ Θ Λ Ξ Π Σ Φ Ψ Ω
- Operators: ∫ ∮ ∬ ∑ ∏ √ ∛ ∂ ∇ ∞ ± ∓ × · ÷ ∘ ⊗ ⊕
- Relations: ≈ ≃ ≅ ≠ ≤ ≥ ≪ ≫ ≡ ∝ ~ → ⇒ ⇔ ↦ ⟶
- Sets/logic: ∈ ∉ ⊂ ⊆ ⊃ ⊇ ∪ ∩ ∖ ∅ ∀ ∃ ∄ ∧ ∨ ¬ ⊥ ∴ ∵
- Number sets: ℝ ℂ ℕ ℤ ℚ 𝔼 ℙ 𝟙
- Brackets: ⟨x, y⟩ ‖x‖ |x| ⌊x⌋ ⌈x⌉
- Superscripts: ⁰¹²³⁴⁵⁶⁷⁸⁹ ⁺⁻⁼⁽⁾ ⁿ ⁱ ᵀ ᵏ ᵃ ᵇ ᶜ ᵈ ᵉ ᵐ ᵖ ˣ ʸ ʲ
- Subscripts: ₀₁₂₃₄₅₆₇₈₉ ₊₋₌₍₎ ₐ ₑ ₕ ᵢ ⱼ ₖ ₗ ₘ ₙ ₒ ₚ ᵣ ₛ ₜ ᵤ ᵥ ₓ
- Accents (combining, type the base char then the mark): x̂ x̄ x̃ ẋ ẍ x⃗ θ̂ μ̂ ȳ

**Every** index is a glyph, not an underscore. `gᵣ`, `p̂ᵣᵢ`, `xᵣᵢᵀ`, `θ̂ₖ`, `∑ᵢ` —
never `g_r`, `p̂_ri`, `x_ri^T`, `theta_k`. This holds in running prose exactly as
much as in a display block, and it holds for *every* symbol in an equation — one
underscore among glyphs is the same failure as all of them. Before sending, read
each equation back index by index and check.

**The subscript is never optional.** A symbol that carries an index in the maths
keeps it in the prose: write `θ̂ₖ`, `nₖ`, `λₖ`, `σ̂ₖ²` — not a bare `θ̂`, `n`, `λ`,
`σ̂²` with the index left to context. Dropping an index to dodge the glyph is the
same error as writing it with an underscore. If I have to work out which k you
mean, the notation has failed.

> **DON'T FORGET.** This is the rule you break most often, and you break it late in
> a reply, in a throwaway aside, after getting every displayed equation right. An
> underscore-subscript in prose — `theta_k`, `sigma_i`, `w_r`, `n_k`, `p_ri` — is
> ALWAYS wrong, however small the mention. **Before sending any reply containing
> maths, scan the text for `_` and check every hit: it is either inside backticks as
> a code identifier, or it is a bug you must fix.** There is no third case.

Code identifiers are not maths: `Sig_h_win_1r`, `test_delta_prs`, `n_days_train`
keep their underscores and stay in backticks. The rule governs symbols, not names.

The fallback is only for indices with **no** glyph at all. There is no subscript
b, c, d, f, g, q, v, w, y or z, and no superscript for most of the alphabet — so
`n_races`, `x_{i+1}`, `σ²_max` have no full Unicode form. Two ways out, in order
of preference: rewrite the symbol so the index disappears ("races in partition k"
→ `nₖ`; `x_{r,winner}` → "the winner's row"), or fall back to parenthesised plain
text `x_(i+1)` / `σ²_max`. Never braces, and never a bare underscore where a glyph
exists.

Simple fractions go inline with `/` and explicit parens: `(a + b)/(2c)`, not `a+b/2c`.

Exponentials are written `exp(...)`, never `e` raised to a power — `exp(θ xᵣⱼ)`, not
`e^(θ xᵣⱼ)` and not `eᶿ`. Unicode has superscript glyphs for almost nothing that shows
up in a real exponent, so `e` to the power of anything non-trivial degrades to an ASCII
caret with parens, which reads worse than the function form. Applies in LaTeX files too:
`\exp(\theta x_{rj})`, not `e^{\theta x_{rj}}`.

## Display math

Anything with a real fraction bar, a matrix, or limits above/below goes in a
**fenced code block with no language tag**, laid out in 2D with box-drawing
characters. The fence guarantees the terminal preserves the alignment.

```
        1   ⁿ
  x̄  =  ─   ∑  xᵢ
        n  ⁱ⁼¹


  ∂L      2   ⁿ
  ──  =  ───  ∑  (ŷᵢ − yᵢ) xᵢⱼ
  ∂wⱼ     n  ⁱ⁼¹


        ⎡ a  b ⎤        1     ⎡  d  −b ⎤
  A  =  ⎢      ⎥   A⁻¹ = ───── ⎢        ⎥
        ⎣ c  d ⎦        ad−bc ⎣ −c   a ⎦
```

Fraction bars are `─` (U+2500) sized to the wider of numerator/denominator, with
both centred over it. Matrix delimiters are `⎡⎢⎣ ⎤⎥⎦`; for a one-row matrix use
`[ ... ]`. Sum/integral limits sit on the lines above and below the operator.

Multi-step derivations align on `=`:

```
  (x + h)² − x²      x² + 2xh + h² − x²
  ─────────────  =  ────────────────────  =  2x + h  ⟶  2x   as h → 0
        h                    h
```

Number displayed equations `(1)`, `(2)`, … at the right only when you refer back
to them later.

## What not to do (in replies)

- No `$`/`$$` delimiters, no `\frac`, `\sum`, `\alpha`, `\mathbb{R}`, `\left(`.
- Don't write out a LaTeX version "as well" — one rendering, the Unicode one.
- Don't answer a maths question by writing a file and telling me to open it. The
  explanation goes in the reply; a file is only for when I asked for a file.

# LaTeX in files

Markdown and friends get read by renderers, not by me in a terminal — so **every
`.md`, `.tex`, `.ipynb`, `.rst` or `.qmd` file you write or edit uses LaTeX**, never
the Unicode forms above. This holds for files you create unprompted (notes, READMEs,
design docs, analysis write-ups) as much as for ones I ask for.

Delimiters — `$…$` inline, `$$…$$` on its own lines for display:

```markdown
The estimator $\hat{\theta}$ is unbiased when $\mathbb{E}[\hat{\theta}] = \theta$.

$$
\frac{\partial L}{\partial w_j} = \frac{2}{n} \sum_{i=1}^{n} (\hat{y}_i - y_i) x_{ij}
$$
```

`$…$`/`$$…$$` is what GitHub, Obsidian, Jupyter, Quarto and Pandoc all understand.
Don't use `\(…\)` or `\[…\]` (GitHub won't render them), and don't wrap display maths
in a ```` ``` ```` fence — that turns it into a code block and it renders as literal
source.

Details that matter:

- Blank line before and after a `$$` block, or Markdown swallows it into the
  preceding paragraph.
- `_` and `*` inside `$…$` are maths, but some renderers still grab them as emphasis —
  keep subscripts braced (`x_{ij}`, not `x_ij`) so it's unambiguous either way.
- Use `\mathbb{R}`, `\mathcal{N}`, `\hat{x}`, `\bar{x}`, `\vec{x}`, `\|x\|`,
  `\langle x, y \rangle`, `\left( … \right)` for auto-sized brackets.
- Multi-line derivations use `\begin{aligned} … \end{aligned}` inside `$$`, aligned
  on `&=`, rows separated by `\\`.
- Matrices: `\begin{pmatrix} a & b \\ c & d \end{pmatrix}`.
- Escape a literal dollar sign as `\$` anywhere in a file that also contains maths.

If a file already uses a different convention (`\(…\)`, MathJax config, a `.tex`
preamble with custom macros), match the file — consistency within it beats this
default.

# How you write code

Applies whenever you write or edit code, under whichever output style is
active. § Brevity governs your replies; this governs the file on disk. Two
subsections below, § Punctuation you wouldn't type and § Printing, are wider than
that and bind your replies as well; each says so where it applies.

## Docstrings

**As terse as possible, and often absent.** A docstring earns its place by
saying something the signature and the name do not. Most don't, and the ones
that don't are worse than nothing — they push the actual code down the screen
and go stale silently.

- **No docstring on a three-line function.** If the body fits on a screen at a
  glance, the name and the code are the documentation. Adding prose to
  `def _flatten(rows): return [x for r in rows for x in r]` explains a thing
  already fully visible.
- **Sacrifice grammar for concision.** These are notes, not sentences. Drop
  articles, drop the subject, drop the verb where the meaning survives. Fragments
  are correct here. A docstring is read at a glance in a hover popup, and every
  word that isn't load-bearing costs a glance.
- **Never restate the signature.** "Takes a list of rows and returns a
  dataframe" is what the annotations already say. Say what the caller cannot
  see: units, the shape of the return, what makes it fail, why it exists.
- One line if one line does it. Reach for a multi-line docstring only when
  there is a genuine argument-by-argument contract that isn't obvious, and then
  keep each line a fragment.

Bad:  """Computes and then returns the Kelly-optimal stake for a given
      win probability and set of decimal odds."""

Good: """Kelly stake as a fraction of bank. p win prob, o decimal odds."""

Bad:  """This is a helper function which is used to normalise the column
      names of the input dataframe so that they are all lowercase."""

Good: """Lowercase the column names. Mutates in place."""

The second pair is the one to internalise: "Mutates in place" is three words and
is the only thing in either version the caller couldn't have worked out.

Maths inside a docstring follows § Math notation — docstrings take Unicode, and
§ Define every symbol applies to them exactly as it applies to a reply. Concision
never licenses an unglossed symbol; `p win prob` is the terse form of a gloss,
not the absence of one.

## What not to add

**Hardcode by default.** A value used once is written where it's used. Don't
hoist it to a module-level constant, don't make it a parameter, don't put it in
a config dict. Extract on the *second* use, when you can see what actually
varies. If a bare number is genuinely cryptic, name it as a local on the line
above — `min_odds = 1.5` keeps the meaning and costs no jump to the top of the
file.

**No parameter I didn't ask for.** No flag, option or keyword argument with a
single call site. A flag with one caller isn't flexibility; it's a branch that
only ever goes one way, and the reader still has to walk both sides. Three
booleans is eight behaviours, of which one exists. Same for a strategy dict, a
registry, or a subclass with one implementation.

Extracting later is a mechanical edit. Extracting early is a guess, and a wrong
guess leaves an abstraction shaped around a use that never arrived.

**Don't extract a helper used once.** A function whose body is shorter than its
signature is a shallow module: it adds a name to learn without hiding any
complexity. Inline it. Extract on the second or third use, when the abstraction
is known rather than predicted.

**Don't guard against states that can't occur.** No try/except around code that
doesn't raise, no None-check on a value the caller just constructed, no
validation of a private function's own arguments. A guard claims the bad state
is reachable; if it isn't, it's a lie that costs the reader time working out
when.

**Crash early instead.** An assertion stating an invariant is worth more than a
try/except that hides its violation. Catch an exception only where you can
actually do something about it.

**Solve the case I have, not the general case.** No format I don't use, no
option I didn't ask for. YAGNI binds you harder than me: you can write the
speculative version faster than I can read it.

## Comments

**Why, never what.** If a comment can be derived by reading the line below it,
delete it. Worth keeping: why this approach over the obvious one, what invariant
holds here, what breaks if this changes.

**Don't comment bad code — rewrite it.** If a block needs a comment to be
followable, first try renaming things so it doesn't.

**Weight by subtlety, not uniformly.** The tricky function gets the comment; the
obvious one gets nothing. Uniform coverage carries no signal — if everything is
annotated, nothing is marked as mattering, and I can't find the part that does.

**Never comment the change you're making.** No "changed to use X", no "added
error handling here". The file says what the code is now; the diff and the
commit message carry the history. Such comments are stale on the next edit.

**No decoration.** A comment is words, not a divider. No `# ------- setup -------`,
no `# =====================`, no boxed banner, no ASCII art, no `#####` rule
between sections. If a file needs painted dividers to be navigable then it needs
splitting into functions or modules, and the divider is hiding that. Blank lines
separate blocks; that is what they are for.

The general form of it: **if a person typing at a keyboard wouldn't produce it,
it doesn't belong in the file.**

## Punctuation you wouldn't type

**Never an em dash.** Not in a comment, not in a docstring, not in a commit
message, not in a PR title or body, and not in a reply to me in the terminal. It
is the clearest single tell that a machine wrote the line, and there is always a
better substitute: a comma, a colon, a full stop, or brackets. If a sentence seems
to need one, it is usually two sentences.

Same for the rest of the typographic set: no en dash between words, no curly
quotes, no ellipsis character. Type ASCII. `'`, `"`, `...`.

This governs what you write, not what you edit. My own prose, in this file and in
my `.md` documents, uses em dashes and stays as it is: leave them where they are
when you edit around them. § Math notation still takes precedence inside maths,
where the Unicode glyphs are the point.

## Printing

**Whatever a script prints, I read it in a terminal or in nvim, and both are
plain text.** Decoration that reads as structure in one is noise in the other.

- **No banners, separators, emoji or colour.** `print("=" * 60)`,
  `--- Results ---`, checkmarks, ANSI escapes. They cost a line each and carry no
  data. Redirected to a file they are worse than noise: `^[[32m` is what I
  actually see in nvim.
- **One fact per line, `key: value`.** Greppable, diffable, no wrapping. Four
  short prints beat one paragraph with `\n` in it.
- **Never hand-align columns.** `f"{name:<30}{pnl:>12.4f}"` is unreadable in the
  source and wrong the moment a name is 31 chars. Emit TSV and let `column -t` or
  `:%!column -t` do the aligning.
- **Past about twenty rows, write a file and print its path.** I have visidata
  for that; the terminal scrollback is not a table viewer.
- **Print the object, not a report about it.** `print(df.to_string())` beats a
  loop that reformats every row by hand.
- **Data on stdout, progress and errors on stderr**, so `script.py > out.txt`
  leaves a file worth opening.
- **No progress bars, spinners or `\r`.** Redirected, they become one
  40,000-character line, which is the thing most likely to hang the editor.
- **Headers once, outside the loop.** A section header reprinted per iteration is
  the biggest volume multiplier there is.

**The first three points hold for your replies too**, which I read in the same
terminal. No banner lines, no rules between sections, no emoji, nothing drawn in a
box. One fact per line instead of a padded paragraph. Columns in a Markdown table
or not aligned at all, never faked with spaces.

The 2D blocks in § Display math are the one exception: that layout carries the
maths, it isn't decoration.

Bad:

```python
print("=" * 60)
print(f"RESULTS FOR {name.upper()}")
print("=" * 60)
for r in rows:
    print(f"  {r.date:<12} {r.course:<20} {r.pnl:>10.2f}")
```

Good:

```python
print(f"results: {name}")
for r in rows:
    print(f"{r.date}\t{r.course}\t{r.pnl:.2f}")
```

## Deleting

**Delete what you replace.** No old path left behind a flag, commented out, or
kept as a fallback I didn't ask for. Git has it. Unused imports, superseded
branches and dead helpers go in the same edit that obsoletes them.

## Clarity

**Write clearly, not cleverly.** Debugging is harder than writing, so code
written at the limit of your cleverness cannot be debugged — by either of us.
Where a clear version and a clever version both work, the clear one is correct.
