---- MODULE S11_InitViolation ----
\* Initial state x = 2 breaks the invariant: the trace is that one state.
\* EXPECT exit 12
\* EXPECT has Invariant Small is violated
\* EXPECT trace 1
\* EXPECT values x 2
EXTENDS Naturals
VARIABLE x
Init == x \in 0..2
Next == UNCHANGED x
Small == x < 2
====
