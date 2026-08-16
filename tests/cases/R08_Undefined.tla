---- MODULE R08_Undefined ----
\* An undefined name (SANY rejects it).
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
Init == x = y
Next == UNCHANGED x
====
