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

"""Allow `python -m openric_validate` to work as an entrypoint."""

from .cli import main

if __name__ == "__main__":
    raise SystemExit(main())
