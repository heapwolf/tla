---- MODULE S13_AssumeTrue ----
\* S12 with N = 7: the ASSUME holds; one state, x = 0, stuttering (no deadlock).
\* EXPECT exit 0
\* EXPECT distinct 1
\* EXPECT depth 1
EXTENDS Naturals
CONSTANT N
ASSUME N > 5
VARIABLE x
Init == x = 0
Next == UNCHANGED x
====
