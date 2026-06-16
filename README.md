# tla: a model checker for a subset of TLA+, in Aela

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

Trust a model only once it catches bugs planted in it: a `Bugs` constant names each planted
bug, and some invariant or property must find each one (see aedb's spec/AntiEntropy.tla and
api's spec/check.sh).

## The subset of TLA+

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
