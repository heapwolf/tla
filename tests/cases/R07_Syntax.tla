---- MODULE R07_Syntax ----
\* A syntax error: an unclosed parenthesis.
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
Init == (x = 0
Next == UNCHANGED x
====
