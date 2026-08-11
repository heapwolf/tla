---- MODULE S12_AssumeFalse ----
\* N = 3 from the cfg; ASSUME N > 5 is false: exit 10.
\* EXPECT exit 10
EXTENDS Naturals
CONSTANT N
ASSUME N > 5
VARIABLE x
Init == x = 0
Next == UNCHANGED x
====
