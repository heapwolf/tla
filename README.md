# `tla`: a model checker for a subset of TLA+, in Aela

tla checks every reachable state of a TLA+ spec, as TLC does, without Java: safety
invariants, and liveness properties under the SPECIFICATION's fairness. A spec is a TLA+
module plus a cfg in TLC's format; SANY and TLC read both unchanged. It began in aedb for
aedb's protocols (aedb's spec/) and is now standalone, used by models of the Aela runtime
(aela's docs/proposals/VERIFIED_RUNTIME.md), aedb, api (api/spec), and others.

```sh
aec build . --product tla               # or: aec src/main.ae -o tla
tla examples/TwoPhase.tla               # uses examples/TwoPhase.cfg; checks every state
tla Spec.tla -config Live.cfg           # another cfg, e.g. one with a PROPERTY
tla Spec.tla -simulate 10000 -depth 60 -seed 7   # random behaviors
aec test src                            # in-code tests: the examples, TLC's counts
tests/run.sh                            # test suite (tests/README.md)
```

You should only trust a model only once it catches bugs planted in it: a `Bugs` constant
names each planted bug, and some invariant or property must find each one (see aedb's
spec/AntiEntropy.tla and api's spec/check.sh).

## The Subset

Invariants are checked as in TLC (breadth-first, giving the shortest trace to a violation),
and so are properties (strongly connected components of the state graph, against the
fairness). Anything outside the subset is an error, never silently skipped.

**Modules.** `EXTENDS` of Naturals, Integers, Sequences, FiniteSets, TLC, and your own
modules (`Name.tla` in the same directory); `CONSTANT(S)`, `VARIABLE(S)`, `ASSUME`,
definitions with parameters, `LOCAL`, `RECURSIVE`, `f[x \in S] == e` (non-recursive),
`THEOREM` (parsed, not checked). Names resolve as in SANY: defined before use, never bound
twice.

**Expressions.** Booleans and their operators, `/\` and `\/` bullet lists, `IF`, `CASE`,
`LET`, bounded `\A`, `\E` and `CHOOSE`; integers and `+ - * \div % ^ .. < <= > >=`; strings;
sets (`{a, b}`, `{x \in S : P}`, `{e : x \in S}`, `\cup \cap \ \subseteq \in \notin SUBSET
UNION \X`, `Nat`, `Int`, `BOOLEAN`, `STRING`); functions (`[x \in S |-> e]`, `f[x]`, `DOMAIN`,
`[S -> T]`, `EXCEPT` with `@`, `:>`, `@@`); records (`[a |-> 1]`, `r.a`, `[a : S]`); tuples and
sequences (`<<a, b>>`, `Seq`, `Len`, `Append`, `Head`, `Tail`, `SubSeq`, `\o`); `Cardinality`,
`IsFiniteSet`, `Print`, `PrintT`, `Assert`, `ToString`, `Permutations`.

**Actions.** As in TLC, `x' = e` and `x' \in S` assign a variable the first time and test it
afterwards; `UNCHANGED`; a SPECIFICATION of the form `Init /\ [][Next]_vars` (conjuncts at
any depth), with fairness `WF_vars(A)` and `SF_vars(A)`, also under bounded `\A` (`\A p \in P
: WF_vars(Step(p))`, one condition per instance) and in conjunctions. Fairness doesn't affect
safety; PROPERTYs are checked under it.

**Properties.** `PROPERTY P` (or `PROPERTIES`) in the cfg, in one of three forms, where P and
Q are state predicates (no primes, `UNCHANGED` or temporal operators, directly or in what
they use):

| form | means |
| --- | --- |
| `P ~> Q` | whenever P holds, Q holds then or later |
| `[]<>Q` | Q holds infinitely often (`TRUE ~> Q`) |
| `<>Q` | Q holds eventually, from the initial states |

For fairness, a step of A means `<<A>>_vars`, one that changes the state; a stuttering step
neither counts as A nor makes A enabled (every state may stutter) As in TLC, the state graph
is kept (successors, which fairness conditions each step satisfies, where each is enabled).
The waiting states (reachable from a P-and-not-Q state through not-Q states) are split into
strongly connected components. A component is fair if each WF action is taken in it or
disabled in some state of it, and each SF action is taken in it or disabled in all its
states (otherwise, the states enabling it are removed and the rest split again). A fair
component is a counterexample, shown as a behavior into it plus a fair loop around it (a
step of each fairness condition it can take), or as stuttering in a state where nothing
fair is enabled.

**cfg.** `CONSTANT(S)` (numbers, strings, booleans, model values, sets of them, and `C <-
Def`), `INIT` and `NEXT` or `SPECIFICATION`, `INVARIANT(S)`, `PROPERTY`/`PROPERTIES`,
`CONSTRAINT(S)`, `CHECK_DEADLOCK`, `SYMMETRY`.

**Not supported:** other temporal forms (`[]P`, `<>[]P`, `P => <>Q` as a property, nested
`~>`, `\A x : P ~> Q`), `ENABLED`, a PROPERTY with `SYMMETRY` (merging symmetric states loses
per-instance fairness) or with `-simulate`, `INSTANCE`, `LAMBDA`, operator arguments,
user-defined infix operators, unbounded quantifiers and `CHOOSE`, tuple binders (`\E <<x,
y>> \in S`), recursive functions, `VIEW`, `ACTION_CONSTRAINT`, `ALIAS`.

**Checking.** Exit codes match TLC's (0 ok, 10 false ASSUME, 11 deadlock, 12 invariant
violated, 13 property violated, 75 evaluation error, 150 unreadable spec or cfg), plus 1 when
the search stops early at `-maxstates` or `-maxvalues`. A state outside a `CONSTRAINT` is
checked but not explored, and is left out of a property's graph (being cut off there doesn't
mean the system is stuck). States are identified by 64-bit fingerprints, as in TLC (under
`SYMMETRY`, the least over its renamings); the report gives the collision odds. As in TLC,
an explored state keeps only its fingerprint and parent (plus its edges, for a PROPERTY); a
state is held whole only while queued, and values held only by explored states are freed
periodically. A violation's trace is rebuilt from the initial states, each step taking the
successor with the next fingerprint. `-simulate N -depth D -seed S` checks random behaviors
instead: it finds deep bugs but proves nothing.

## Testing

- `aec test src`: the examples in `examples` with TLC's counts (Lamport's TCommit, 34
  states; TwoPhase, 288, and 80 with SYMMETRY; DieHard's 7-state trace); `Semantics.tla`,
  whose ASSUMEs are facts from Specifying Systems; the same reports when explored states are
  freed at every step; and liveness under WF, SF and `\A` fairness. An independent Python
  brute force matched the counts (distinct states, states generated, depth) and the symmetry
  orbits (80 of 288; 314 of 8,832 with 5 resource managers).
- `tests/run.sh`: 56 specs with hand-derived expected outcomes (counts, depths, shortest
  traces, deadlock, constraints, refusals, and liveness: WF vs SF, a fair sub-cycle SF must
  find, vacuous properties, stuck states, fairness under `\A`, stuttering steps), then
  `tests/differential.py`: random state machines checked against a Python oracle sharing no
  code with tla (safety by breadth-first search; liveness by trying every set of waiting
  states, per the definition of a fair behavior), and every counterexample tla shows is
  verified as a real fair loop. 8,000 cases across 16 seeds agree. `tests/mutants.sh` shows
  the suite catches each of 11 kinds of wrong answer.
