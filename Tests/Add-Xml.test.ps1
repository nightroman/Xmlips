
$Version = $PSVersionTable.PSVersion.Major
Import-Module Xmlips

task BadTag {
	($r = try {Add-Xml} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.AddXmlCommand'
	if ($Version -ge 7) {
		equals "$r" "Value cannot be null. (Parameter 'Tag')"
	}
	else {
		assert ($r -clike '*: Tag')
	}

	($r = try {Add-Xml ''} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.AddXmlCommand'
	if ($Version -ge 7) {
		equals "$r" "Value cannot be null. (Parameter 'Tag')"
	}
	else {
		assert ($r -clike '*: Tag')
	}
}

task BadXml {
	($r = try {Add-Xml e} catch {$_})
	equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.AddXmlCommand'
	equals "$r" 'Xml is required.'

	($r = try {Add-Xml e @($null)} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.AddXmlCommand'
	if ($Version -ge 7) {
		equals "$r" "Value cannot be null. (Parameter 'Xml (item)')"
	}
	else {
		assert ($r -clike '*: Xml (item)')
	}
}

task NoXml {
	$r = $(
		Add-Xml e @()
		Add-Xml e $null
		@() | Add-Xml e
		$null | Add-Xml e
	)
	equals $r
}

task Add {
	$xml = [xml]'<r/>'
	$r = Add-Xml e $xml.DocumentElement
	equals $r.OuterXml '<e />'
	equals $xml.InnerXml '<r><e /></r>'
}

task NamespacePrefix {
	$xml = [xml]'<r xmlns:my="my-namespace"/>'
	$r = Add-Xml my:e $xml.DocumentElement -Namespace my-namespace
	Set-Xml a, 1 $r
	equals $xml.InnerXml '<r xmlns:my="my-namespace"><my:e a="1" /></r>'
}

task Add-ProjectReference {
	# simplified project sample
	Set-Content z.csproj @'
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003"/>
'@
	# add System, ItemGroup should be added
	../Examples/Add-ProjectReference.ps1 z.csproj System

	# add System.Xml, keep LastWriteTime
	../Examples/Add-ProjectReference.ps1 z.csproj System.Xml
	$LastWriteTime = (Get-Item z.csproj).LastWriteTime

	# add System.Xml again, should not touch the file
	../Examples/Add-ProjectReference.ps1 z.csproj System.Xml
	equals $LastWriteTime (Get-Item z.csproj).LastWriteTime

	# test expected content
	equals ([IO.File]::ReadAllText("$BuildRoot\z.csproj")) @'
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup>
    <Reference Include="System" />
    <Reference Include="System.Xml" />
  </ItemGroup>
</Project>
'@

	Remove-Item z.csproj
}
