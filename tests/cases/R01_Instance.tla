---- MODULE R01_Instance ----
\* INSTANCE is outside the subset: refused, not skipped.
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == UNCHANGED x
I == INSTANCE Naturals
====
