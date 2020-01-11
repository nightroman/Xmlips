# Xmlips Release Notes

## v1.0.1

Add details to the PSGallery package.

## v1.0.0

`Read-Xml`

- New parameter `Settings` (`[XmlReaderSettings]`).

## v0.4.1

- Tweak `Get-Xml` output type attribute for better code completion.
- Fix `Remove-Xml` for attributes as input.
- Add *Examples/Clear-Dgml.ps1*.

## v0.4.0

`New-Xml`: new parameters `Tag` and `Attribute`.

## v0.3.0

`Set-Xml`

- `Attribute` specifies attribute name/value pairs and the optional text as the last odd item.
- New switch `Change` tells to set only changed values and do not return data like `Changed` does.

New cmdlets

- `New-Xml` - Creates a new XML element.
- `Copy-Xml` - Copies the inner XML of one element to another.

`Update-ILSpyList.ps1` shows a scenario with two new cmdlets and updated `Set-Xml`.

## v0.2.1

`Add-Xml`: new parameter `Namespace`. Use case: add references or compile items
to a project file. Example: *Examples/Add-ProjectReference.ps1*. Test: task
`Add-ProjectReference` in *Tests/Add-Xml.test.ps1*.

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
