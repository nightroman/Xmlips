
Import-Module Xmlips

task NullXml {
	$r = Remove-Xml $null
	assert ($null -eq $r)
}

task EmptyXml {
	$r = Remove-Xml @()
	assert ($null -eq $r)
}

task Remove {
	$xml = [xml]'<r><e a="1" /><e a="2" /><e a="3" /><e a="4" /><e a="5" /></r>'

	# using parameter
	$node = Get-Xml //e $xml -Single
	Remove-Xml $node
	assert $xml.InnerXml.Equals('<r><e a="2" /><e a="3" /><e a="4" /><e a="5" /></r>')

	# using pipeline
	$nodes = Get-Xml '//e[@a > 3]' $xml
	assert $nodes.Count.Equals(2)
	$nodes | Remove-Xml
	assert $xml.InnerXml.Equals('<r><e a="2" /><e a="3" /></r>')

	# using array
	$nodes = Get-Xml //e $xml
	assert $nodes.Count.Equals(2)
	Remove-Xml $nodes
	assert $xml.InnerXml.Equals('<r></r>')
}
