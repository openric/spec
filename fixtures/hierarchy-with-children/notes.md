# Fixture — hierarchy-with-children

**Endpoint:** `GET /api/ric/v1/hierarchy/912150?include=parent,children,siblings`  *(Egypt — Place)*
**Schema:** [hierarchy.schema.json](../../schemas/hierarchy.schema.json)

Demonstrates:
- The 3-axis walk: parent + children + siblings in one response.
- Mixed `type_id` among children (cities + archaeological sites are both valid children of a country).
- The subject entity (Egypt) never appears in any of the three lists — only its relations.

For Place, hierarchy is resolved via `ric_place.parent_id`. For other entity types it's derived from `ric_relation_meta.dropdown_code` ∈ {`has_part`, `is_part_of`, `includes`, `is_included_in`, `is_superior_of`}.
