
Import-Module Xmlips
$Version = $PSVersionTable.PSVersion.Major

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
	remove z.xml
}

task New {
	remove z.xml
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

	remove z.xml
}

task NewBom {
	remove z.xml

	$content = '<?xml version="1.0" encoding="utf-8"?><root/>'
	$xml = Read-Xml z.xml -Content $content
	Save-Xml $xml
	equals (Get-Item z.xml).Length ($content.Length + 6L)

	remove z.xml
}

task NewNoBom {
	remove z.xml

	$content = '<root/>'
	$xml = Read-Xml z.xml -Content $content
	Save-Xml $xml
	equals (Get-Item z.xml).Length ($content.Length + 1L)

	remove z.xml
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

	remove z.xml
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

	remove z.xml, z.xml.bak
}

task Settings {
	# this XML (pandoc) cannot be read with default settings
	Set-Content z.xml @'
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title></title>
</head>
<body>
<p>Hello</p>
</body>
</html>
'@

	$settings = New-Object System.Xml.XmlReaderSettings
	if ($Version -eq 2) {
		$settings.ProhibitDtd = $false
		$settings.XmlResolver = $null
	}
	else {
		$settings.DtdProcessing = 'Ignore'
	}

	$r = Read-Xml z.xml -Settings $settings | Get-Xml //x:p -Namespace @{x="http://www.w3.org/1999/xhtml"}
	equals $r.'#text' Hello

	remove z.xml
}
