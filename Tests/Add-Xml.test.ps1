
Import-Module Xmlips

task BadTag {
	($r = try {Add-Xml} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.AddXmlCommand'
	assert ($r -clike '*: Tag')

	($r = try {Add-Xml ''} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.AddXmlCommand'
	assert ($r -clike '*: Tag')
}

task BadXml {
	($r = try {Add-Xml e} catch {$_})
	equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.AddXmlCommand'
	equals "$r" 'Xml is required.'

	($r = try {Add-Xml e @($null)} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.AddXmlCommand'
	assert ($r -clike '*: Xml (item)')
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
