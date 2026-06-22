---
layout: default
title: OpenRiC - Digital Object Linkage Profile
description: rico:Instantiation carriers (files, images, PDFs) and openricx:Function (ISDF) as first-class entities. The profile that connects records to their bitstreams and to the business functions that produced them.
---

# Digital Object Linkage Profile

**Profile id:** `digital-object-linkage`
**Profile version:** 0.6.0
**Spec version:** 0.33.0
**Status:** Normative
**Dependencies:** None at the endpoint level. When combined with Graph Traversal, the `:InstantiationLinkedFromRecordShape` full-graph SHACL shape (defined there) additionally verifies that every Instantiation is referenced by at least one Record.
**Last updated:** 2026-04-21

---

## 1. Purpose

Digital Object Linkage is the profile for **the concrete surfaces records live on** - digital files, images, PDFs, audio, video, and their physical counterparts - plus **the business functions that produced them**. Where Core Discovery answers *what is this record*, this profile answers *where does the bitstream actually sit, and under which organisational function was it created*.

A server implementing this profile commits to three things:

1. **Expose `rico:Instantiation` entities** - one per carrier (file, physical object, copy) - at stable URIs under `/api/ric/v1/instantiations/{id}`. Each Instantiation carries MIME type, carrier type, extent, and a link back to the Record it instantiates via `rico:isOrWasInstantiationOf`.
2. **Expose `openricx:Function` entities** - ISDF-native business functions - at `/api/ric/v1/functions/{id}`. Each Function carries name, classification, and optional history / mandate.
3. **Optionally expose file bytes and thumbnails** - `POST /upload` writes bytes; `GET /thumbnail/{id}` derives display-sized renditions for image Instantiations. These are conveniences for a working catalogue, not strictly required for profile claim.

Digital Object Linkage is **orthogonal to every other profile**. A server may claim it without Core Discovery (a pure object repository), without Authority & Context (files with no places or activities behind them), or without Graph Traversal (no `/graph` endpoint - Instantiations surfaced only via their per-record backlink). Combining with Graph Traversal is what enables store-wide hygiene checks over Instantiation ↔ Record linkage.

## 2. Scope

### 2.1 Required endpoints

A conformant server MUST expose:

| Verb | Path | Returns |
|---|---|---|
| GET | `/api/ric/v1/instantiations` | Instantiation list, paginated |
| GET | `/api/ric/v1/instantiations/{id}` | Single Instantiation as JSON-LD |
| GET | `/api/ric/v1/functions` | Function list, paginated |
| GET | `/api/ric/v1/functions/{id}` | Single Function as JSON-LD |

Pagination rules match Core Discovery §3.3 (default page size 50, max 200, `openric:total`/`openric:page`/`openric:limit`/`openric:items`).

### 2.2 Optional endpoints

| Verb | Path | Purpose |
|---|---|---|
| POST | `/api/ric/v1/upload` | Multipart write of a single file → creates Instantiation + stores bytes. Requires `X-API-Key` with `write` scope. |
| GET | `/api/ric/v1/thumbnail/{id}` | Derivative thumbnail for image Instantiations. First call generates + caches; subsequent calls serve from cache. Public (no auth). Returns the image bytes, not JSON. |

A server MAY additionally expose format-specific derivative endpoints (IIIF image tiles, video transcodes, etc.); anything outside the four required endpoints + the two listed optionals is outside the profile's normative surface.

### 2.3 Forbidden without additional profile claims

- **Write verbs on `/instantiations` / `/functions`** beyond `POST /upload` for creating Instantiations from uploaded files. Full CRUD lives in Round-Trip Editing.
- **Cross-entity graph hygiene checks** (orphaned Instantiations, unlinked Records). Those live in Graph Traversal.
- **Unbounded file-size uploads.** Servers MUST enforce a per-request size cap and return `413 payload-too-large` with the cap in the problem+json body when exceeded.

### 2.4 Content types

- `/instantiations`, `/functions`, and their per-id variants → `application/ld+json`
- `/upload` → accepts `multipart/form-data` with a `file` part; returns `application/json` with the created Instantiation's `id`, `href`, `thumbnail_url` (if applicable), `mime`, `size`, `filename`, `path`
- `/thumbnail/{id}` → returns image bytes with appropriate `Content-Type` (typically `image/webp` or `image/jpeg`), NOT JSON

Error responses MUST be `application/problem+json` per Core Discovery §4.

## 3. Response shapes

### 3.1 Instantiation - `GET /instantiations/{id}`

