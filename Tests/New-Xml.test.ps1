
Import-Module Xmlips

task Tag {
	# default
	$r = New-Xml
	equals $r.OuterXml '<root />'

	# default
	$r = New-Xml ''
	equals $r.OuterXml '<root />'

	# default
	$r = New-Xml $null
	equals $r.OuterXml '<root />'

	# custom
	$r = New-Xml name
	equals $r.OuterXml '<name />'
}

task Attribute {
	$test = {
		equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.NewXmlCommand'
		equals "$r" 'Parameter Attribute contains null or empty name.'
	}

	($r = try {New-Xml tag '', 1} catch {$_})
	. $test

	($r = try {New-Xml tag $null, 1} catch {$_})
	. $test
}

task Log {
	Remove-Item [z] -Force -Recurse

	# case 1
	$e = New-Xml log
	Set-Xml date, 2016-12-01, text1 $e
	Export-Xml z $e

	# case 2
	New-Xml log date, 2016-12-02, text2 | Export-Xml z -Append

	$r = Import-Xml z
	equals $r.OuterXml '<root><log date="2016-12-01">text1</log><log date="2016-12-02">text2</log></root>'

	Remove-Item z
}
