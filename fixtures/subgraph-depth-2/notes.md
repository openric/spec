# Fixture: `subgraph-depth-2`

**Source:** [`https://heratio.theahg.co.za/api/ric/v1/graph?uri=https://heratio.theahg.co.za/informationobject/egyptian-boat&depth=2`](https://heratio.theahg.co.za/api/ric/v1/graph?uri=https://heratio.theahg.co.za/informationobject/egyptian-boat&depth=2)

A 2-hop subgraph. Exercises: depth parameter honoured, still satisfies the six invariants, predicates propagate through multi-hop edges.

**Validation:** `expected.jsonld` MUST validate against the schema selected by its `@type`.
