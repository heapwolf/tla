---- MODULE R03_Unbounded ----
\* An unbounded quantifier is outside the subset.
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == UNCHANGED x
Inv == \A n : n = n
====
