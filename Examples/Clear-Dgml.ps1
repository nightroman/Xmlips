
<#
.Synopsis
	Clears the specified DGML file.

.Description
	The command restores the default DGML graph layout by removing designer
	generated attributes and reduces the file size. Not changed DGML is not
	saved.

.Parameter Path
		The DGML file path.
#>

param(
	[Parameter(Mandatory=1)]
	[string]$Path
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
$ErrorActionPreference = 1

# read
Import-Module Xmlips
$xml = Read-Xml $Path

# remove designer attributes Bounds, UseManualLocation, and Label=Id
$xml | Get-Xml '//@Bounds | //@UseManualLocation | //*[@Id = @Label]/@Label' | Remove-Xml

# save
Save-Xml $xml
