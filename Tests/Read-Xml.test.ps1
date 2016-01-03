
Import-Module Xmlips

task BadContent {
	($r = try {Read-Xml missing.xml -Content $null} catch {$_})
	equals $r.FullyQualifiedErrorId 'ParameterArgumentValidationError,Xmlips.Commands.ReadXmlCommand'

	($r = try {Read-Xml missing.xml -Content ''} catch {$_})
	equals $r.FullyQualifiedErrorId 'ParameterArgumentValidationError,Xmlips.Commands.ReadXmlCommand'
}

task RootIsMissing {
	($r = try {Read-Xml missing.xml -Content ' '} catch {$_})
	equals "$r" 'Root element is missing.'
	equals $r.FullyQualifiedErrorId 'System.Xml.XmlException,Xmlips.Commands.ReadXmlCommand'

	Set-Content z.xml ''
	($r = try {Read-Xml z.xml} catch {$_})
	equals "$r" 'Root element is missing.'
	equals $r.FullyQualifiedErrorId 'System.Xml.XmlException,Xmlips.Commands.ReadXmlCommand'
	Remove-Item z.xml
}

task New {
	if (Test-Path z.xml) {Remove-Item z.xml}
	$content = '<root/>'

	$xml = Read-Xml z.xml -Content $content
	assert $xml.OwnerDocument.IsNew
	assert $xml.OwnerDocument.IsChanged
	$null = Find-Xml e a атрибут $xml
	Save-Xml $xml
	assert (Test-Path z.xml)

	$xml = Read-Xml z.xml -Content $content
	assert (!$xml.OwnerDocument.IsNew)
	assert (!$xml.OwnerDocument.IsChanged)
	$e = Get-Xml e $xml
	equals $e.a 'атрибут'
}

task NewBom {
	if (Test-Path z.xml) {Remove-Item z.xml}

	$content = '<?xml version="1.0" encoding="utf-8"?><root/>'
	$xml = Read-Xml z.xml -Content $content
	Save-Xml $xml
	equals (Get-Item z.xml).Length ($content.Length + 6L)
}

task NewNoBom {
	if (Test-Path z.xml) {Remove-Item z.xml}

	$content = '<root/>'
	$xml = Read-Xml z.xml -Content $content
	Save-Xml $xml
	equals (Get-Item z.xml).Length ($content.Length + 1L)
}

task Add {
	Set-Content z.xml '<root/>'

	$xml = Read-Xml z.xml
	$doc = $xml.OwnerDocument
	assert (!$doc.IsChanged)

	Add-Xml node $xml | Set-Xml id, 1
	Add-Xml node $xml | Set-Xml id, 2

	assert $doc.IsChanged
	Save-Xml $xml
	assert (!$doc.IsChanged)

	assert (Get-Content z.xml | Out-String).Equals(@'
<root>
  <node id="1" />
  <node id="2" />
</root>

'@)

	# not saved on no changes
	$time1 = (Get-Item z.xml).LastWriteTime
	Start-Sleep -Milliseconds 50
	Save-Xml $xml
	$time2 = (Get-Item z.xml).LastWriteTime
	equals $time1 $time2
}

task Edit Add, {
	$xml = Read-Xml z.xml
	$node = Get-Xml 'node[@id = 2]' $xml
	equals $node.id '2'
	$node.id = '3'
	Save-Xml $xml

	assert (Get-Content z.xml | Out-String).Equals(@'
<root>
  <node id="1" />
  <node id="3" />
</root>

'@)
}

task Remove Edit, {
	$xml = Read-Xml z.xml
	$node = Get-Xml 'node[@id = 3]' $xml
	equals $node.id '3'
	Remove-Xml $node
	Save-Xml $xml

	assert (Get-Content z.xml | Out-String).Equals(@'
<root>
  <node id="1" />
</root>

'@)
}

task Backup {
	Set-Content z.xml '<r/>'
	$xml = Read-Xml z.xml -Backup
	$null = Find-Xml e a 1 $xml
	Save-Xml $xml

	$xml = Read-Xml z.xml
	equals $xml.OuterXml '<r><e a="1" /></r>'

	$xml = Read-Xml z.xml.bak
	equals $xml.OuterXml '<r />'
}

task Clean {
	Remove-Item z.xml, z.xml.bak
}
