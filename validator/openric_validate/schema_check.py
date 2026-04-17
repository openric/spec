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

"""JSON Schema validation (draft 2020-12)."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from jsonschema import Draft202012Validator


@dataclass
class SchemaError:
    message: str
    json_path: str


class SchemaCheckError(Exception):
    """Raised when a document fails its JSON Schema."""

    def __init__(self, errors: list[SchemaError]):
        self.errors = errors
        super().__init__(f"{len(errors)} schema violation(s)")


def validate_against_schema(document: dict[str, Any], schema: dict[str, Any]) -> None:
    """Validate `document` against `schema`. Raise SchemaCheckError on failure."""
    validator = Draft202012Validator(schema)
    errors = sorted(validator.iter_errors(document), key=lambda e: list(e.absolute_path))

    if not errors:
        return

    schema_errors = [
        SchemaError(
            message=e.message,
            json_path="$" + "".join(f"[{p!r}]" if isinstance(p, str) else f"[{p}]"
                                    for p in e.absolute_path),
        )
        for e in errors
    ]
    raise SchemaCheckError(schema_errors)
