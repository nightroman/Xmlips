
Import-Module Xmlips

task BadXml {
	($r = try {Remove-Xml} catch {$_})
	equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.RemoveXmlCommand'
	equals "$r" 'Xml is required.'

	($r = try {Remove-Xml @($null)} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.RemoveXmlCommand'
	assert ("$r" -clike '*: Xml (item)')
}

task NoXml {
	$r = $(
		Remove-Xml @()
		Remove-Xml $null
		@() | Remove-Xml
		$null | Remove-Xml
	)
	equals $r
}

task Remove {
	$xml = [xml]'<r><e a="1" /><e a="2" /><e a="3" /><e a="4" /><e a="5" /></r>'

	# using parameter
	$node = Get-Xml //e $xml -Single
	Remove-Xml $node
	equals $xml.InnerXml '<r><e a="2" /><e a="3" /><e a="4" /><e a="5" /></r>'

	# using pipeline
	$nodes = Get-Xml '//e[@a > 3]' $xml
	equals $nodes.Count 2
	$nodes | Remove-Xml
	equals $xml.InnerXml '<r><e a="2" /><e a="3" /></r>'

	# using array
	$nodes = Get-Xml //e $xml
	equals $nodes.Count 2
	Remove-Xml $nodes
	equals $xml.InnerXml '<r></r>'
}
