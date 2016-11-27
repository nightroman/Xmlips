
<#
.Synopsis
	Updates the specified ILSpy assembly list.

.Description
	The cmdlet creates or updates the specified assembly list in the ILSpy
	configuration file. Assemblies are DLL files in the specified directory.
	If the new list is the same then the file is not written.

.Parameter ListName
		Specifies the list name.
.Parameter Directory
		Specifies the directory with assemblies.
#>

[CmdletBinding()] param(
	[Parameter(Mandatory=1)]
	[string]$ListName,
	[Parameter(Mandatory=2)]
	[string]$Directory
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
$ErrorActionPreference = 'Stop'

$Directory = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Directory)
if (![System.IO.Directory]::Exists($Directory)) {throw "Missing directory '$Directory'."}

$XmlPath = "$env:APPDATA\ICSharpCode\ILSpy.xml"
if (![System.IO.File]::Exists($XmlPath)) {throw "Missing expected '$XmlPath'."}

Import-Module Xmlips

$xml = Read-Xml $XmlPath
$lists = Get-Xml AssemblyLists $xml
$list1 = Find-Xml List name $ListName $lists

$list2 = New-Xml
foreach ($item in Get-ChildItem -LiteralPath $Directory -Filter *.dll) {
	Add-Xml Assembly $list2 | Set-Xml $item.FullName
}
Copy-Xml $list2 $list1

Save-Xml $xml
