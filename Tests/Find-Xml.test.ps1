
Import-Module Xmlips

task BadName {
	($r = try {Find-Xml} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.FindXmlCommand')
	assert ($r -clike '*: Name')

	($r = try {Find-Xml ''} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.FindXmlCommand')
	assert ($r -clike '*: Name')
}

task BadKey {
	($r = try {Find-Xml e} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.FindXmlCommand')
	assert ($r -clike '*: Key')

	($r = try {Find-Xml e ''} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.FindXmlCommand')
	assert ($r -clike '*: Key')
}

task BadValue {
	($r = try {Find-Xml e k} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.FindXmlCommand')
	assert ($r -clike '*: Value')

	($r = try {Find-Xml e k ''} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.FindXmlCommand')
	assert ($r -clike '*: Value')
}

task BadXml {
	($r = try {Find-Xml e k v} catch {$_})
	assert $r.FullyQualifiedErrorId.Equals('ArgumentNull,Xmlips.Commands.FindXmlCommand')
	assert ($r -clike '*: Xml')
}

task Find {
	$doc = [xml]'<r><e a="1" /></r>'
	$xml = $doc.DocumentElement

	# get existing and pipe to add missing
	$r = Find-Xml e a 1 $xml | Find-Xml new new new
	assert $r.OuterXml.Equals('<new new="new" />')
	assert $xml.InnerXml.Equals('<e a="1"><new new="new" /></e>')

	# add missing with apostrophe
	$r = Find-Xml e a "'s" $xml
	assert $r.OuterXml.Equals('<e a="''s" />')

	# add missing with quotation
	$r = Find-Xml e a '"s' $xml
	assert $r.OuterXml.Equals('<e a="&quot;s" />')

	# 3+1 elements
	assert $doc.InnerXml.Equals('<r><e a="1"><new new="new" /></e><e a="''s" /><e a="&quot;s" /></r>')
}
