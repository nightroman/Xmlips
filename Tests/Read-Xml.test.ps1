
Import-Module Xmlips

task New {
	if (Test-Path z.xml) {Remove-Item z.xml}
	$content = '<root/>'

	$xml = Read-Xml z.xml -Content $content
	assert $xml.IsNew
	assert $xml.IsChanged
	$null = Find-Xml e a атрибут $xml.DocumentElement
	$xml.Save()
	assert (Test-Path z.xml)

	$xml = Read-Xml z.xml -Content $content
	assert (!$xml.IsNew)
	assert (!$xml.IsChanged)
	$e = Get-Xml //e $xml
	equals $e.a 'атрибут'
}

task NewBom {
	if (Test-Path z.xml) {Remove-Item z.xml}

	$content = '<?xml version="1.0" encoding="utf-8"?><root/>'
	$xml = Read-Xml z.xml -Content $content
	$xml.Save()
	equals (Get-Item z.xml).Length ($content.Length + 6L)
}

task NewNoBom {
	if (Test-Path z.xml) {Remove-Item z.xml}

	$content = '<root/>'
	$xml = Read-Xml z.xml -Content $content
	$xml.Save()
	equals (Get-Item z.xml).Length ($content.Length + 1L)
}

task Add {
	Set-Content z.xml '<root/>'

	$xml = Read-Xml z.xml
	assert (!$xml.IsChanged)

	$e = $xml.DocumentElement.AppendChild($xml.CreateElement('node'))
	$e.SetAttribute('id', 1)
	$e = $xml.DocumentElement.AppendChild($xml.CreateElement('node'))
	$e.SetAttribute('id', 2)

	assert $xml.IsChanged
	$xml.Save()
	assert (!$xml.IsChanged)

	assert (Get-Content z.xml | Out-String).Equals(@'
<root>
  <node id="1" />
  <node id="2" />
</root>

'@)

	# not saved on no changes
	$time1 = (Get-Item z.xml).LastWriteTime
	Start-Sleep -Milliseconds 50
	$xml.Save()
	$time2 = (Get-Item z.xml).LastWriteTime
	equals $time1 $time2
}

task Edit Add, {
	$xml = Read-Xml z.xml
	$node = Get-Xml '*/node[@id = 2]' $xml
	equals $node.id '2'
	$node.id = '3'
	$xml.Save()

	assert (Get-Content z.xml | Out-String).Equals(@'
<root>
  <node id="1" />
  <node id="3" />
</root>

'@)
}

task Remove Edit, {
	$xml = Read-Xml z.xml
	$node = Get-Xml '*/node[@id = 3]' $xml
	equals $node.id '3'
	Remove-Xml $node
	$xml.Save()

	assert (Get-Content z.xml | Out-String).Equals(@'
<root>
  <node id="1" />
</root>

'@)
}

task Fragment {
	Set-Content z.xml @'
<e1 a="1" t="e1"><inner a="inner"/></e1>
<e1 a="2" t="e1"/>
<e2 a="1" t="e2"/>
'@
	$xml = Read-Xml z.xml -Fragment
	equals $xml.Count 3

	$r = Get-Xml 'self::*[@a=1]' $xml
	equals $r.Count 2

	$r = Get-Xml '*[@a = "inner"]' $r
	equals $r.OuterXml '<inner a="inner" />'

	$r = Get-Xml 'self::e2' $xml
	equals $r.OuterXml '<e2 a="1" t="e2" />'
}

task Backup {
	Set-Content z.xml '<r/>'
	$xml = Read-Xml z.xml -Backup
	$null = Find-Xml e a 1 $xml.DocumentElement
	$xml.Save()

	$xml = Read-Xml z.xml
	equals $xml.InnerXml '<r><e a="1" /></r>'

	$xml = Read-Xml z.xml.bak
	equals $xml.InnerXml '<r />'
}

task Clean {
	Remove-Item z.xml, z.xml.bak
}
