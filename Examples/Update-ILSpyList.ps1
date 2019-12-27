<#
.Synopsis
	Updates the specified ILSpy assembly list.

.Description
	The cmdlet creates or updates the specified assembly list in the ILSpy
	configuration file. Assemblies are dll and exe files in the specified
	directory. If the new list is the same then the file is not changed.

.Parameter ListName
		Specifies the list name.

.Parameter Directory
		Specifies the directory with assemblies.

.Parameter Force
		Tells to include all dll files. By default, lower case dll files are
		not included, they are supposed to be net core runtime.
#>

[CmdletBinding()] param(
	[Parameter(Mandatory=1)]
	[string]$ListName,
	[Parameter(Mandatory=2)]
	[string]$Directory,
	[switch]$Force
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
foreach ($item in (Get-ChildItem -LiteralPath $Directory)) {
	# skip not dll or exe
	if ($item.Name -notmatch '\.(dll|exe)$') {continue}

	# skip lower case dll, presumably runtime
	if (!$Force -and $item.Name -like '*.dll' -and $item.Name -ceq $item.Name.ToLower()) {continue}

	# add the file
	Add-Xml Assembly $list2 | Set-Xml $item.FullName
}
Copy-Xml $list2 $list1

Save-Xml $xml
