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
