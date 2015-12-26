
Import-Module Xmlips

task NullXPath {
	($r = try {Get-Xml $null $null} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.GetXmlCommand'
	assert ($r -clike '*: XPath')
}

task EmptyXPath {
	($r = try {Get-Xml '' $null} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.GetXmlCommand'
	assert ($r -clike '*: XPath')
}

task BadXml {
	($r = try {Get-Xml * @($null)} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.GetXmlCommand'
	assert ($r -clike '*: Xml (item)')

	($r = try {Get-Xml *} catch {$_})
	equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.GetXmlCommand'
	equals "$r" 'Xml is required.'
}

task NoXml {
	$r = $(
		Get-Xml * @()
		Get-Xml * $null
		@() | Get-Xml *
		$null | Get-Xml *
	)
	equals $r
}

task BadProperty {
	($r = try {Get-Xml * $null -Property 1} catch {$_})
	equals "$r" 'Parameter Property item must be string or dictionary.'

	($r = try {Get-Xml * $null -Property @{}} catch {$_})
	equals "$r" 'Parameter Property dictionary must contain 1 key/value.'

	($r = try {Get-Xml * $null -Property @{x = 1}} catch {$_})
	equals "$r" 'Parameter Property dictionary value must be string or array with 2 items.'

	($r = try {Get-Xml * $null -Property @{x = 1, 1}} catch {$_})
	equals "$r" 'Parameter Property dictionary value second item must be Type.'
}

task BadPropertyType {
	$xml = [xml]'<r a="invalid"/>'
	($r = try {Get-Xml r $xml -Property @{a = '@a', [int]}} catch {$_})
	assert ("$r" -like 'Property name "a": * "invalid" * "System.Int32". *')
}

task XmlAndSigle {
	$xml = [xml]@'
<root>
	<node attr='1'>Text 1</node>
	<node attr='2'>Text 2</node>
	<node attr='2'>Text 3</node>
</root>
'@
	$attr = 2

	# parameter
	$r = Get-Xml '*/node[@attr = $attr]' $xml
	equals $r.Count 2
	equals $r[0].'#text' 'Text 2'
	equals $r[1].'#text' 'Text 3'

	# pipeline
	$r = $xml | Get-Xml '*/node[@attr = $attr]'
	equals $r.Count 2
	equals $r[0].'#text' 'Text 2'
	equals $r[1].'#text' 'Text 3'

	# single
	$r = Get-Xml '*/node[@attr = $attr]' $xml -Single
	equals $r.'#text' 'Text 2'

	# array
	$r = Get-Xml '*/node[@attr = $attr]' $xml, $xml -Single
	equals $r.Count 2
	equals $r[0].'#text' 'Text 2'
	equals $r[1].'#text' 'Text 2'
}

task ParameterNamespace {
	$namespace = @{x='http://schemas.microsoft.com/developer/msbuild/2003'}
	[xml]$xml = Get-Content ..\Src\Xmlips.csproj
	$x = 'AssemblyInfo.cs'
	($r = Get-Xml '//x:Compile[@Include = $x]' $xml -Namespace $namespace)
	equals $r.Include $x
}

task Property {
	$xml = [xml]@'
<packages>
	<package name="Package1">
		<version name="1.0.0" date="2014-01-01" downloads="111"/>
		<version name="1.0.1" date="2015-01-01" downloads="11"/>
	</package>
	<package name="Package2">
		<version name="0.0.1" date="2013-02-02" downloads="2"/>
		<version name="2.0.0" date="2014-02-02" downloads="22"/>
		<version name="2.0.1" date="2015-02-02" downloads="222"/>
	</package>
</packages>
'@

	$r = Get-Xml 'packages/package/version[last()]' $xml -Property @(
		@{package = '../@name'}
		@{version = '@name'}
		@{date = '@date', [DateTime]}
		@{downloads = '@downloads', [int]}
	)
	$r | Out-String
	equals $r.Count 2
	equals $r[0].package 'Package1'
	equals $r[0].downloads 11
	assert ($r[0].date -is [DateTime])
	equals $r[1].package 'Package2'
	equals $r[1].downloads 222
	assert ($r[1].date -is [DateTime])

	$r = Get-Xml 'packages/package' $xml -Property @(
		@{package = '@name'}
		@{versions = 'count(version)'}
	)
	$r | Out-String
	equals $r.Count 2
	equals $r[0].versions 2.0
	equals $r[1].versions 3.0

	$p1 = 'string(@name)'
	$p2 = 'count(version)'
	$r = Get-Xml 'packages/package' $xml -Property $p1, $p2
	$r | Out-String
	equals $r.Count 2
	equals $r[0].$p2 2.0
	equals $r[1].$p2 3.0
}

task BooleanProperty {
	$xml = [xml]@'
<r>
	<e a="true"/>
	<e a="false"/>
</r>
'@

	# bad
	$r = Get-Xml //e $xml -Property @{a = '@a', [bool]}
	equals $r[0].a $true
	equals $r[1].a $true #!

	# bad
	$r = Get-Xml //e $xml -Property @{a = 'boolean(@a)'}
	equals $r[0].a $true
	equals $r[1].a $true #!

	# good
	$r = Get-Xml //e $xml -Property @{a = '@a = "true"'}
	equals $r[0].a $true
	equals $r[1].a $false #!
}
