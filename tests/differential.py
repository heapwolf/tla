"""tla against an independent oracle on random state machines.

Each case is a random finite graph as a TLA+ spec: variable s over 0..N-1,
actions whose disjuncts are edges (s = a /\\ s' = b), random initial states,
random WF/SF on random actions, an invariant and a property. The oracle knows
nothing of tla's code; it explores the graph from the same description:

* safety: breadth-first search gives the distinct states, the depth, and the
  length of the shortest behavior to a state violating the invariant;
* liveness: by definition, not tla's algorithm. A fair behavior never reaching
  the goal exists iff some nonempty set S of waiting states (reachable, where
  the property waits) is strongly connected (every state may stutter) and fair:
  each WF action has a step within S or is disabled in some state of S; each SF
  action has a step within S or is disabled in all of S. Every subset is tried.

tla's verdict must agree. When tla says a property fails, its behavior is
checked: a graph path from an initial state, a loop back to the named state (or
final stuttering), never at the goal once the property starts waiting, and a
loop a fair behavior can repeat forever.

    python3 -I tests/differential.py [cases] [seed]     (tla at build/tla, or $TLA)
"""
import itertools
import os
import random
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
TLA = os.environ.get("TLA", os.path.join(HERE, "..", "build", "tla"))


def make(rng):
    n = rng.randint(1, 6)
    acts = rng.randint(1, 4)
    edges = []                                  # per action: a set of (a, b)
    for _ in range(acts):
        k = rng.randint(0, n + 2)
        edges.append(sorted({(rng.randrange(n), rng.randrange(n)) for _ in range(k)}))
    init = sorted(rng.sample(range(n), rng.randint(1, n)))
    goal = sorted(rng.sample(range(n), rng.randint(0, n)))
    bad = sorted(rng.sample(range(n), rng.randint(0, 1)))
    fair = [rng.choice([None, "WF", "SF"]) for _ in range(acts)]
    form = rng.choice(["often", "leads", "soon"])
    start = sorted(rng.sample(range(n), rng.randint(0, n)))
    return dict(n=n, edges=edges, init=init, goal=goal, bad=bad, fair=fair, form=form, start=start)


def spec(c):
    def setof(xs):
        return "{" + ", ".join(map(str, xs)) + "}"
    lines = ["---- MODULE R ----", "EXTENDS Naturals", "VARIABLE s", "vars == <<s>>",
             f"Init == s \\in {setof(c['init'])}"]
    for i, es in enumerate(c["edges"]):
        body = " \\/ ".join(f"(s = {a} /\\ s' = {b})" for a, b in es) or "FALSE"
        lines.append(f"A{i} == {body}")
    lines.append("Next == " + " \\/ ".join(f"A{i}" for i in range(len(c["edges"]))))
    lines.append(f"Safe == s \\notin {setof(c['bad'])}")
    lines.append(f"Goal == s \\in {setof(c['goal'])}")
    if c["form"] == "often":
        lines.append("Live == []<>Goal")
    elif c["form"] == "soon":
        lines.append("Live == <>Goal")
    else:
        lines.append(f"Live == (s \\in {setof(c['start'])}) ~> Goal")
    fair = [f"{f}_vars(A{i})" for i, f in enumerate(c["fair"]) if f]
    lines.append("Spec == Init /\\ [][Next]_vars" + "".join(" /\\ " + f for f in fair))
    lines.append("====")
    return "\n".join(lines) + "\n"


def oracle(c):
    """(distinct, depth, shortest violation's length or None, live: True/False)"""
    n, edges = c["n"], c["edges"]
    succ = {u: set() for u in range(n)}
    for es in edges:
        for a, b in es:
            succ[a].add(b)
    # breadth first, as tla: depth is the longest shortest path + 1
    dist = {u: 1 for u in c["init"]}
    order = list(c["init"])
    at = 0
    while at < len(order):
        u = order[at]
        at += 1
        for v in sorted(succ[u]):
            if v not in dist:
                dist[v] = dist[u] + 1
                order.append(v)
    reach = set(dist)
    bad = [dist[u] for u in reach if u in c["bad"]]
    violation = min(bad) if bad else None
    # each action's steps that change s, and where it's enabled
    step = [{(a, b) for a, b in es if a != b} for es in edges]
    enabled = [{a for a, b in es if a != b} for es in edges]
    goal = set(c["goal"])
    # where the property starts waiting, and what it waits through
    if c["form"] == "often":
        seeds = {u for u in reach if u not in goal}
    elif c["form"] == "soon":
        seeds = {u for u in c["init"] if u not in goal}
    else:
        seeds = {u for u in reach if u in c["start"] and u not in goal}
    waiting = set(seeds)
    todo = list(seeds)
    while todo:
        u = todo.pop()
        for v in succ[u]:
            if v not in goal and v not in waiting:
                waiting.add(v)
                todo.append(v)
    live = True
    for k in range(1, len(waiting) + 1):
        for S in itertools.combinations(sorted(waiting), k):
            if fair_set(set(S), succ, c["fair"], step, enabled):
                live = False
                break
        if not live:
            break
    return len(reach), max(dist.values()), violation, live, waiting


