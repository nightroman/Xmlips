
# Xmlips Release Notes

## v0.1.0

New cmdlets `Export-Xml` and `Import-Xml` are designed for XML fragments
persistence and logging in XML with effective appending. Files normally
contain multiple root elements, i.e. not well-formed XML documents.

`Read-Xml`: removed switch `Fragment`, use new cmdlet `Import-Xml`.

`Find-Xml`: improved performance.

## v0.0.2

Consistency of `Xml` parameters. They are all required and accept arrays and
pipeline input. Empty and null arrays are allowed. Null items are not allowed.

`Add-Xml`, `Find-Xml`: renamed `Name` to `Tag`.

## v0.0.1

The first preview.
