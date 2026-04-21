# Fixture — oai-identify

**Profile:** `export-only`
**Endpoint:** `GET /api/ric/v1/oai?verb=Identify`
**Protocol:** [OAI-PMH v2.0](https://www.openarchives.org/OAI/openarchivesprotocol.html#Identify)
**Content-Type:** `text/xml; charset=utf-8`

Canonical `Identify` verb response. Six `Identify` child elements are REQUIRED by OAI-PMH v2.0 and MUST all be present:

- `repositoryName` — human-readable server name
- `baseURL` — the `/oai` endpoint URL (echoed back, used by harvesters to dedupe)
- `protocolVersion` — MUST be `2.0`
- `adminEmail` — at least one; multiple allowed
- `earliestDatestamp` — oldest record timestamp in the repository (for incremental-harvest `from` bounds)
- `deletedRecord` — one of `no`, `persistent`, `transient`
- `granularity` — either `YYYY-MM-DD` or `YYYY-MM-DDThh:mm:ssZ`; the reference server uses the finer grain

The `<description>` block with `<oai-identifier>` is OPTIONAL per OAI-PMH but STRONGLY RECOMMENDED for OpenRiC servers — it advertises the URI scheme harvesters should expect in record identifiers.
