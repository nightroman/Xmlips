
Import-Module Xmlips

task BadAttribute {
	($r = try {Set-Xml $null $null} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.SetXmlCommand'
	assert ($r -clike '*: Attribute')

	($r = try {Set-Xml @() $null} catch {$_})
	equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.SetXmlCommand'
	equals "$r" 'Parameter Attribute must not be empty.'

	($r = try {Set-Xml '', x $null} catch {$_})
	equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.SetXmlCommand'
	equals "$r" 'Parameter Attribute contains null or empty name.'
}

task BadXml {
	($r = try {Set-Xml x, x} catch {$_})
	equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.SetXmlCommand'
	equals "$r" 'Xml is required.'

	($r = try {Set-Xml x, x @($null)} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.SetXmlCommand'
	assert ($r -clike '*: Xml (item)')
}

task NoXml {
	$r = $(
		Set-Xml x, x @()
		Set-Xml x, x $null
		@() | Set-Xml x, x
		$null | Set-Xml x, x
	)
	equals $r
}

task SetAttr {
	Set-Content z.xml '<r><e a="1" /><e a="2" /><e a="2" /></r>'

	## not changed on setting the same

	$xml = Read-Xml z.xml
	$doc = $xml.OwnerDocument

	# single
	$r = Get-Xml e $xml -Single
	$changed = Set-Xml a, 1 $r -Change
	equals $doc.IsChanged $false
	equals $changed $null

	# array
	$r = Get-Xml e[@a=2] $xml
	equals $r.Count 2
	$changed = Set-Xml a, 2 $r -Change
	equals $doc.IsChanged $false
	equals $changed $null

	## changed on setting new

	# single, changed
	$r = Get-Xml e $xml -Single
	$changed = Set-Xml a, -1 $r -Changed
	assert $doc.IsChanged
	equals $r.a '-1'
	equals $changed.Attribute 'a'
	equals $changed.OldValue '1'
	equals $changed.NewValue '-1'
	equals $changed.Element $r

	# array, changed
	$r = Get-Xml e[@a=2] $xml
	$changed = Set-Xml a, -2 $r -Change
	equals $changed $null
	equals $r[0].a '-2'
	equals $r[1].a '-2'
	equals $r.Count 2

	# pipeline
	$r = Get-Xml e[@a=-2] $xml
	$r | Set-Xml a, 2
	equals $r[0].a '2'
	equals $r[1].a '2'

	Remove-Item z.xml
}

task SetText {
	Set-Content z.xml '<r a="1"/>'

	$xml = Read-Xml z.xml
	$doc = $xml.OwnerDocument

	Set-Xml '' $xml -Change
	equals $doc.IsChanged $false

	Set-Xml text1 $xml -Change
	equals $xml.OuterXml '<r a="1">text1</r>'

	Set-Xml a, 2, b, 2, text2 $xml
	equals $xml.OuterXml '<r a="2" b="2">text2</r>'

	Remove-Item z.xml
}
