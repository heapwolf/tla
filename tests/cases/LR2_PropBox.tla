---- MODULE LR2_PropBox ----
\* []P as a PROPERTY is not one of the three forms: refused (it would be an INVARIANT).
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
Next == x' = (x + 1) % 3
Live == [](x < 3)
Spec == Init /\ [][Next]_vars
====
