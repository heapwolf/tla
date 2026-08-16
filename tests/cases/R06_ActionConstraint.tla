---- MODULE R06_ActionConstraint ----
\* ACTION_CONSTRAINT in the cfg is outside the subset.
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == x < 2 /\ x' = x + 1
AC == x' > x
====
