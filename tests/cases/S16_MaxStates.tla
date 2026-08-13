---- MODULE S16_MaxStates ----
\* x + 1 forever, -maxstates 10: the search stops at the limit: exit 1.
\* EXPECT args -maxstates 10
\* EXPECT exit 1
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == x' = x + 1
====
