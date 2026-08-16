---- MODULE R09_BadCfg ----
\* A cfg naming an INVARIANT the spec does not define.
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == UNCHANGED x
====
