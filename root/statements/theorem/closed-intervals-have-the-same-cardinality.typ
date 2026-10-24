#import "/lib/statements.typ": *

#let entry = (
  title: [Any Two Nondegenerate Closed Intervals Have the Same Cardinality],
  date: "2026-10-26",
  author: "Glomzzz",
  parent: "/how/daily/closed-intervals-have-the-same-cardinality.typ",
)

#show: statement-page.with(
  "theorem/closed-intervals-have-the-same-cardinality",
  entry,
)

Let $a, b, c, d in RR$, with $a < b$ and $c < d$.
Then the closed intervals $[a, b]$ and $[c, d]$ have the same cardinality.

#proof[
  Define $f class("relation", colon) [a, b] -> [c, d]$ by

  $
  f(x) = c + frac(d - c, b - a)(x - a).
  $

  In particular, $f(a) = c$ and $f(b) = d$.
  We check that $f$ is well-defined, injective, and surjective.

  *1. Well-definedness.*

  Let $x in [a, b]$. Since $b - a > 0$,

  $
  a <= x <= b quad => quad 0 <= frac(x - a, b - a) <= 1.
  $

  Multiplying by $d - c > 0$ and adding $c$ gives

  $
  c <= c + frac(d - c, b - a)(x - a) <= d.
  $

  Thus $f(x) in [c, d]$, so the formula really does define a function with the
  required domain and codomain.

  *2. Injectivity (one-to-one).*

  Let $x_1, x_2 in [a, b]$ and suppose $f(x_1) = f(x_2)$. Then

  $
  c + frac(d - c, b - a)(x_1 - a)
    = c + frac(d - c, b - a)(x_2 - a).
  $

  Subtracting $c$ and dividing by the nonzero number
  $(d - c) slash (b - a)$ yields

  $
  x_1 - a = x_2 - a, quad "hence" quad x_1 = x_2.
  $

  Therefore, $f$ is injective: distinct points cannot share a partner.

  *3. Surjectivity (onto).*

  Let $y in [c, d]$ be arbitrary. Choose

  $
  x = a + frac(b - a, d - c)(y - c).
  $

  Since $d - c > 0$,

  $
  c <= y <= d quad => quad 0 <= frac(y - c, d - c) <= 1.
  $

  Multiplying by $b - a > 0$ and adding $a$ shows that

  $
  a <= a + frac(b - a, d - c)(y - c) <= b.
  $

  Hence $x in [a, b]$. Substituting this choice into $f$ gives

  $
  f(x) &= c + frac(d - c, b - a)(x - a) \
       &= c + frac(d - c, b - a)
          lr(frac(b - a, d - c)(y - c)) \
       &= c + (y - c) \
       &= y.
  $

  Thus every $y in [c, d]$ has a preimage in $[a, b]$, so $f$ is surjective.

  Since $f$ is both injective and surjective, it is a bijection. Therefore,

  $
  |[a, b]| = |[c, d]|.
  $
]

The pairing can be reversed explicitly:

$
f^(-1)(y) = a + frac(b - a, d - c)(y - c), quad y in [c, d].
$
