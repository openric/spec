# Fixture: `instantiation-application`

**Source:** [`https://heratio.theahg.co.za/api/ric/v1/instantiations/910880`](https://heratio.theahg.co.za/api/ric/v1/instantiations/910880)

An Instantiation with application/* MIME type (not image). Exercises: MIME regex coverage.

**Validation:** `expected.jsonld` MUST validate against the schema selected by its `@type`.

**Edited in v0.54.0:** the extent follows mapping 7.1 and Digital Object Linkage 3.1. A record extent is a `rico:RecordResourceExtent` with its text on `rico:textualValue`; a counted extent is a `rico:InstantiationExtent` with `rico:quantity` and `rico:hasUnitOfMeasurement`. The capture had a literal on `rico:hasExtentType`, an object property in RiC-O 1.1.
