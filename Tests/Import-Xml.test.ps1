
Import-Module Xmlips
$Version = $PSVersionTable.PSVersion.Major

task Import {
	Set-Content z.xml @'
<e1 a="1" t="e1"><inner a="2"/></e1>
<e1 a="2" t="e1"><inner a="1"/></e1>
<e2 a="1" t="e2"/>
'@
	$xml = Import-Xml z.xml
	equals $xml.ChildNodes.Count 3

	# level 1 with a=1
	$r = Get-Xml '*[@a=1]' $xml
	equals $r.Count 2
	equals $r[0].OuterXml '<e1 a="1" t="e1"><inner a="2" /></e1>'
	equals $r[1].OuterXml '<e2 a="1" t="e2" />'

	# level 2+ with a=2
	$r = Get-Xml '*//*[@a="2"]' $xml
	equals $r.OuterXml '<inner a="2" />'

	# level 1 name e2
	$r = Get-Xml 'e2' $xml
	equals $r.OuterXml '<e2 a="1" t="e2" />'

	Remove-Item z.xml
}

$Pandoc = Get-Command pandoc.exe* -CommandType Application

task PandocXmlips -If ($Pandoc) {
	# --to=html outputs as XHTML, without --standalone it is not well-formed XML,
	# there is no need to use -Namespace @{x = 'http://www.w3.org/1999/xhtml'}
	$text = exec {& $Pandoc.Path --to=html ../Release-Notes.md}

	# import and find versions
	$r = Import-Xml -Content $text | Get-Xml h2

	# show and test
	$r | Out-String
	assert ($r.Count -ge 3)
	equals $r[-1].id v0.0.1
}

task PandocNative -If ($Pandoc -and $Version -ge 3) {
	# --to=html outputs as XHTML, with --standalone it is well-formed XML
	# and queries require -Namespace @{x = 'http://www.w3.org/1999/xhtml'}
	$text = exec {& $Pandoc.Path --to=html --standalone ../Release-Notes.md}

	# import and find versions
	$r = ([xml]$text) | Select-Xml x:html/x:body/x:h2 -Namespace @{x = 'http://www.w3.org/1999/xhtml'}

	# show and test
	$r | Out-String
	assert ($r.Count -ge 3)
	equals $r[-1].Node.id v0.0.1
}

task BadFragment {
	Set-Content z.xml @'
<e a="1"/>
</e>
<e a="2"/>
'@
	($r = try {Read-Xml z.xml} catch {$_})
	equals "$r" 'Unexpected end tag. Line 2, position 3.'

	Remove-Item z.xml
}
