# Fixture: `record-multilingual`

**Source:** [`https://ric.theahg.co.za/api/ric/v1/records/cat-in-arms`](https://ric.theahg.co.za/api/ric/v1/records/cat-in-arms), re-captured on 19 October 2026 from service v0.17.17. The previous capture, from April 2026, came from Heratio and had drifted from the live record (its title was "Demo of folder1", and it still carried `openricx:description`).

Intended to show a record with titles in more than one language, exercising language negotiation and the `rdf:langString` branches of the record schema. **It does not yet do so.** The reference service returns each record in its source culture as plain strings, so a capture from it carries no `@language` tags. Until a server returns language-tagged titles, `fonds-minimal` is the fixture that exercises `@language`.

**Validation:** `expected.jsonld` MUST validate against the schema selected by its `@type`.