def connected(S, succ):
    """Every state of S reaches every other within S (each may stutter)."""
    for u in S:
        seen, todo = {u}, [u]
        while todo:
            x = todo.pop()
            for y in succ[x]:
                if y in S and y not in seen:
                    seen.add(y)
                    todo.append(y)
        if seen != S:
            return False
    return True


def fair_set(S, succ, fair, step, enabled):
    if not connected(S, succ):
        return False
    for i, f in enumerate(fair):
        if not f:
            continue
        taken = any(a in S and b in S for a, b in step[i])
        if taken:
            continue
        if f == "WF" and all(u in enabled[i] for u in S):
            return False
        if f == "SF" and any(u in enabled[i] for u in S):
            return False
    return True


def run(c, with_property):
    d = tempfile.mkdtemp(prefix="tla-diff-")
    with open(os.path.join(d, "R.tla"), "w") as f:
        f.write(spec(c))
    cfg = "SPECIFICATION Spec\nINVARIANT Safe\nCHECK_DEADLOCK FALSE\n"
    if with_property:
        cfg = "SPECIFICATION Spec\nPROPERTY Live\nCHECK_DEADLOCK FALSE\n"
    with open(os.path.join(d, "R.cfg"), "w") as f:
        f.write(cfg)
    p = subprocess.run([TLA, os.path.join(d, "R.tla")], capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr


def trace(out):
    """States tla shows (values of s), and the state its loop goes back to (None: stuttering)."""
    states, back = [], None
    for line in out.splitlines():
        m = re.match(r"/\\ s = (\d+)$", line.strip())
        if m:
            states.append(int(m.group(1)))
        m = re.match(r"Back to state (\d+):", line)
        if m:
            back = int(m.group(1))
    return states, back


def check_lasso(c, out, waiting):
    """tla's counterexample: a real path, a real loop, waiting all along the loop, and fair."""
    n, edges = c["n"], c["edges"]
    succ = {u: set() for u in range(n)}
    for es in edges:
        for a, b in es:
            succ[a].add(b)
    states, back = trace(out)
    if not states or states[0] not in c["init"]:
        return "no behavior from an initial state"
    for a, b in zip(states, states[1:]):
        if b not in succ[a]:
            return f"{a} -> {b} is no step"
    if back is None:
        loop = [states[-1]]
        if "Stuttering" not in out:
            return "neither a loop nor stuttering"
    else:
        if states[back - 1] not in succ[states[-1]]:
            return f"the loop's last step {states[-1]} -> {states[back - 1]} is no step"
        loop = states[back - 1:]
    if any(u not in waiting for u in loop):
        return f"the loop leaves the waiting states: {loop}"
    S = set(loop)
    used = set(zip(loop, loop[1:] + loop[:1])) if back is not None else set()
    step = [{(a, b) for a, b in es if a != b} for es in edges]
    enabled = [{a for a, b in es if a != b} for es in edges]
    for i, f in enumerate(c["fair"]):
        if not f:
            continue
        if any(e in used for e in step[i]):
            continue
        if f == "WF" and all(u in enabled[i] for u in S):
            return f"the loop isn't fair: WF(A{i}) enabled throughout, never taken"
        if f == "SF" and any(u in enabled[i] for u in S):
            return f"the loop isn't fair: SF(A{i}) enabled, never taken"
    return None


def main():
    cases = int(sys.argv[1]) if len(sys.argv) > 1 else 300
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    rng = random.Random(seed)
    failed = 0
    kinds = {"holds": 0, "fails": 0, "safe": 0, "unsafe": 0, "loops": 0, "stutters": 0}
    for k in range(cases):
        c = make(rng)
        distinct, depth, violation, live, waiting = oracle(c)
        code, out = run(c, with_property=False)
        want = 12 if violation else 0
        problem = None
        if code != want:
            problem = f"safety: tla exit {code}, oracle {want}"
        elif violation is None:
            got = re.search(r"(\d+) distinct states found", out)
            dep = re.search(r"depth of the complete state graph search is (\d+)", out)
            if not got or int(got.group(1)) != distinct or not dep or int(dep.group(1)) != depth:
                problem = f"counts: tla {got and got.group(1)}/{dep and dep.group(1)}, oracle {distinct}/{depth}"
            kinds["safe"] += 1
        else:
            states, _ = trace(out)
            if len(states) != violation:
                problem = f"trace: tla {len(states)} states, shortest {violation}"
            kinds["unsafe"] += 1
        if problem is None:
            code, out = run(c, with_property=True)
            want = 0 if live else 13
            if code != want:
                problem = f"liveness: tla exit {code}, oracle {want}"
            elif not live:
                problem = check_lasso(c, out, waiting)
                kinds["loops" if "Back to state" in out else "stutters"] += 1
            kinds["holds" if live else "fails"] += 1
        if problem:
            failed += 1
            print(f"FAIL case {k} (seed {seed}): {problem}\n{spec(c)}{out}")
    print(f"{cases - failed}/{cases} agree: {kinds}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
