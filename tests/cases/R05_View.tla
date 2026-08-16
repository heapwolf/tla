---- MODULE R05_View ----
\* VIEW in the cfg is outside the subset.
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == UNCHANGED x
V == x
====
