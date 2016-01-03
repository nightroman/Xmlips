
# Xmlips Release Notes

## v0.2.0

`Read-Xml` returns the root element instead of the document. Typical use cases
show that this makes coding easier. Saving is done by the new cmdlet `Save-Xml`.
The document, if needed, is available as the property `OwnerDocument`.

## v0.1.1

`Get-Xml`

- Fixed null result issues with `-Single`.
- Improved errors on using undefined prefixes in XPath.

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
