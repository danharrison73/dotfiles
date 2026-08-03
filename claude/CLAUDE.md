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
