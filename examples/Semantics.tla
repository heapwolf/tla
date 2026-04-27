------------------------------ MODULE Semantics ------------------------------
\* TLA+ semantics facts as ASSUMEs; tla must find all TRUE. Expected values come from
\* Specifying Systems, not from running the checker.
EXTENDS Integers, Sequences, FiniteSets, TLC

VARIABLE x

\* arithmetic: \div and % round toward minus infinity
ASSUME 7 \div 2 = 3 /\ (-7) \div 2 = -4 /\ -7 % 2 = 1 /\ 7 % 3 = 1 /\ 2^10 = 1024
ASSUME 1 + 2 * 3 = 7 /\ (1 + 2) * 3 = 9 /\ -3 + 5 = 2 /\ 10 - 2 - 3 = 5
ASSUME 1..0 = {} /\ 2..4 = {2, 3, 4} /\ 3 \in 1..5 /\ 6 \notin 1..5
\* logic and precedence: \div (13) binds tighter than unary - (12), % (10) looser
ASSUME -7 \div 2 = -3 /\ -7 % 2 = 1
ASSUME (TRUE => FALSE) = FALSE /\ (FALSE => FALSE) /\ (TRUE <=> TRUE) /\ ~(TRUE <=> FALSE)
ASSUME ~ 1 = 2
ASSUME BOOLEAN = {TRUE, FALSE} /\ "a" \in STRING /\ "a" /= "b" /\ "abc" = "abc"
ASSUME IF FALSE THEN 1 ELSE 2 = 2
ASSUME (CASE 1 = 2 -> 1 [] 1 = 1 -> 2 [] OTHER -> 3) = 2
ASSUME (CASE 1 = 2 -> 1 [] OTHER -> 3) = 3
ASSUME LET f(a) == a + 1
           b == 2
       IN  f(b) = 3
\* bullets: the \/ list is one /\ item
ASSUME /\ \/ FALSE
          \/ TRUE
       /\ TRUE
ASSUME ~ /\ TRUE
         /\ FALSE
\* sets
ASSUME {1, 2} \cup {2, 3} = {1, 2, 3} /\ {1, 2} \cap {2, 3} = {2} /\ {1, 2} \ {2} = {1}
ASSUME {{1, 2}} = {{2, 1}} /\ {1, 1, 2} = {1, 2} /\ Cardinality({1, 1, 2}) = 2
ASSUME SUBSET {1, 2} = {{}, {1}, {2}, {1, 2}} /\ SUBSET {1} = {{}, {1}}
ASSUME {SUBSET {1}} = {{{}, {1}}}
ASSUME UNION {{1}, {2, 3}} = {1, 2, 3} /\ Cardinality(SUBSET (1..4)) = 16
ASSUME {1} \subseteq {1, 2} /\ ~({3} \subseteq {1, 2}) /\ {} \subseteq {}
ASSUME {y \in 1..5 : y % 2 = 0} = {2, 4} /\ {y * 2 : y \in 1..3} = {2, 4, 6}
ASSUME {<<a, b>> : a \in {1}, b \in {2, 3}} = {<<1, 2>>, <<1, 3>>}
ASSUME {1, 2} \X {3} = {<<1, 3>>, <<2, 3>>}
ASSUME Cardinality({1, 2} \X {3, 4} \X {5}) = 4 /\ <<1, 3, 5>> \in {1, 2} \X {3, 4} \X {5}
ASSUME \A y \in {} : FALSE
ASSUME ~ \E y \in {} : TRUE
ASSUME \A y, z \in 1..3 : y + z <= 6
ASSUME \E y \in 1..3, z \in {10} : y + z = 12
ASSUME (CHOOSE y \in 1..5 : y > 3) \in {4, 5}
ASSUME 1 \in Nat /\ -1 \notin Nat /\ -1 \in Int
\* functions, records and tuples
ASSUME [y \in {1, 2} |-> y * y][2] = 4 /\ DOMAIN [y \in {1, 2} |-> 0] = {1, 2}
ASSUME <<1, 2>> = [i \in 1..2 |-> i] /\ <<>> = [y \in {} |-> 1]
ASSUME [a |-> 1, b |-> 2].b = 2 /\ DOMAIN [a |-> 1, b |-> 2] = {"a", "b"}
ASSUME [a |-> 1, b |-> 2] = [b |-> 2, a |-> 1] /\ [a |-> 1]["a"] = 1
ASSUME [[a |-> 1] EXCEPT !.a = @ + 1].a = 2
ASSUME [[a |-> 1] EXCEPT !["a"] = 7] = [a |-> 7]
ASSUME LET g == [r \in {1, 2} |-> [s \in {1, 2} |-> 0]]
           h == [g EXCEPT ![1][2] = 5]
       IN  h[1][2] = 5 /\ h[2][2] = 0 /\ h[1][1] = 0
ASSUME [<<1, 2>> EXCEPT ![1] = 9, ![2] = @ * 10] = <<9, 20>>
ASSUME [<<1, 2>> EXCEPT ![3] = 9] = <<1, 2>>
ASSUME [y \in {1, 2}, z \in {3} |-> y + z][2, 3] = 5
ASSUME [y \in {1, 2}, z \in {3} |-> y + z][<<1, 3>>] = 4
ASSUME Cardinality([{1, 2} -> {0, 1}]) = 4 /\ [{1} -> {2}] = {[y \in {1} |-> 2]}
ASSUME [a : {1, 2}, b : {3}] = {[a |-> 1, b |-> 3], [a |-> 2, b |-> 3]}
ASSUME [a |-> 1] \in [a : Nat] /\ [y \in {1} |-> 2] \in [{1} -> Nat]
ASSUME [a |-> -1] \notin [a : Nat] /\ [b |-> 1] \notin [a : Nat]
ASSUME (1 :> 2 @@ 3 :> 4)[3] = 4 /\ ((1 :> 2) @@ (1 :> 3)) = (1 :> 2)
\* sequences
ASSUME Len(<<1, 2, 3>>) = 3 /\ Append(<<1>>, 2) = <<1, 2>> /\ Head(<<1, 2>>) = 1
ASSUME Tail(<<1, 2>>) = <<2>> /\ SubSeq(<<1, 2, 3>>, 2, 3) = <<2, 3>> /\ SubSeq(<<1>>, 2, 1) = <<>>
ASSUME <<1>> \o <<2>> = <<1, 2>> /\ <<1, 2>> \in Seq(Nat) /\ <<>> \in Seq({})
ASSUME <<-1>> \notin Seq(Nat)
\* recursion
RECURSIVE Sum(_)
Sum(S) == IF S = {} THEN 0 ELSE LET m == CHOOSE y \in S : TRUE IN m + Sum(S \ {m})
ASSUME Sum(1..4) = 10
\* a definition used as a constant
Sq(n) == n * n
ASSUME Sq(3) = 9
ASSUME ToString(<<1, "a">>) = "<<1, \"a\">>"

Init == x = 0
Next == x' = x
==============================================================================
