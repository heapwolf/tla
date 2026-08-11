---- MODULE S08_NoDeadlock ----
\* S07 with CHECK_DEADLOCK FALSE: 0, 1, 2: 3 distinct, depth 3, generated 1 + 2 = 3.
\* EXPECT exit 0
\* EXPECT distinct 3
\* EXPECT depth 3
\* EXPECT generated 3
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == x < 2 /\ x' = x + 1
====
