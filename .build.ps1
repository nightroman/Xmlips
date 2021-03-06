<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
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

# Synopsis: Generate meta files.
task Meta @{
	Inputs = $BuildFile, 'Release-Notes.md'
	Outputs = "Module\$ModuleName.psd1", 'Src\AssemblyInfo.cs'
	Jobs = {
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

	PrivateData = @{
		PSData = @{
			Tags = 'XML', 'XPath'
			ProjectUri = 'https://github.com/nightroman/Xmlips'
			LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'
			ReleaseNotes = 'https://github.com/nightroman/Xmlips/blob/master/Release-Notes.md'
		}
	}
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
}

# Synopsis: Build and publish.
task Build Meta, {
	$MSBuild = Resolve-MSBuild
	exec { & $MSBuild Src\$ModuleName.csproj /t:Build /p:Configuration=$Configuration /p:TargetFrameworkVersion=$TargetFrameworkVersion }
},
Help

# Synopsis: Copy files to the module root.
# It is called from the post build event.
task Publish {
	exec { robocopy Module $ModuleRoot /s /np /r:0 /xf *-Help.ps1 } (0..3)
	Copy-Item Src\Bin\$Configuration\$ModuleName.dll $ModuleRoot
}

# Synopsis: Remove temp files.
task Clean {
	remove z, Src\bin, Src\obj, README.htm, *.nupkg
}

# Synopsis: Build and test help by https://github.com/nightroman/Helps
task Help {
	. Helps.ps1
	Test-Helps Module\en-US\$ModuleName.dll-Help.ps1
	Convert-Helps Module\en-US\$ModuleName.dll-Help.ps1 $ModuleRoot\en-US\$ModuleName.dll-Help.xml
}

# Synopsis: Convert markdown to HTML.
task Markdown {
	exec { pandoc.exe README.md --output=README.htm --from=gfm --standalone --metadata=pagetitle:README }
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

	Copy-Item -Destination z\tools\$ModuleName $(
		'LICENSE.txt'
		'README.htm'
		"$ModuleRoot\$ModuleName.dll"
		"$ModuleRoot\$ModuleName.psd1"
	)

	Copy-Item -Destination z\tools\$ModuleName\en-US $(
		"$ModuleRoot\en-US\about_$ModuleName.help.txt"
		"$ModuleRoot\en-US\$ModuleName.dll-Help.xml"
	)
}

# Synopsis: Make NuGet package.
task NuGet Package, Version, {
	$summary = 'Legacy package of the PSGallery module Xmlips.'

	Set-Content z\Package.nuspec @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
	<metadata>
		<id>$ModuleName</id>
		<version>$Version</version>
		<owners>Roman Kuzmin</owners>
		<authors>Roman Kuzmin</authors>
		<license type="expression">Apache-2.0</license>
		<requireLicenseAcceptance>false</requireLicenseAcceptance>
		<projectUrl>https://github.com/nightroman/Xmlips</projectUrl>
		<summary>$summary</summary>
		<description>$summary</description>
		<tags>PowerShell Module XML XPath</tags>
		<releaseNotes>https://github.com/nightroman/Xmlips/blob/master/Release-Notes.md</releaseNotes>
	</metadata>
</package>
"@

	exec { NuGet pack z\Package.nuspec }
}

# Synopsis: Make and push the NuGet package.
task PushNuGet NuGet, {
	exec { NuGet push "$ModuleName.$Version.nupkg" -Source nuget.org }
},
Clean

# Synopsis: Make and push the PSGallery package.
task PushPSGallery Package, Version, {
	$NuGetApiKey = Read-Host NuGetApiKey
	Publish-Module -Path z\tools\$ModuleName -NuGetApiKey $NuGetApiKey
},
Clean

# Synopsis: Push to the repository with a version tag.
task PushRelease Version, {
	$changes = exec { git status --short }
	assert (!$changes) "Please, commit changes."

	exec { git push }
	exec { git tag -a "v$Version" -m "v$Version" }
	exec { git push origin "v$Version" }
}

# Synopsis: Test current PowerShell.
task Test3 {
	Invoke-Build ** Tests
}

# Synopsis: Test PowerShell v2.
task Test2 {
	exec { powershell.exe -Version 2 Invoke-Build Test3 }
}

# Synopsis: Test PowerShell Core.
task Test6 -If $env:powershell6 {
	exec { & $env:powershell6 -Command Invoke-Build Test3 }
}

# Synopsis: Test PowerShell versions.
task Test Test3, Test6, Test2

# Synopsis: Build, test, clean.
task . Build, Test, Clean
