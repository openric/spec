#!/usr/bin/env python3
#
# Copyright (C) 2026 Johan Pieterse
# Plain Sailing Information Systems
# Email: johan@plainsailingisystems.co.za
#
# This file is part of OpenRiC. Licensed under AGPL-3.0-or-later.
#
"""A minimal OpenRiC server: the Core Discovery profile in one file.

Standard library only - no framework, no database, no Heratio. It holds a
small invented fonds in memory and serves it at the ten Core Discovery
endpoints, so an implementer can see the whole contract working before
writing their own. It is an example, not a product.

It also takes writes, so the getting-started guide has somewhere safe to
create, change and delete things: POST, PATCH and DELETE on /records and
/agents, with an X-API-Key. Writes live in memory and are gone when the server
stops. This small write surface is for learning; it is not a Round-Trip
Editing implementation, and the server does not claim that profile.

    python3 server.py                     # http://localhost:8080
    PORT=9000 python3 server.py
    BASE_IRI=https://archive.example.org python3 server.py
    WRITE_KEY=my-secret python3 server.py # the key writes need (default: example-write-key)

Then test it with the conformance probe:

    BASE=http://localhost:8080 bash conformance/probe.sh --profile=core-discovery
"""

import json
import os
import pathlib
import re
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

PORT = int(os.environ.get("PORT", "8080"))
BASE_IRI = os.environ.get("BASE_IRI", f"http://localhost:{PORT}").rstrip("/")
WRITE_KEY = os.environ.get("WRITE_KEY", "example-write-key")
_VERSION_FILE = pathlib.Path(__file__).resolve().parents[2] / "version.json"
SPEC_VERSION = os.environ.get("SPEC_VERSION") or (
    json.loads(_VERSION_FILE.read_text())["version"] if _VERSION_FILE.exists() else "unknown")

RICO = "https://www.ica.org/standards/RiC/ontology#"
CONTEXT = {"rico": RICO, "openric": "https://openric.org/ns/v1#",
           "openricx": "https://openric.org/ns/ext/v1#",
           "rdfs": "http://www.w3.org/2000/01/rdf-schema#"}


def iri(kind, key):
    return f"{BASE_IRI}/{kind}/{key}"


def text(value, lang="en"):
    return {"@value": value, "@language": lang}


# ---- the data: one invented fonds, held by one invented repository ----------
# Everything here is synthetic. The names say so.

REPOSITORIES = {
    "example-archive": {
        "@type": "rico:CorporateBody",
        "rico:name": text("Example County Archive (OpenRiC example data)"),
        "rico:history": text("A fictional repository used by the minimal OpenRiC server."),
    },
}

AGENTS = {
    "marsh-family": {
        "@type": "rico:Family",
        "rico:name": text("Marsh family (OpenRiC example data)"),
    },
    "eleanor-marsh": {
        "@type": "rico:Person",
        "rico:name": text("Marsh, Eleanor (OpenRiC example data)"),
    },
}

RECORDS = {
    "marsh-papers": {
        "@type": "rico:RecordSet",
        "rico:identifier": "EX-1",
        "rico:title": text("Marsh family papers (OpenRiC example data)"),
        "creator": "marsh-family",
        "holder": "example-archive",
        "parts": ["marsh-letter-1", "marsh-diary-1"],
    },
    "marsh-letter-1": {
        "@type": "rico:Record",
        "rico:identifier": "EX-1/1",
        "rico:title": text("Letter from Eleanor Marsh to her brother (OpenRiC example data)"),
        "creator": "eleanor-marsh",
        "holder": "example-archive",
        "part_of": "marsh-papers",
    },
    "marsh-diary-1": {
        "@type": "rico:Record",
        "rico:identifier": "EX-1/2",
        "rico:title": text("Diary of Eleanor Marsh (OpenRiC example data)"),
        "creator": "eleanor-marsh",
        "holder": "example-archive",
        "part_of": "marsh-papers",
    },
}


def ref(kind, key, store, label_field):
    item = store[key]
    return {"@id": iri(kind, key), "@type": item["@type"], label_field: item[label_field]}


