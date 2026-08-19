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

When a sub/superscript has no Unicode form (`x_{i+1}`, `σ²_max`), fall back to
plain `x_(i+1)` / `σ²_max` — never `x_{i+1}` with braces.

Simple fractions go inline with `/` and explicit parens: `(a + b)/(2c)`, not `a+b/2c`.

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
