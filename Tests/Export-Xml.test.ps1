﻿
$Version = $PSVersionTable.PSVersion.Major
Import-Module Xmlips

task BadXml {
	($r = try {Export-Xml z.xml} catch {$_})
	equals $r.FullyQualifiedErrorId 'Argument,Xmlips.Commands.ExportXmlCommand'
	equals "$r" 'Xml is required.'

	($r = try {Export-Xml z.xml @($null)} catch {$_})
	equals $r.FullyQualifiedErrorId 'ArgumentNull,Xmlips.Commands.ExportXmlCommand'
	if ($Version -ge 7) {
		equals "$r" "Value cannot be null. (Parameter 'Xml (item)')"
	}
	else {
		assert ($r -clike '*: Xml (item)')
	}

	Remove-Item z.xml
}

task NoXml {
	$r = $(
		Export-Xml z.xml @()
		Export-Xml z.xml $null
		@() | Export-Xml z.xml
		$null | Export-Xml z.xml
	)
	equals $r

	Remove-Item z.xml
}

task Append {
	if (Test-Path z.xml) {Remove-Item z.xml}

	$log = ([xml]'<log/>').DocumentElement
	$log.SetAttribute('date', (Get-Date).ToString('s'))
	$log.SetAttribute('атрибут', 'значение1')
	$log.InnerText = '<текст>'

	# create
	Export-Xml z.xml $log -Append
	assert (Test-Path z.xml)

	# append
	$log.SetAttribute('атрибут', 'значение2')
	Export-Xml z.xml $log -Append

	# use array
	$log.SetAttribute('атрибут', 'значение3')
	Export-Xml z.xml $log, $log -Append

	# use pipeline
	$log.SetAttribute('атрибут', 'значение4')
	$log, $log | Export-Xml z.xml -Append

	# test
	($r = Import-Xml z.xml) | Out-String
	equals $r.ChildNodes.Count 6
	($r = ($r | Get-Xml 'log' -Property @{a='@атрибут'} | .{process{ $_.a }}) -join '|')
	equals $r 'значение1|значение2|значение3|значение3|значение4|значение4'

	Remove-Item z.xml
}

task Create {
	if (Test-Path z.xml) {Remove-Item z.xml}

	$log = ([xml]'<log/>').DocumentElement
	$log.SetAttribute('атрибут', 'значение1')

	# create new
	Export-Xml z.xml $log
	$r = Import-Xml z.xml
	equals $r.ChildNodes.Count 1
	equals $r.LastChild.атрибут значение1

	# override
	$log.SetAttribute('атрибут', 'значение2')
	Export-Xml z.xml $log
	$r = Import-Xml z.xml
	equals $r.ChildNodes.Count 1
	equals $r.LastChild.атрибут значение2

	Remove-Item z.xml
}

task Namespace {
	# get nodes with namespace and export
	$ns = @{x='http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd'}
	[xml]$xml = Get-Content $HOME\.nuget\packages\powershellstandard.library\5.1.1\powershellstandard.library.nuspec
	$r = Get-Xml '//x:references' $xml -Namespace $ns
	$r | Export-Xml z.xml

	# import, namespace is present
	$r = Import-Xml z.xml
	$r.FirstChild | Out-String
	equals $r.FirstChild.xmlns $ns.x
	assert ($r.ChildNodes.Count -eq 1)

	remove z.xml
}
