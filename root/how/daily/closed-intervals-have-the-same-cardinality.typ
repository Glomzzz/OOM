#import "/lib/lib.typ": *
#import "/lib/statements.typ": statement
#import "/lib/diagrams/closed-intervals-have-the-same-cardinality.typ" as diagrams

#show: schema.with("page")

#title[Any Two Nondegenerate Closed Intervals Have the Same Cardinality]
#metacontent("description")[A geometric picture and an explicit affine bijection show why any two nondegenerate closed intervals have the same cardinality.]
#date[2026-10-26]
#author[Glomzzz]
#parent("/how/daily/index.typ")
#heading-numbering("none")

A longer segment has greater length, but does it have more points?
For *cardinality*, we compare sets by pairing their elements, not by measuring
their lengths. Two sets have the same cardinality if there is a *bijection*
between them: every point in either set has exactly one partner in the other.

Let $a, b, c, d in RR$, with $a < b$ and $c < d$.
The goal is to pair the points of $[a, b]$ and $[c, d]$ without leaving any
point unpaired.

= Geometric idea: one ray, one pair

Draw the intervals as two parallel segments, as in the picture.
The lines through the corresponding endpoints meet at a point $O$ outside
both segments. Given a point $x$ on the upper segment, draw the ray from $O$
through $x$. Its unique intersection with the lower segment is the partner
of $x$, which we call $f(x)$.

#diagrams.point-correspondence()

This pairing works in both directions:

- Each point $x$ on the upper segment determines one ray and hence exactly
  one point $f(x)$ on the lower segment.
- Two distinct points on the upper segment lie on different rays, so they
  cannot have the same partner on the lower segment.
- Every point on the lower segment lies on a ray that also meets the upper
  segment, so no point is left unpaired.

The picture shows a shorter upper segment. If it is longer, interchange the
roles of the segments in the picture; if their lengths are equal, simply
translate one segment onto the other.

By similar triangles, paired points are the same fraction of the way from
the left endpoint to the right endpoint:

$
frac(x - a, b - a) = frac(f(x) - c, d - c).
$

For example, the point two-fifths of the way along one segment is paired with
the point two-fifths of the way along the other.
Writing this relative position as $t in [0, 1]$, we have

$
x = a + t(b - a), quad f(x) = c + t(d - c).
$

Solving for $t$ gives the formula used in the proof.

= Statement and proof

#statement("theorem/closed-intervals-have-the-same-cardinality")

= Conclusion

Any two nondegenerate closed intervals of real numbers therefore have the
same cardinality, regardless of their lengths or positions on the real line.
The nondegeneracy assumption matters: $[a, a]$ has only one point and cannot
have the same cardinality as an interval with distinct endpoints.
