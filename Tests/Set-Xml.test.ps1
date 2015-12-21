
Import-Module Xmlips

task BadAttribute {
	($r = try {Set-Xml $null $null} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.SetXmlCommand')
	assert ($r -clike '*: Attribute')

	($r = try {Set-Xml @() $null} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('Argument,Xmlips.Commands.SetXmlCommand')
	assert "$r".Equals('Parameter Attribute must not be empty.')

	($r = try {Set-Xml a $null} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('Argument,Xmlips.Commands.SetXmlCommand')
	assert "$r".Equals('Parameter Attribute must contain even number of items.')

	($r = try {Set-Xml '', $v $null} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('Argument,Xmlips.Commands.SetXmlCommand')
	assert "$r".Equals('Parameter Attribute contains null or empty name.')
}

task BadXml {
	($r = try {Set-Xml x, x} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.SetXmlCommand')
	assert ($r -clike '*: Xml')

	($r = try {Set-Xml x, x $null} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.SetXmlCommand')
	assert ($r -clike '*: Xml')
}

task EmptyXml {
	$r = Set-Xml x, x @()
	assert ($null -eq $r)

	$r = @() | Set-Xml x, x
	assert ($null -eq $r)
}

task Set {
	Set-Content z.xml '<r><e a="1" /><e a="2" /><e a="2" /></r>'

	## not changed on setting the same

	$xml = Read-Xml z.xml

	# single
	$r = Get-Xml //e $xml -Single
	Set-Xml a, 1 $r -Changed
	assert (!$xml.IsChanged)

	# array
	$r = Get-Xml //e[@a=2] $xml
	assert $r.Count.Equals(2)
	Set-Xml a, 2 $r -Changed
	assert (!$xml.IsChanged)

	## changed on setting new

	# single, changed
	$r = Get-Xml //e $xml -Single
	$changed = Set-Xml a, -1 $r -Changed
	assert ($xml.IsChanged)
	assert ($r.a.Equals('-1'))
	assert $changed.Attribute.Equals('a')
	assert $changed.OldValue.Equals('1')
	assert $changed.NewValue.Equals('-1')
	assert $changed.Element.Equals($r)

	# array, changed
	$r = Get-Xml //e[@a=2] $xml
	$changed = Set-Xml a, -2 $r -Changed
	assert ($r[0].a.Equals('-2'))
	assert ($r[1].a.Equals('-2'))
	assert $r.Count.Equals(2)

	# pipeline
	$r = Get-Xml //e[@a=-2] $xml
	$r | Set-Xml a, 2
	assert ($r[0].a.Equals('2'))
	assert ($r[1].a.Equals('2'))

	Remove-Item z.xml
}