An Instantiation is a concrete carrier of the information in a Record - a specific file, a specific physical copy. At minimum: `@id`, `@type: "rico:Instantiation"`, `rico:title`, and at least one of `rico:hasCarrierType`, `openricx:hasMimeType`, `rico:hasContentOfType`, or `rico:productionTechnique` (otherwise the Instantiation is a shell with no way to identify what it actually carries - SHACL Violation per §5).

```json
{
  "@context": { "rico": "https://www.ica.org/standards/RiC/ontology#",
                "xsd":  "http://www.w3.org/2001/XMLSchema#" },
  "@id":                "https://example.org/instantiation/910871",
  "@type":              "rico:Instantiation",
  "rico:identifier":    "marble_statue_ultra_high_res.tiff",
  "rico:title":         "marble_statue_ultra_high_res.tiff",
  "openricx:description":   "MIME: image/tiff | Size: 73735.3 KB",
  "openricx:hasMimeType":   "image/tiff",
  "rico:hasCarrierType": "digital",
  "rico:hasExtent": {
    "@type":           "rico:Extent",
    "rico:quantity":   75504986,
    "rico:hasExtentType": "bytes"
  },
  "openricx:technicalCharacteristics": "Checksum (sha256): b4156fc402504b621b0579635162f887ddd131045ee6eaa67c7c4b4a2d4e890f",
  "rico:isOrWasInstantiationOf": {
    "@id":        "https://example.org/informationobject/title-of-object",
    "@type":      "rico:Record",
    "rico:title": "Title of object"
  }
}
```

**Required:** `@id`, `@type: "rico:Instantiation"`, `rico:title`, AND at least one of `rico:hasCarrierType` / `openricx:hasMimeType` / `rico:hasContentOfType` / `rico:productionTechnique`.

**Strongly recommended when present in the backing data:**

| Field | Notes |
|---|---|
| `rico:identifier` | Typically the original filename |
| `openricx:description` | Free-form, often auto-generated from MIME + size |
| `openricx:hasMimeType` | MUST match `^[a-zA-Z0-9!#$&^_.+-]+/[a-zA-Z0-9!#$&^_.+-]+$` per SHACL |
| `rico:hasCarrierType` | `digital`, `physical`, `born-digital`, `analog-converted`, or a local vocabulary value |
| `rico:hasExtent` | Structured `rico:Extent` with `rico:quantity` (integer) + `rico:hasExtentType` (`bytes`, `pages`, `minutes`, etc.) |
| `openricx:technicalCharacteristics` | Free-form string. Checksum convention: `"Checksum (sha256): <hex>"` - structured checksum shape is a v0.7 candidate (see §9 Q2). |
| `rico:isOrWasInstantiationOf` | **STRONGLY RECOMMENDED.** Embedded stub of the Record this Instantiation carries. Without it, the Instantiation is floating (SHACL Warning at Graph Traversal level). |

### 3.2 Function - `GET /functions/{id}`

A Function is an ISDF business function - a recurring organisational activity-class under which records are produced and managed ("Acquisitions Management", "Conservation Treatment", "Permit Administration"). At minimum: `@id`, `@type: "openricx:Function"`, and a name (either `rico:name` shorthand OR `rico:hasOrHadName`).

```json
{
  "@id":                  "https://example.org/function/918002",
  "@type":                "openricx:Function",
  "rico:name":            "Permit Administration",
  "rico:history":         "Established 1984 under Act 117/1983; moved from Ministry of Culture to Supreme Council of Antiquities in 2005.",
  "rico:classification":  "isdf:5.2.1",
  "openric:localType":    "administrative"
}
```

**Required:** `@id`, `@type: "openricx:Function"`, AND one of `rico:name` / `rico:hasOrHadName`.

**Recommended (SHACL Info severity):** `rico:history`, `rico:classification` (ISDF §5.2 code). Functions without either are accepted but carry no actionable semantics.

### 3.3 List envelopes

List responses follow the Core Discovery §3.3 shape:

- `/instantiations` → `openricx:InstantiationList`
- `/functions` → `openricx:FunctionList`

Each envelope wraps `openric:items` as an array of stubs: `@id`, `@type`, `rico:title` (Instantiations) or `rico:name` (Functions), plus `openric:localType` when the server carries one. Full shapes only on single-entity GET.

### 3.4 Upload - `POST /upload` (optional)

```
POST /api/ric/v1/upload HTTP/1.1
Content-Type: multipart/form-data; boundary=…
X-API-Key: …
```

The request body MUST be a `multipart/form-data` with a `file` part. Servers MAY accept additional parts (e.g., `record_id` to pre-link on create, `description` for metadata). On success:

