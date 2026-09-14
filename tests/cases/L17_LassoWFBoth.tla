---- MODULE L17_LassoWFBoth ----
\* A goes 0 -> 1 -> 2 -> 0, G the reverse, 0 -> 2 -> 1 -> 0. Both are always enabled and WF.
\* x = 9 never holds, so []<>(x = 9) fails (e.g. alternating A, G is fair). But a
\* counterexample loop must take both an A and a G step: A steps alone leave G enabled
\* throughout and never taken (and vice versa): unfair. Checked: the loop's steps (from the
\* state it goes back to, plus the step back) include both <A> and <G>.
\* EXPECT exit 13
\* EXPECT loop
\* EXPECT looplabel A
\* EXPECT looplabel G
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
A == \/ x = 0 /\ x' = 1
     \/ x = 1 /\ x' = 2
     \/ x = 2 /\ x' = 0
G == \/ x = 0 /\ x' = 2
     \/ x = 1 /\ x' = 0
     \/ x = 2 /\ x' = 1
Next == A \/ G
Live == []<>(x = 9)
Spec == Init /\ [][Next]_vars /\ WF_vars(A) /\ WF_vars(G)
====
