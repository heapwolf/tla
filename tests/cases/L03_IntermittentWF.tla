---- MODULE L03_IntermittentWF ----
\* Toggle flips x forever; Go (enabled only at x = 1, not done) sets done.
\* WF(Go): toggling forever, (0,F) -> (1,F) -> (0,F) ..., takes Toggle infinitely often
\* (WF(Toggle) met); Go is disabled at each x = 0, so not continuously enabled (WF(Go) met).
\* It never gets done: <>done fails by a loop over the two states (stuttering is never fair:
\* Toggle is always enabled).
\* EXPECT exit 13
\* EXPECT loop
\* EXPECT lacks done = TRUE
EXTENDS Naturals
VARIABLES x, done
vars == <<x, done>>
Init == x = 0 /\ done = FALSE
Toggle == x' = 1 - x /\ UNCHANGED done
Go == x = 1 /\ done = FALSE /\ done' = TRUE /\ UNCHANGED x
Next == Toggle \/ Go
Live == <>(done = TRUE)
Spec == Init /\ [][Next]_vars /\ WF_vars(Toggle) /\ WF_vars(Go)
====