def record_doc(key):
    r = RECORDS[key]
    doc = {
        "@context": CONTEXT,
        "@id": iri("records", key),
        "@type": r["@type"],
        "rico:identifier": r["rico:identifier"],
        "rico:title": r["rico:title"],
        "rico:hasOrHadHolder": ref("repositories", r["holder"], REPOSITORIES, "rico:name"),
    }
    if r.get("creator") in AGENTS:
        doc["rico:hasCreator"] = [ref("agents", r["creator"], AGENTS, "rico:name")]
    if "rico:scopeAndContent" in r:
        doc["rico:scopeAndContent"] = r["rico:scopeAndContent"]
    if "part_of" in r:
        doc["rico:isOrWasIncludedIn"] = {"@id": iri("records", r["part_of"]), "@type": "rico:RecordSet"}
    if "parts" in r:
        doc["rico:includesOrIncluded"] = [{"@id": iri("records", p), "@type": "rico:Record"} for p in r["parts"]]
    return doc


def agent_doc(key):
    return {"@context": CONTEXT, "@id": iri("agents", key), **AGENTS[key]}


def repository_doc(key):
    held = [{"@id": iri("records", k), "@type": r["@type"]} for k, r in RECORDS.items() if r["holder"] == key]
    return {"@context": CONTEXT, "@id": iri("repositories", key), **REPOSITORIES[key], "rico:isOrWasHolderOf": held}


def list_doc(list_type, kind, store, label_field, query):
    limit = max(1, min(int(query.get("limit", ["50"])[0]), 200))
    page = max(1, int(query.get("page", ["1"])[0]))
    keys = sorted(store)
    chunk = keys[(page - 1) * limit: page * limit]
    return {
        "@context": CONTEXT,
        "@type": list_type,
        "openric:total": len(keys),
        "openric:page": page,
        "openric:limit": limit,
        "openric:items": [ref(kind, k, store, label_field) for k in chunk],
    }


def service_description():
    return {
        "name": "OpenRiC minimal server (example)",
        "version": "1.0.0",
        "description": "Standard-library example implementing the Core Discovery profile, with a small in-memory write surface for learning. Synthetic data.",
        "openric_conformance": {
            "spec_version": SPEC_VERSION,
            "profiles": [{"id": "core-discovery", "version": "0.6.0", "conformance": "full"}],
        },
    }


VOCABULARY = {
    "@context": CONTEXT,
    "@type": "openric:Vocabulary",
    "classes": [{"@id": f"rico:{c}", "rdfs:label": c} for c in ("Record", "RecordSet", "Person", "Family", "CorporateBody")],
    "predicates": [{"@id": f"rico:{p}"} for p in ("hasCreator", "hasOrHadHolder", "isOrWasIncludedIn", "includesOrIncluded")],
}


def autocomplete(query):
    q = query.get("q", [""])[0].lower()
    limit = max(1, min(int(query.get("limit", ["10"])[0]), 200))
    hits = []
    for store, field in ((RECORDS, "rico:title"), (AGENTS, "rico:name")):
        for key, item in store.items():
            label = item[field]["@value"]
            if q in label.lower():
                hits.append({"id": key, "label": label, "type": item["@type"]})
    return hits[:limit]


# ---- writes: in memory, for the getting-started guide ------------------------

_next_id = [1001]


def problem(status, title, detail):
    slug = title.lower().replace(" ", "-")
    return status, {"type": f"https://openric.org/errors/{slug}", "title": title, "status": status, "detail": detail}


def slugify(value):
    return re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-") or "item"


