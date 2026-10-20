# Fixture: `instantiation-tiff`

**Source:** [`https://heratio.theahg.co.za/api/ric/v1/instantiations/910871`](https://heratio.theahg.co.za/api/ric/v1/instantiations/910871)

A TIFF digital-object Instantiation with MIME, carrier type, extent in bytes, back-link to parent Record. Exercises: full Instantiation schema coverage.

**Validation:** `expected.jsonld` MUST validate against the schema selected by its `@type`.

**Edited in v0.54.0:** the extent follows mapping 7.1 and Digital Object Linkage 3.1. A record extent is a `rico:RecordResourceExtent` with its text on `rico:textualValue`; a counted extent is a `rico:InstantiationExtent` with `rico:quantity` and `rico:hasUnitOfMeasurement`. The capture had a literal on `rico:hasExtentType`, an object property in RiC-O 1.1.
