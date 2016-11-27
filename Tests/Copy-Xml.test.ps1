
Import-Module Xmlips

task BadSource {
	($r = try {Copy-Xml} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.CopyXmlCommand'
	assert ($r -clike '*: Source')
}

task BadTarget {
	($r = try {Copy-Xml (New-Xml)} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.CopyXmlCommand'
	assert ($r -clike '*: Target')
}

task Copy {
	Set-Content z.xml '<r a="1"><e>text1</e></r>'

	$xml = Read-Xml z.xml
	$doc = $xml.OwnerDocument

	# same, not copied
	$new = New-Xml
	$new | Add-Xml e | Set-Xml text1
	Copy-Xml $new $xml
	equals $doc.IsChanged $false

	# different, copied
	$new = New-Xml
	$new | Add-Xml e | Set-Xml text2
	Copy-Xml $new $xml
	equals $doc.IsChanged $true
	equals $xml.OuterXml '<r a="1"><e>text2</e></r>'

	Remove-Item z.xml
}
