
Xmlips - XML in PowerShell
==========================

The module provides cmdlets for basic operations on XML.

#### Read-Xml

It reads an XML document from a file. The returned document watches for
changes. Its method Save() saves XML to the source file if the document
is changed. It optionally creates a backup copy or the original file.

#### Get-Xml

It is similar to the built-in Select-Xml. Main differences:

- input is nodes, paths are not supported
- output is nodes or PSObject, not node info
- it supports variables in XPath expressions
- it supports Property to get data as PSObject

#### Find-Xml

It gets a single element specified by its name, key attribute name, and
unique value. If the element is not found then it is created with the
specified key attribute value.

#### Add-Xml

It creates and adds a new element to the specified.

#### Set-Xml

It sets the specified attribute values.

#### Remove-Xml

It removes the specified nodes.

#### Export-Xml

It exports elements as fragments.

#### Import-Xml

It reads elements as fragments.

****
## Get and Install

Xmlips is distributed as the NuGet package [Xmlips](https://www.nuget.org/packages/Xmlips).
Download it to the current location as the directory *"Xmlips"* by this PowerShell command:

    iex (New-Object Net.WebClient).DownloadString('https://raw.github.com/nightroman/Xmlips/master/Download.ps1')

Alternatively, download it by NuGet tools or [directly](http://nuget.org/api/v2/package/Xmlips).
In the latter case rename the package to *".zip"* and unzip. Use the package
subdirectory *"tools/Xmlips"*.

Copy the directory *Xmlips* to a PowerShell module directory, see
`$env:PSModulePath`, normally like this:

    C:/Users/<User>/Documents/WindowsPowerShell/Modules/Xmlips
