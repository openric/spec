"""HTTP fetching with JSON-LD content negotiation."""

from __future__ import annotations

import json
from typing import Any

import requests


class ServerUnreachable(Exception):
    """Raised when a target URL cannot be reached or returns non-success."""


def fetch_json(url: str, timeout: int = 15) -> dict[str, Any]:
    """GET a URL expecting application/ld+json or application/json."""
    try:
        resp = requests.get(
            url,
            headers={"Accept": "application/ld+json, application/json;q=0.9"},
            timeout=timeout,
        )
    except requests.exceptions.RequestException as e:
        raise ServerUnreachable(f"Cannot reach {url}: {e}") from e

    if resp.status_code >= 400:
        raise ServerUnreachable(f"{url} returned HTTP {resp.status_code}")

    try:
        return resp.json()
    except json.JSONDecodeError as e:
        raise ServerUnreachable(f"{url} did not return valid JSON: {e}") from e
