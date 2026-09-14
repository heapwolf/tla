---- MODULE LR5_PropActionQ ----
\* <>Q with Q an action (x' = 1), not a state predicate as the three forms need: refused, 150.
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
Next == x' = (x + 1) % 3
Live == <>(x' = 1)
Spec == Init /\ [][Next]_vars
====
