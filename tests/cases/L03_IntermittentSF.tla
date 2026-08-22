---- MODULE L03_IntermittentSF ----
\* Toggle flips x forever; Go (enabled only at x = 1, not done) sets done.
\* SF(Go): toggling enables Go infinitely often (at each x = 1), so Go must be taken: done.
\* Stuttering is unfair (WF(Toggle), always enabled). Holds.
\* EXPECT exit 0
EXTENDS Naturals
VARIABLES x, done
vars == <<x, done>>
Init == x = 0 /\ done = FALSE
Toggle == x' = 1 - x /\ UNCHANGED done
Go == x = 1 /\ done = FALSE /\ done' = TRUE /\ UNCHANGED x
Next == Toggle \/ Go
Live == <>(done = TRUE)
Spec == Init /\ [][Next]_vars /\ WF_vars(Toggle) /\ SF_vars(Go)
====