```json
{
  "id":            910871,
  "url":           "https://example.org/uploads/abc123.tiff",
  "thumbnail_url": "https://example.org/api/ric/v1/thumbnail/910871",
  "mime":          "image/tiff",
  "size":          75504986,
  "filename":      "marble_statue_ultra_high_res.tiff",
  "path":          "uploads/2026/04/abc123.tiff"
}
```

**Required on response:** `id`, `url`, `mime`, `size`, `filename`. The `thumbnail_url` MUST be emitted when the upload was an image AND the server supports thumbnails. The `path` field is informational; clients SHOULD NOT parse it.

Error cases:

- Missing `file` part → `400 bad-request` with `code: no_file`
- Upload system-rejected (PHP upload error, etc.) → `422 validation-failed` with `code: invalid_file`
- File exceeds size cap → `413 payload-too-large` with `max_bytes` in the problem+json body

### 3.5 Thumbnail - `GET /thumbnail/{id}` (optional)

Public, cacheable derivative for image Instantiations. The `{id}` is the Instantiation's numeric ID (not the Record's).

- If the Instantiation exists and is an image: returns the thumbnail bytes with `Content-Type: image/webp` (or `image/jpeg` for implementations without WebP). First call generates + caches on disk; subsequent calls serve from cache.
- If the Instantiation doesn't exist: `404 not-found`
- If the source file is missing on disk: `404 not-found` with `code: source_missing`
- If the Instantiation exists but is not an image: `415 unsupported-media-type` with the actual `mime` in the problem+json body

Servers SHOULD emit `Cache-Control: public, max-age=86400` or similar on successful thumbnail responses.

## 4. Error handling

Error responses follow Core Discovery §4 / §4.1 verbatim - `application/problem+json` with the nine registered error-type URIs. This profile uses:

- `404 not-found` - missing Instantiation / Function ID, missing source file for thumbnail
- `400 bad-request` - `POST /upload` without a `file` part
- `413 payload-too-large` - upload exceeds size cap
- `415 unsupported-media-type` - thumbnail requested for a non-image Instantiation
- `422 validation-failed` - upload system-rejected
- `401 authentication-required` - `POST /upload` without a valid `X-API-Key`

No Digital Object Linkage-specific error types are defined.

## 5. SHACL shapes

Digital Object Linkage responses MUST validate against the profile-scoped shape file:

```
shapes/profiles/digital-object-linkage.shacl.ttl
```

| Shape | Target | Severity model |
|---|---|---|
| `:InstantiationShape` | `rico:Instantiation` | `sh:Violation` on missing title; `sh:Warning` on invalid MIME pattern; `sh:Violation` if none of `hasCarrierType` / `hasMimeType` / `hasContentOfType` / `hasProductionTechnique` are present |
| `:FunctionShape` | `openricx:Function` | `sh:Violation` on missing name; `sh:Info` on missing `history` / `classification` |

Shapes are **open** - unknown predicates do not cause failure. The cross-entity check "Instantiation must be linked from a Record via `rico:hasOrHadInstantiation`" lives in `shapes/profiles/graph-traversal.shacl.ttl` (`:InstantiationLinkedFromRecordShape`) because it requires the full triple store to evaluate and produces false positives on single-document API responses.

## 6. Conformance testing

A server claims `digital-object-linkage` when:

1. The four required endpoints from §2.1 return `application/ld+json` with HTTP 200 on happy paths.
2. Every Instantiation response validates against `:InstantiationShape` at `sh:Violation` severity.
3. Every Function response validates against `:FunctionShape` at `sh:Violation` severity.
4. Instantiations that are digital carriers emit a MIME type matching the SHACL pattern.
5. Instantiations emit `rico:isOrWasInstantiationOf` pointing at a real, dereferenceable Record (the cross-entity resolution is SHACL Warning, not Violation, at the per-endpoint level).
6. If `POST /upload` is implemented, the four error cases in §3.4 each return the matching problem+json type URI.
7. If `GET /thumbnail/{id}` is implemented, the three error cases in §3.5 each return the matching problem+json type URI.

Run the conformance probe with `--profile=digital-object-linkage` to exercise only this profile's checks against a live server.

## 7. Fixture pack

The manifest declares these four fixtures as normative for `digital-object-linkage`:

| Fixture | Status | What it pins |
|---|---|---|
| `instantiation-tiff` | done | Digital Instantiation - TIFF carrier with MIME, bytes-extent, sha256 checksum, backlink to Record |
| `instantiation-application` | done | Digital Instantiation - `application/vnd.openxmlformats…` MIME (exercises the SHACL MIME-pattern regex on a compound subtype) |
| `function-with-activities` | planned | ISDF Function with ≥2 linked Activities (cross-tags Authority & Context) |
| `record-in-container` | planned | Record held in a `rico:Thing` container (physical Instantiation cousin) |

