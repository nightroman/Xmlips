
Import-Module Xmlips

task New {
	if (Test-Path z.xml) {Remove-Item z.xml}
	$content = '<root/>'

	$xml = Read-Xml z.xml -Content $content
	assert $xml.IsNew
	assert $xml.IsChanged
	Find-Xml e a атрибут $xml.DocumentElement
	$xml.Save()
	assert (Test-Path z.xml)

	$xml = Read-Xml z.xml -Content $content
	assert (!$xml.IsNew)
	assert (!$xml.IsChanged)
	$e = Get-Xml //e $xml
	assert $e.a.Equals('атрибут')
}

task NewBom {
	if (Test-Path z.xml) {Remove-Item z.xml}

	$content = '<?xml version="1.0" encoding="utf-8"?><root/>'
	$xml = Read-Xml z.xml -Content $content
	$xml.Save()
	assert ((Get-Item z.xml).Length -eq ($content.Length + 6))
}

task NewNoBom {
	if (Test-Path z.xml) {Remove-Item z.xml}

	$content = '<root/>'
	$xml = Read-Xml z.xml -Content $content
	$xml.Save()
	assert ((Get-Item z.xml).Length -eq ($content.Length + 1))
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
	assert $time1.Equals($time2)
}

task Edit Add, {
	$xml = Read-Xml z.xml
	$node = Get-Xml '*/node[@id = 2]' $xml
	assert $node.id.Equals('2')
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
	assert $node.id.Equals('3')
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
	assert $xml.Count.Equals(3)

	$r = Get-Xml 'self::*[@a=1]' $xml
	assert $r.Count.Equals(2)

	$r = Get-Xml '*[@a = "inner"]' $r
	assert $r.OuterXml.Equals('<inner a="inner" />')

	$r = Get-Xml 'self::e2' $xml
	assert $r.OuterXml.Equals('<e2 a="1" t="e2" />')
}

task Backup {
	Set-Content z.xml '<r/>'
	$xml = Read-Xml z.xml -Backup
	$null = Find-Xml e a 1 $xml.DocumentElement
	$xml.Save()

	$xml = Read-Xml z.xml
	assert $xml.InnerXml.Equals('<r><e a="1" /></r>')

	$xml = Read-Xml z.xml.bak
	assert $xml.InnerXml.Equals('<r />')
}

task Clean {
	Remove-Item z.xml, z.xml.bak
}
