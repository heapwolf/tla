---- MODULE R10_TupleBinder ----
\* A tuple binder (\E <<a, b>> \in S) is outside the subset.
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == \E <<a, b>> \in {<<1, 2>>} : x' = a + b
====