Fixtures outside this list are NOT required for profile conformance.

## 8. Implementation checklist

- [ ] Expose the four required endpoints from §2.1
- [ ] Emit `@type: rico:Instantiation` on every instantiation response
- [ ] Emit at least one of `hasCarrierType` / `hasMimeType` / `hasContentOfType` / `hasProductionTechnique` per Instantiation
- [ ] Emit `rico:isOrWasInstantiationOf` pointing at a real Record (stub with `@id` + `@type` + `rico:title`)
- [ ] Validate Instantiation responses against `:InstantiationShape` - 0 Violations
- [ ] Emit `@type: openricx:Function` on every function response
- [ ] Emit a name (`rico:name` or `rico:hasOrHadName`) on every Function
- [ ] Add `digital-object-linkage` to `openric_conformance.profiles` in `GET /`
- [ ] Run the conformance probe with `--profile=digital-object-linkage` - all shipped fixtures pass
- [ ] Emit `/conformance/badge?profile=digital-object-linkage` returning shields.io JSON
- [ ] *(optional)* Implement `POST /upload` - handle all four error paths (`no_file`, `invalid_file`, `too_large`, auth)
- [ ] *(optional)* Implement `GET /thumbnail/{id}` - handle `not_found`, `source_missing`, `not_an_image`

## 9. Design decisions

Five questions were flagged during drafting; all five carry resolutions.

### Q1 - Why `openricx:Function` in "Digital Object Linkage"?

**Resolution**: **Historical grouping, preserved for stability.**

**Rationale**: When the profile matrix was first laid out, `openricx:Function` was grouped with `rico:Instantiation` under "things that qualify records but aren't Agents, Places, or Rules" - both are ISDF/ISAAR-adjacent carriers of organisational context. Splitting Function out into its own profile (or folding it into Authority & Context) would be a cleaner taxonomy today, but the shapes file + manifest have been stable since v0.1, and implementations are already mapping Function under this profile. Treating the grouping as a historical artefact and preserving it is strictly less churn than re-homing Function across two profile cycles. A future v1 review may revisit this.

### Q2 - Checksum as a free-form string vs structured sub-object?

**Resolution**: **Free-form `openricx:technicalCharacteristics` string now; structured `openricx:Checksum` sub-object is a v0.7 candidate.**

**Rationale**: The current convention `"Checksum (sha256): <hex>"` inside `openricx:technicalCharacteristics` is what every reference implementation emits today. It is machine-parseable (single regex) without being overengineered. A structured shape (`{@type: openricx:Checksum, openricx:algorithm: "sha256", openricx:checksumValue: "<hex>"}`) is cleaner for multi-algorithm storage and for PREMIS interop, but there is no current consumer that needs it. Adding the structured shape as OPTIONAL in v0.7 - allowed *alongside* the string form, not replacing it - is the planned path.

### Q3 - Is `/thumbnail/{id}` required or optional?

**Resolution**: **Optional.**

**Rationale**: Thumbnails are an ergonomic layer, not a semantic one. A valid Digital Object Linkage claim can be made by a server that doesn't generate derivatives at all (e.g., a pure archive that serves master files only). Forcing thumbnails would exclude implementations without image-processing toolchains and push them out of conformance for a reason unrelated to the profile's meaning. Servers that *do* implement thumbnails MUST honour the three error paths in §3.5 so clients can depend on them.

### Q4 - `rico:hasCarrierType` - fixed vocabulary or open strings?

**Resolution**: **Open strings, with four conventional values RECOMMENDED.**

**Rationale**: `digital`, `physical`, `born-digital`, `analog-converted` cover the common cases and SHOULD be preferred where they fit. But carrier taxonomies vary wildly by domain (archaeology vs film archive vs born-digital startup), and locking the vocabulary would bake a single discipline's assumptions into the spec. Implementations with a narrower local vocabulary MAY surface it via `openric:localType` alongside the broader `rico:hasCarrierType` - the same pattern as `rico:hasOrHadRuleType` in Authority & Context §3.3.

### Q5 - Upload size cap: spec-enforced minimum, or implementation choice?

**Resolution**: **Implementation choice, with a MUST on the error path.**

**Rationale**: A small-archive server on a $5 VPS has different capacity than a national archive on dedicated storage; spec-mandating any specific cap (100 MB? 2 GB?) would force implementations to either over-provision or artificially lie about the limit. The conformance requirement is behavioural: the server MUST return `413 payload-too-large` with `max_bytes` in the problem+json body when the cap is hit, regardless of what that cap is. Clients can discover the cap either by reading the body of a failed upload or (optionally) by a future `/service-description` extension.
