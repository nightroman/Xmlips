
Import-Module Xmlips

task BadTag {
	($r = try {Find-Xml} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.FindXmlCommand'
	assert ($r -clike '*: Tag')

	($r = try {Find-Xml ''} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.FindXmlCommand'
	assert ($r -clike '*: Tag')
}

task BadKey {
	($r = try {Find-Xml e} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.FindXmlCommand'
	assert ($r -clike '*: Key')

	($r = try {Find-Xml e ''} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.FindXmlCommand'
	assert ($r -clike '*: Key')
}

task BadValue {
	($r = try {Find-Xml e k} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.FindXmlCommand'
	assert ($r -clike '*: Value')

	($r = try {Find-Xml e k ''} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.FindXmlCommand'
	assert ($r -clike '*: Value')
}

task BadXml {
	($r = try {Find-Xml e k v} catch {$_})
	equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.FindXmlCommand'
	equals "$r" 'Xml is required.'

	($r = try {Find-Xml e k v @($null)} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.FindXmlCommand'
	assert ($r -clike '*: Xml (item)')
}

task NoXml {
	$r = $(
		Find-Xml e k v @()
		Find-Xml e k v $null
		@() | Find-Xml e k v
		$null | Find-Xml e k v
	)
	equals $r
}

task Find {
	$doc = [xml]'<r><e a="1" /></r>'
	$xml = $doc.DocumentElement

	# get existing and pipe to add missing
	$r = Find-Xml e a 1 $xml | Find-Xml new new new
	equals $r.OuterXml '<new new="new" />'
	equals $xml.InnerXml '<e a="1"><new new="new" /></e>'

	# add missing with apostrophe
	$r = Find-Xml e a "'s" $xml
	equals $r.OuterXml '<e a="''s" />'

	# add missing with quotation
	$r = Find-Xml e a '"s' $xml
	equals $r.OuterXml '<e a="&quot;s" />'

	# 3+1 elements
	equals $doc.InnerXml '<r><e a="1"><new new="new" /></e><e a="''s" /><e a="&quot;s" /></r>'
}
