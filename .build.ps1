<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build
#>

param(
	$Configuration = 'Release'
)

Set-StrictMode -Version 3
$ModuleName = 'Xmlips'
$ModuleRoot = "$env:ProgramFiles\WindowsPowerShell\Modules\$ModuleName"

# Synopsis: Remove temp files.
task clean {
	remove z, Src\bin, Src\obj, README.htm
}

# Synopsis: Generate meta files.
task meta -Inputs $BuildFile, Release-Notes.md -Outputs "Module\$ModuleName.psd1", Src\Directory.Build.props -Jobs version, {
	$Project = 'https://github.com/nightroman/Xmlips'
	$Summary = 'Xmlips - XML in PowerShell'
	$Copyright = 'Copyright (c) Roman Kuzmin'

	Set-Content "Module\$ModuleName.psd1" @"
@{
	Author = 'Roman Kuzmin'
	ModuleVersion = '$Version'
	Description = '$Summary'
	CompanyName = '$Project'
	Copyright = '$Copyright'

	RootModule = '$ModuleName.dll'

	PowerShellVersion = '5.1'
	GUID = 'bc86e123-c8c7-4d69-bbef-fc4d068b6c05'

	PrivateData = @{
		PSData = @{
			Tags = 'XML', 'XPath'
			ProjectUri = 'https://github.com/nightroman/Xmlips'
			LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'
			ReleaseNotes = 'https://github.com/nightroman/Xmlips/blob/main/Release-Notes.md'
		}
	}
}
"@

	Set-Content Src\Directory.Build.props @"
<Project>
	<PropertyGroup>
		<Company>$Project</Company>
		<Copyright>$Copyright</Copyright>
		<Description>$Summary</Description>
		<Product>$ModuleName</Product>
		<Version>$Version</Version>
		<IncludeSourceRevisionInInformationalVersion>False</IncludeSourceRevisionInInformationalVersion>
	</PropertyGroup>
</Project>
"@
}

# Synopsis: Build, publish in post-build, make help.
task build meta, {
	exec { dotnet build "Src\$ModuleName.csproj" -c $Configuration }
},
?help

# Synopsis: Publish the module (post-build).
task publish {
	exec { robocopy Module $ModuleRoot /s /xf *-Help.ps1 } (0..3)
	exec { dotnet publish Src\$ModuleName.csproj --no-build -c $Configuration -o $ModuleRoot }
	remove $ModuleRoot\System.Management.Automation.dll, $ModuleRoot\*.deps.json
}

# Synopsis: Build help by https://github.com/nightroman/Helps
task help -Inputs @(Get-Item Src\*.cs, "Module\en-US\$ModuleName.dll-Help.ps1") -Outputs "$ModuleRoot\en-US\$ModuleName.dll-Help.xml" {
	. Helps.ps1
	Convert-Helps "Module\en-US\$ModuleName.dll-Help.ps1" $Outputs
}

# Synopsis: Set $script:Version.
task version {
	($script:Version = switch -Regex -File Release-Notes.md {'##\s+v(\d+\.\d+\.\d+)' {$Matches[1]; break}})
}

# Synopsis: Convert markdown to HTML.
task markdown {
	exec { pandoc.exe README.md --output=README.htm --from=gfm --standalone --metadata=pagetitle:README }
}

# Synopsis: Make the package.
task package markdown, version, {
	assert ((Get-Module $ModuleName -ListAvailable).Version -eq ([Version]$Version))
	assert ((Get-Item $ModuleRoot\$ModuleName.dll).VersionInfo.FileVersion -eq ([Version]"$Version.0"))

	remove z
	exec { robocopy $ModuleRoot z\$ModuleName /s /xf *.pdb } (0..3)

	Copy-Item LICENSE -Destination z\$ModuleName
	Move-Item README.htm -Destination z\$ModuleName

	$r = (Get-ChildItem z\$ModuleName -File -Force -Recurse -Name) -join '*'
	equals $r LICENSE*README.htm*Xmlips.dll*Xmlips.psd1*en-US\about_Xmlips.help.txt*en-US\Xmlips.dll-Help.xml
}

# Synopsis: Make and push the PSGallery package.
task pushPSGallery package, {
	$NuGetApiKey = Read-Host NuGetApiKey
	Publish-Module -Path z\$ModuleName -NuGetApiKey $NuGetApiKey
},
clean

# Synopsis: Push to the repository with a version tag.
task pushRelease version, {
	$changes = exec { git status --short }
	assert (!$changes) "Please, commit changes."

	exec { git push }
	exec { git tag -a "v$Version" -m "v$Version" }
	exec { git push origin "v$Version" }
}

task test_core {
	exec { pwsh -NoProfile -Command Invoke-Build test }
}

task test_desktop {
	exec { powershell -NoProfile -Command Invoke-Build test }
}

# Synopsis: Test PowerShell editions.
task tests test_core, test_desktop

# Synopsis: Test current PowerShell.
task test {
	Invoke-Build ** Tests
}

# Synopsis: Build and clean.
task . build, clean
