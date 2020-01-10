
$Version = $PSVersionTable.PSVersion.Major
Import-Module Xmlips

task BadXml {
	($r = try {Remove-Xml} catch {$_})
	equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.RemoveXmlCommand'
	equals "$r" 'Xml is required.'

	($r = try {Remove-Xml @($null)} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.RemoveXmlCommand'
	if ($Version -ge 7) {
		equals "$r" "Value cannot be null. (Parameter 'Xml (item)')"
	}
	else {
		assert ($r -clike '*: Xml (item)')
	}
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

task RemoveChildNodes {
	$xml = ([xml]@'
<r a="1">
	<e1/>
	<e2/>
	<e3/>
</r>
'@).DocumentElement

	# cannot use ChildNodes as the parameter
	($r = try { Remove-Xml $xml.ChildNodes } catch {$_})
	equals $r.FullyQualifiedErrorId 'CannotConvertArgumentNoMessage,Xmlips.Commands.RemoveXmlCommand'

	# can pipe but it will remove just the first
	$xml.ChildNodes | Remove-Xml
	equals $xml.ChildNodes.Count 2
	equals $xml.FirstChild.Name e2

	# use @() in order to convert ChildNodes to node array
	@($xml.ChildNodes) | Remove-Xml
	equals $xml.ChildNodes.Count 0

	# final XML
	equals $xml.OuterXml '<r a="1"></r>'
}

task RemoveChildNodesAndAttributes {
	$xml = ([xml]@'
<r a="1" b="2">
	<e1/>
	<e2/>
</r>
'@).DocumentElement

	$xml.RemoveAll()
	equals $xml.OuterXml '<r></r>'
}

# Issue found on removing @Bounds from DGML.
task RemoveAttributes {
	$xml = [xml]@'
<r a1="1">
	<e1 a1="1"/>
	<e2 a2="2"/>
</r>
'@

	$xml | Get-Xml //@a1 | Remove-Xml
	equals '<r><e1 /><e2 a2="2" /></r>' $xml.OuterXml
}
