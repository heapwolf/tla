---- MODULE S10_ConstraintInv ----
\* S09 with invariant x /= 3: 3 is outside the constraint but still checked. Trace 0, 1, 2, 3.
\* EXPECT exit 12
\* EXPECT has Invariant NotThree is violated
\* EXPECT trace 4
\* EXPECT values x 0 1 2 3
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == x' = x + 1
Small == x < 3
NotThree == x /= 3
====
