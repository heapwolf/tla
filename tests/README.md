# tla's tests

```sh
tests/run.sh          # every case, then differential.py: 500 cases x seeds 1 2 3 4
tests/mutants.sh      # run against deliberately broken tlas; every mutant must be caught
```

Both build `build/tla` if missing; `TLA=path` tests another binary. `run.sh` prints one line
per case and per differential seed, and exits non-zero on any failure. Options:
`CASES='L*'` (glob of case names), `DIFF=0` (skip the differential test), `SEEDS='1 2'`,
`DIFFN=500`, `VERBOSE=1` (print tla's output on failure).

## cases/

Hand-written specs, `Name.tla` + `Name.cfg`. Each `.tla` explains in comments how its
expected values were derived, and states them as `\* EXPECT ...` lines (forms listed at the
top of `run.sh`): exit code, distinct/generated states, depth, trace length and values, loop
or stuttering, steps a loop must take, text the output must or must not contain.

* `S*`: safety. Counts and depth (grids, subsets, multiple initial states), the shortest
  counterexample (including one a naive DFS would find longer), deadlock and
  `CHECK_DEADLOCK FALSE`, `CONSTRAINT` (out-of-constraint states are still checked),
  `ASSUME`, evaluation errors, `-maxstates`, `SYMMETRY` orbit counts.
* `R*`: constructs outside the subset, and unreadable specs/cfgs: refused with 150.
* `L*`: liveness (`PROPERTY`), WF and SF, each with its reasoning in the file: fairness
  that makes it hold, and its absence making it fail by stuttering; WF vs SF on an
  intermittently enabled action; SF where only a sub-cycle of the component is fair;
  leads-to with late P / Q only before P / vacuous P; `<>Q` from the initial states; a stuck
  state under WF; `\A p \in S : WF(...)`; WF(Next) starving a disjunct; an action whose only
  step is stuttering; and that a shown loop is a fair behavior (takes the steps fairness
  requires).
* `LR*`: properties tla refuses (150): with SYMMETRY, with `-simulate`, and forms other than
  `P ~> Q`, `[]<>Q`, `<>Q` over state predicates.

## differential.py

Random small state graphs as specs, checked against an independent Python oracle: safety
counts, depth and shortest trace; liveness by enumerating every subset of waiting states;
and every counterexample tla shows is validated as a real fair lasso. See its docstring.

## mutants.sh

Proves a pass means something: a wrapper standing in for `tla` runs the real one and
perturbs its report (flips 0/13 or 0/12, drops or moves `Back to state`, shows stuttering as
a loop, changes or drops a trace state, reports a wrong distinct count or depth, says every
property holds). The unperturbed wrapper's failures are the baseline (tla's known bugs);
each mutant must fail some case or differential seed that passes in the baseline.
