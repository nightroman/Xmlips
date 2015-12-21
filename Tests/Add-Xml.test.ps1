
Import-Module Xmlips

task BadName {
	($r = try {Add-Xml} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.AddXmlCommand')
	assert ($r -clike '*: Name')

	($r = try {Add-Xml ''} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.AddXmlCommand')
	assert ($r -clike '*: Name')
}

task BadXml {
	($r = try {Add-Xml e} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.AddXmlCommand')
	assert ($r -clike '*: Xml')

	($r = try {Add-Xml e $null} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.AddXmlCommand')
	assert ($r -clike '*: Xml')
}

task EmptyXml {
	$r = Add-Xml e @()
	assert ($null -eq $r)

	$r = @() | Add-Xml e
	assert ($null -eq $r)
}

task Add {
	$xml = [xml]'<r/>'
	$r = Add-Xml e $xml.DocumentElement
	assert $r.OuterXml.Equals('<e />')
	assert $xml.InnerXml.Equals('<r><e /></r>')
}