def write(method, kind, key, body):
    """Return (status, body) for a write. kind is records or agents."""
    store, field = (RECORDS, "title") if kind == "records" else (AGENTS, "name")
    label = "rico:title" if kind == "records" else "rico:name"
    if method == "POST":
        if not str(body.get(field, "")).strip():
            return problem(422, "Validation Failed", f"The {field} field is required.")
        new = str(_next_id[0])
        _next_id[0] += 1
        if kind == "records":
            item = {"@type": "rico:Record", "rico:identifier": f"EX-{new}", "rico:title": text(body["title"]),
                    "holder": "example-archive"}
            if body.get("creator") in AGENTS:
                item["creator"] = body["creator"]
            if body.get("scope_and_content"):
                item["rico:scopeAndContent"] = text(body["scope_and_content"])
        else:
            item = {"@type": "rico:Person", "rico:name": text(body["name"])}
        store[new] = item
        return 201, {"id": int(new), "slug": slugify(body[field]), "type": kind[:-1], "href": f"/{kind}/{new}"}
    if key not in store:
        return problem(404, "Not Found", f"No {kind[:-1]} {key}.")
    if method == "PATCH":
        if field in body:
            if not str(body[field]).strip():
                return problem(422, "Validation Failed", f"The {field} field cannot be empty.")
            store[key][label] = text(body[field])
        if kind == "records" and body.get("scope_and_content"):
            store[key]["rico:scopeAndContent"] = text(body["scope_and_content"])
        return 200, {"success": True, "id": int(key) if key.isdigit() else None}
    # DELETE
    if kind == "records" and store[key].get("parts"):
        return problem(409, "Conflict", "This record has parts; delete them first.")
    if kind == "agents" and any(r.get("creator") == key for r in RECORDS.values()):
        return problem(409, "Conflict", "Records name this agent as their creator.")
    del store[key]
    return 200, {"success": True, "id": int(key) if key.isdigit() else None}


ROUTES = {
    "records": (RECORDS, record_doc, "openricx:RecordList", "rico:title"),
    "agents": (AGENTS, agent_doc, "openricx:AgentList", "rico:name"),
    "repositories": (REPOSITORIES, repository_doc, "openricx:RepositoryList", "rico:name"),
}


class Handler(BaseHTTPRequestHandler):
    server_version = "OpenRiC-minimal/1.0"

    def send_json(self, status, body):
        data = json.dumps(body, ensure_ascii=False, indent=2).encode("utf-8")
        self.send_response(status)
        kind = "application/problem+json" if status >= 400 else "application/ld+json"
        self.send_header("Content-Type", f"{kind}; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        url = urlparse(self.path)
        query = parse_qs(url.query)
        parts = [p for p in url.path.split("/") if p]
        try:
            if not parts:
                return self.send_json(200, service_description())
            if parts == ["health"]:
                return self.send_json(200, {"status": "ok"})
            if parts == ["vocabulary"]:
                return self.send_json(200, VOCABULARY)
            if parts == ["autocomplete"]:
                return self.send_json(200, autocomplete(query))
            if parts[0] in ROUTES and len(parts) <= 2:
                store, doc, list_type, label = ROUTES[parts[0]]
                if len(parts) == 1:
                    return self.send_json(200, list_doc(list_type, parts[0], store, label, query))
                if parts[1] in store:
                    return self.send_json(200, doc(parts[1]))
        except ValueError:
            return self.send_json(*problem(400, "Bad Request", "Bad query parameter."))
        return self.send_json(*problem(404, "Not Found", "Nothing at this path."))

    def handle_write(self, method):
        parts = [p for p in urlparse(self.path).path.split("/") if p]
        if not parts or parts[0] not in ("records", "agents") or len(parts) != (1 if method == "POST" else 2):
            return self.send_json(*problem(405, "Method Not Allowed", "Writes are accepted on /records and /agents only."))
        if self.headers.get("X-API-Key") != WRITE_KEY:
            return self.send_json(*problem(401, "Unauthorized", "Writes need the X-API-Key the server was started with."))
        body = {}
        if method != "DELETE":
            try:
                length = int(self.headers.get("Content-Length") or 0)
                body = json.loads(self.rfile.read(length) or b"{}")
            except ValueError:
                return self.send_json(*problem(400, "Bad Request", "The body is not JSON."))
            if not isinstance(body, dict):
                return self.send_json(*problem(400, "Bad Request", "The body must be a JSON object."))
        return self.send_json(*write(method, parts[0], parts[1] if len(parts) > 1 else None, body))

    def do_POST(self):
        self.handle_write("POST")

    def do_PATCH(self):
        self.handle_write("PATCH")

    def do_DELETE(self):
        self.handle_write("DELETE")

    def log_message(self, format, *args):  # noqa: A002 - matches the base signature
        pass  # quiet; a real server would log


if __name__ == "__main__":
    print(f"OpenRiC minimal server on http://localhost:{PORT}  (identifiers under {BASE_IRI})")
    ThreadingHTTPServer(("", PORT), Handler).serve_forever()
