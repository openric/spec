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
writing their own. It is read-only, and it is an example, not a product.

    python3 server.py                     # http://localhost:8080
    PORT=9000 python3 server.py
    BASE_IRI=https://archive.example.org python3 server.py

Then test it with the conformance probe:

    BASE=http://localhost:8080 bash conformance/probe.sh --profile=core-discovery
"""

import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

PORT = int(os.environ.get("PORT", "8080"))
BASE_IRI = os.environ.get("BASE_IRI", f"http://localhost:{PORT}").rstrip("/")

RICO = "https://www.ica.org/standards/RiC/ontology#"
CONTEXT = {"rico": RICO, "openricx": "https://openric.org/ns/ext/v1#",
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
        "rico:hasCreator": [ref("agents", r["creator"], AGENTS, "rico:name")],
        "rico:hasOrHadHolder": ref("repositories", r["holder"], REPOSITORIES, "rico:name"),
    }
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
        "description": "Standard-library example implementing the Core Discovery profile. Read-only, synthetic data.",
        "openric_conformance": {
            "spec_version": os.environ.get("SPEC_VERSION", "0.43.14"),
            "profiles": [{"id": "core-discovery", "version": "0.3.0", "conformance": "full"}],
        },
    }


VOCABULARY = {
    "@context": CONTEXT,
    "@type": "ric:Vocabulary",
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
        self.send_header("Content-Type", "application/ld+json; charset=utf-8")
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
            return self.send_json(400, {"error": "Bad query parameter."})
        return self.send_json(404, {"error": "Not found."})

    def log_message(self, format, *args):  # noqa: A002 - matches the base signature
        pass  # quiet; a real server would log


if __name__ == "__main__":
    print(f"OpenRiC minimal server on http://localhost:{PORT}  (identifiers under {BASE_IRI})")
    ThreadingHTTPServer(("", PORT), Handler).serve_forever()
