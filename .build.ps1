
<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)

.Description
	HOW TO USE THIS SCRIPT AND BUILD THE MODULE

	Get the utility script Invoke-Build.ps1:
	https://github.com/nightroman/Invoke-Build

	Copy it to the path. Set location to here. Build:
	PS> Invoke-Build Build
#>

param(
	$Configuration = 'Release',
	$TargetFrameworkVersion = 'v2.0'
)

$ModuleName = 'Xmlips'

# Module directory.
$ModuleRoot = Join-Path ([Environment]::GetFolderPath('MyDocuments')) WindowsPowerShell\Modules\$ModuleName

# Get version from release notes.
function Get-Version {
	switch -Regex -File Release-Notes.md {'##\s+v(\d+\.\d+\.\d+)' {return $Matches[1]} }
}

# Synopsis: Generate or update meta files.
task Meta -Inputs Release-Notes.md -Outputs Module\$ModuleName.psd1, Src\AssemblyInfo.cs {
	$Version = Get-Version
	$Project = 'https://github.com/nightroman/Xmlips'
	$Summary = 'Xmlips - XML in PowerShell'
	$Copyright = 'Copyright (c) Roman Kuzmin'

	Set-Content Module\$ModuleName.psd1 @"
@{
	Author = 'Roman Kuzmin'
	ModuleVersion = '$Version'
	Description = '$Summary'
	CompanyName = '$Project'
	Copyright = '$Copyright'

	ModuleToProcess = '$ModuleName.dll'

	PowerShellVersion = '2.0'
	GUID = 'bc86e123-c8c7-4d69-bbef-fc4d068b6c05'
}
"@

	Set-Content Src\AssemblyInfo.cs @"
using System;
using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyProduct("$ModuleName")]
[assembly: AssemblyVersion("$Version")]
[assembly: AssemblyTitle("$Summary")]
[assembly: AssemblyCompany("$Project")]
[assembly: AssemblyCopyright("$Copyright")]

[assembly: ComVisible(false)]
[assembly: CLSCompliant(false)]
"@
}

# Synopsis: Build and trigger PostBuild.
task Build Meta, {
	use * MSBuild.exe
	exec { MSBuild.exe Src\$ModuleName.csproj /t:Build /p:Configuration=$Configuration /p:TargetFrameworkVersion=$TargetFrameworkVersion }
}

# Synopsis: Copy files to the module root.
# It is called from the post build event.
task PostBuild {
	exec { robocopy Module $ModuleRoot /s /np /r:0 /xf *-Help.ps1 } (0..3)
	Copy-Item Src\Bin\$Configuration\$ModuleName.dll $ModuleRoot
}

# Synopsis: Remove temp files.
task Clean {
	remove Module\$ModuleName.psd1, "$ModuleName.*.nupkg", z, Src\bin, Src\obj, README.htm, Release-Notes.htm
}

# Synopsis: Build and test help by https://github.com/nightroman/Helps
task Help {
	. Helps.ps1
	Test-Helps Module\en-US\$ModuleName.dll-Help.ps1
	Convert-Helps Module\en-US\$ModuleName.dll-Help.ps1 $ModuleRoot\en-US\$ModuleName.dll-Help.xml
}

# Synopsis: Convert markdown files to HTML.
# <http://johnmacfarlane.net/pandoc/>
task Markdown {
	function Convert-Markdown($Name) {pandoc.exe --standalone --from=gfm "--output=$Name.htm" "--metadata=pagetitle=$Name" "$Name.md"}
	exec { Convert-Markdown README }
	exec { Convert-Markdown Release-Notes }
}

# Synopsis: Set $script:Version.
task Version {
	($script:Version = Get-Version)
	# module version
	assert ((Get-Module $ModuleName -ListAvailable).Version -eq ([Version]$script:Version))
	# assembly version
	assert ((Get-Item $ModuleRoot\$ModuleName.dll).VersionInfo.FileVersion -eq ([Version]"$script:Version.0"))
}

# Synopsis: Make the package in z\tools.
task Package Markdown, {
	remove z
	$null = mkdir z\tools\$ModuleName\en-US

	Copy-Item -Destination z\tools\$ModuleName `
	LICENSE.txt,
	README.htm,
	Release-Notes.htm,
	$ModuleRoot\$ModuleName.dll,
	$ModuleRoot\$ModuleName.psd1

	Copy-Item -Destination z\tools\$ModuleName\en-US `
	$ModuleRoot\en-US\about_$ModuleName.help.txt,
	$ModuleRoot\en-US\$ModuleName.dll-Help.xml
}

# Synopsis: Make NuGet package.
task NuGet Package, Version, {
	$summary = @'
The module provides cmdlets for basic operations on XML in PowerShell v2.0 or newer.
'@
	$description = @"
$summary

---

To install Xmlips, follow the Get and Install steps:
https://github.com/nightroman/Xmlips#get-and-install

---
"@
	# nuspec
	Set-Content z\Package.nuspec @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
	<metadata>
		<id>$ModuleName</id>
		<version>$Version</version>
		<owners>Roman Kuzmin</owners>
		<authors>Roman Kuzmin</authors>
		<requireLicenseAcceptance>false</requireLicenseAcceptance>
		<licenseUrl>http://www.apache.org/licenses/LICENSE-2.0</licenseUrl>
		<projectUrl>https://github.com/nightroman/Xmlips</projectUrl>
		<summary>$summary</summary>
		<description>$description</description>
		<tags>PowerShell Module XML XPath</tags>
		<releaseNotes>https://github.com/nightroman/Xmlips/blob/master/Release-Notes.md</releaseNotes>
	</metadata>
</package>
"@
	# pack
	exec { NuGet pack z\Package.nuspec -NoPackageAnalysis }
}

# Synopsis: Push to the repository with a version tag.
task PushRelease Version, {
	$changes = exec { git status --short }
	assert (!$changes) "Please, commit changes."

	exec { git push }
	exec { git tag -a "v$Version" -m "v$Version" }
	exec { git push origin "v$Version" }
}

# Synopsis: Make and push the NuGet package.
task PushNuGet NuGet, {
	exec { NuGet push "$ModuleName.$Version.nupkg" -Source nuget.org }
},
Clean

# Synopsis: Test PowerShell v2.
task Test2 {
	exec {PowerShell.exe -Version 2 Invoke-Build ** Tests}
}

# Synopsis: Test current PowerShell.
task Test {
	Invoke-Build ** Tests
}

# Synopsis: Build, test and clean all.
task . Build, Test, Test2, Help, Clean
