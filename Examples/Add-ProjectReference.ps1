
<#
.Synopsis
	Adds a reference to a project.

.Description
	The command adds the specified missing reference to the project file.
	Although Save-Xml is called in the end, the project is not touched if the
	reference already exists. This cmdlet does not write not changed documents.

.Parameter Project
		The project file path.
.Parameter Value
		The reference value, i.e. the content of attribute Include.
#>

param(
	[Parameter(Mandatory=1)]
	[string]$Project,
	[Parameter(Mandatory=1)]
	[string]$Value
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$default = 'http://schemas.microsoft.com/developer/msbuild/2003'
$namespace = @{x = $default}

# read
Import-Module Xmlips
$xml = Read-Xml $Project

# find element with references, add missing
$ItemGroup = Get-Xml 'x:ItemGroup[x:Reference]' $xml -Namespace $namespace
if (!$ItemGroup) {$ItemGroup = Add-Xml ItemGroup $xml -Namespace $default}

# try to find existing reference, add missing
if (!(Get-Xml 'x:Reference[@Include = $Value]' $ItemGroup -Namespace $namespace)) {
	Add-Xml Reference $ItemGroup -Namespace $default | Set-Xml Include, $Value
}

# save
Save-Xml $xml
