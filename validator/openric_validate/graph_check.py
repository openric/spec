# Copyright (C) 2026 Johan Pieterse
# Plain Sailing Information Systems
# Email: johan@plansailingisystems.co.za
#
# This file is part of OpenRiC.
#
# OpenRiC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

"""Graph invariants + isomorphism checks.

Stub for the thin slice. Full implementation in Week 2 items 16–17.

The six invariants per graph-primitives.md §6:
    1. Root presence — root URI is in nodes
    2. No dangling edges — every edge endpoint exists in nodes
    3. Unique node ids
    4. Stable identifiers (not checkable statically)
    5. Type vocabulary — every Node.type is RiC-O or OpenRiC
    6. Edge predicates — every Edge.predicate is in vocabulary
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass
class InvariantViolation:
    invariant: str
    message: str


def check_subgraph_invariants(subgraph: dict[str, Any]) -> list[InvariantViolation]:
    """Check the six invariants. Returns empty list if all pass."""
    violations: list[InvariantViolation] = []

    root = subgraph.get("openric:root")
    nodes = subgraph.get("openric:nodes", []) or []
    edges = subgraph.get("openric:edges", []) or []
    node_ids = {n.get("id") for n in nodes if n.get("id")}

    # Invariant 1 — Root presence
    if root and root not in node_ids:
        violations.append(InvariantViolation(
            invariant="root-presence",
            message=f"Root {root!r} is not present in nodes array",
        ))

    # Invariant 2 — No dangling edges
    for i, e in enumerate(edges):
        for end in ("source", "target"):
            endpoint = e.get(end)
            if endpoint and endpoint not in node_ids:
                violations.append(InvariantViolation(
                    invariant="no-dangling-edges",
                    message=f"Edge[{i}].{end} {endpoint!r} not in nodes",
                ))

    # Invariant 3 — Unique node ids
    seen: set[str] = set()
    for i, n in enumerate(nodes):
        nid = n.get("id")
        if nid and nid in seen:
            violations.append(InvariantViolation(
                invariant="unique-ids",
                message=f"Duplicate node id {nid!r} at index {i}",
            ))
        if nid:
            seen.add(nid)

    return violations
