<#
.Synopsis
	Help script (https://github.com/nightroman/Helps)
#>

# Import the module to make commands available for the builder.
Import-Module Xmlips

$SiteLink = @{ text = 'Project site:'; URI = 'https://github.com/nightroman/Xmlips' }
$AttributeDescription = @'
		Specifies attribute name/value pairs followed by an optional inner
		text. In other words, if the number of items is odd then the last
		item is the inner text.
'@

### Add-Xml command help
@{
	command = 'Add-Xml'
	synopsis = 'Adds an XML element.'
	description = @'
	The command creates and adds a new XML element to the specified.
'@
	parameters = @{
		Tag = @{
			required = $true
			description = 'Specifies the new element name.'
		}
		Xml = @{
			required = $true
			description = 'Specifies the parent element.'
		}
		Namespace = 'The namespace URI of the element.'
	}
	inputs = @{
		type = 'System.Xml.XmlElement'
		description = 'Input parent XML element.'
	}
	outputs = @{
		type = 'System.Xml.XmlElement'
		description = 'Added child XML element.'
	}
	examples = @(
		@{
			code = {
	$xml = [xml]'<r/>'
	Add-Xml e $xml.DocumentElement | Set-Xml a, 1
	$xml.OuterXml
			}
			remarks = @'
	This example adds a new element "e" to the root element and passes the
	added result element in Set-Xml which sets its attribute "a" to "1".
'@
			test = {
	$r = . $args[0]
	if ($r -ne '<r><e a="1" /></r>') {throw}
			}
		}
	)
	links = @(
		$SiteLink
	)
}

### Copy-Xml command help
@{
	command = 'Copy-Xml'
	synopsis = 'Copies the inner XML of one element to another.'
	description = @'
	The cmdlet compares inner XML of the source and target. If they are
	different then the source is copied to the target. Note that this
	command does not affect attributes.
'@
	parameters = @{
		Source = @{
			required = $true
			description = 'Specifies the source element.'
		}
		Target = @{
			required = $true
			description = 'Specifies the target element.'
		}
	}
	links = @(
		$SiteLink
	)
}

### Export-Xml command help
@{
	command = 'Export-Xml'
	synopsis = 'Exports elements as fragments.'
	description = @'
	The cmdlet exports specified XML elements as fragments.
	Exported elements may be imported later by Import-Xml.

	The cmdlet may be used in order to save XML query results for later use.
	Another use case is logging using XML format, in this case the switch
	Append is normally used in order to add new data to logs effectively.
'@
	parameters = @{
		Path = 'Specifies the destination file path.'
		Xml = @{
			required = $true
			description = 'Specifies elements to be exported.'
		}
		Append = 'Tells to append data if the file exists.'
	}
	inputs = @(
		@{
			type = 'System.Xml.XmlElement'
			description = 'XML elements.'
		}
	)
	links = @(
		@{ text = 'Import-Xml' }
		$SiteLink
	)
}

### Find-Xml command help
@{
	command = 'Find-Xml'
	synopsis = 'Gets the specified existing or just added element.'
	description = @'
    The cmdlet gets a single element specified by its name, key attribute name,
    and unique value. If the element is not found then it is created with the
    specified key attribute value and added to the input parent.
'@
	parameters = @{
		Tag = @{
			required = $true
			description = 'Specifies the element name.'
		}
		Key = @{
			required = $true
			description = 'Specifies the key attribute name.'
		}
		Value = @{
			required = $true
			description = 'Specifies the unique attribute value.'
		}
		Xml = @{
			required = $true
			description = 'Specifies the parent element.'
		}
	}
	inputs = @(
		@{
			type = 'System.Xml.XmlElement'
			description = 'XML elements.'
		}
	)
	outputs = @(
		@{
			type = 'System.Xml.XmlElement'
			description = 'Found or created XML element.'
		}
	)
	examples = @(
		@{
			code = {
	$xml = [xml]'<r> <e a="1"/> </r>'
	Find-Xml e a 1 $xml.DocumentElement
	Find-Xml e a 2 $xml.DocumentElement
	$xml.OuterXml
			}
			remarks = @'
	The first Find-Xml gets the existing element "e" with a="1".
	The second Find-Xml gets the created element "e" with a="2".
'@
			test = {
	$r = . $args[0]
	if ($r.Count -ne 3) {throw}
	if ($r[2] -ne '<r><e a="1" /><e a="2" /></r>') {throw}
			}
		}
	)
	links = @(
		$SiteLink
	)
}

### Get-Xml command help
@{
	command = 'Get-Xml'
	synopsis = 'Gets XML nodes or data using XPath.'
	description = @'
	The cmdlet uses XPath queries to search for nodes or data in XML nodes.
'@
	parameters = @{
		XPath = @{
			required = $true
			description = @'
		Specifies an XPath search query. Variables are supported. XPath uses
		the same variable notation as PowerShell: $Variable. Variables are
		evaluated as existing PowerShell variables.
'@
		}
		Xml = @{
			required = $true
			description = @'
		Specifies one or more XML nodes. The XPath query is applied to them.
'@
		}
		Namespace = @'
		Specifies a hash table of the namespaces used in the XML.
		See Select-Xml parameter Namespace for more details.
'@
		Single = @'
		Tells to return the first found node, if any, for each input node.
'@
		Property = @'
		Tells to evaluate the specified XPath expressions on the result node
		and return them as PSObject properties. Strings may be converted to
		specified types.

		The parameter accepts one or more items. Items are defined as:

		<XPath>

			Get-Xml //log $xml -Property '@time', '@count'

		@{<PropertyName> = <XPath>}

			Get-Xml //log $xml -Property @{Time = '@time'}, @{Count = '@count'}

		@{<PropertyName> = <XPath>, <ResultType>}

			Get-Xml //log $xml -Property @(
				@{Time = '@time', [DateTime]}
				@{Count = '@count', [int]}
			)

		PowerShell conversion is used to convert strings to specified types.
'@
	}
	inputs = @{
		type = 'System.Xml.XmlNode'
		description = 'XML nodes.'
	}
	outputs = @(
		@{
			type = 'System.Xml.XmlNode'
			description = 'XML nodes.'
		}
		@{
			type = 'PSObject'
			description = 'Objects with evaluated properties specified by Property.'
		}
	)
	examples = @(
		@{
			code = {
	$xml = [xml]'<r> <e a="1"/> <e a="2"/> </r>'
	$a = 2
	Get-Xml '//e[@a = $a]' $xml
			}
			remarks = @'
	This example creates an XML document and gets an element "e" which
	attribute "a" is equal to 2. The value is specified by a variable.
'@
			test = {
				$r = . $args[0]
				if ($r.OuterXml -ne '<e a="2" />') {throw}
			}
		}
		@{
			code = {
	$xml = [xml]'<r> <e id="1" date="2015-01-02"/> <e id="2" date="2015-11-12"/> </r>'
	Get-Xml //e $xml -Property @{Id = '@id', [int]}, @{Date = '@date', [DateTime]}
			}
			remarks = @'
	This example queries for elements "e" and tells to return PSObject's with
	properties "Id" (int) and "Date" (DateTime) based on attributes "id" and
	"date".
'@
			test = {
				$r = . $args[0]
				if (!$r.Count.Equals(2)) {throw}
				if (!$r[0].Id.Equals(1)) {throw}
				if (!$r[1].Date.Equals(([DateTime]'2015-11-12'))) {throw}
			}
		}
	)
	links = @(
		$SiteLink
	)
}

### Import-Xml command help
@{
	command = 'Import-Xml'
	synopsis = 'Imports elements from a file or strings.'
	description = @'
	The command reads elements from the source with multiple root elements. The
	result is a single element "root" which contains imported elements as child
	nodes.
'@
	parameters = @{
		Path = 'Specifies the source file path.'
		Content = 'Specifies the content string(s).'
	}
	outputs = @(
		@{
			type = 'System.Xml.XmlElement'
			description = 'An element "root" with imported elements.'
		}
	)
	examples = @(
		@{
			code = {
	# pandoc.exe --to=html outputs as XHTML, without --standalone it is not well-formed XML
	$fragments = pandoc.exe --to=html README.md

	# import and get all links, the namespace http://www.w3.org/1999/xhtml is not needed
	Import-Xml -Content $fragments | Get-Xml //a
			}
		}
	)
	links = @(
		@{ text = 'Export-Xml' }
		$SiteLink
	)
}

### New-Xml command help
@{
	command = 'New-Xml'
	synopsis = 'Creates a new XML element.'
	description = @'
	The cmdlet creates and returns an XML element.
'@
	parameters = @{
		Tag = @'
		Specifies the new element name.
		The default name is "root".
'@
		Attribute = $AttributeDescription
	}
	outputs = @{
		type = 'System.Xml.XmlElement'
		description = 'Created XML element.'
	}
	links = @(
		$SiteLink
	)
}

### Save-Xml command help
@{
	command = 'Save-Xml'
	synopsis = 'Saves a document read by Read-Xml.'
	description = @'
	The cmdlet saves a document read by Read-Xml if it is changed.
'@
	parameters = @{
		Xml = @{
			required = $true
			description = 'Any node of the document read by Read-Xml.'
		}
	}
	examples = @(
		@{
			code = {
	$xml = Read-Xml data.xml
	...
	Save-Xml $xml
			}
			remarks = @'
	The example shows a typical scenario: an XML document is read from a file,
	some operations are performed on returned $xml, and then Save-Xml is called.
'@
		}
	)
	links = @(
		@{ text = 'Read-Xml' }
		$SiteLink
	)
}

### Set-Xml command help
@{
	command = 'Set-Xml'
	synopsis = 'Sets XML attributes and text.'
	description = @'
	The cmdlet sets the specified attribute and text values.
'@
	parameters = @{
		Attribute = @{
			required = $true
			description = $AttributeDescription
		}
		Xml = @{
			required = $true
			description = @'
		Specifies the XML element which attributes and text are set.
'@
		}
		Change = @'
		Tells to set only changed values.

		The same values are not set and the document is not changed.
		This may avoid unnecessary writing to disk by Save-Xml.
'@
		Changed = @'
		Tells to set only changed values and return changed information.

		For each changed value an object describing the change is written.
		The properties are Attribute, OldValue, NewValue, Element.
		The attribute name is empty for the text value.
'@
	}
	inputs = @{
		type = 'System.Xml.XmlElement'
		description = 'XML element which attributes and text are set.'
	}
	outputs = @{
		type = 'None or change information objects'
		description = 'Optional change data information.'
	}
	examples = @(
		@{
			code = {
	$xml = [xml]'<r> <e a="1"/> <e/> </r>'
	Get-Xml //e $xml | Set-Xml a, 2
	$xml.InnerXml
			}
			remarks = @'
	This example gets all elements "e" and sets their attribute "a" to "2".
'@
			test = {
				$r = . $args[0]
				if ($r -ne '<r><e a="2" /><e a="2" /></r>') {throw}
			}
		}
	)
	links = @(
		$SiteLink
	)
}

### Read-Xml command help
@{
	command = 'Read-Xml'
	synopsis = 'Reads a document and gets its root element.'
	description = @'
	The cmdlet reads an XML document from a file and returns its root element.
	Use Save-Xml with any node of this document in order to save the changes.
	Note that Save-Xml does not write to disk if the document is not changed.

	The document, if needed, can be obtained as the property OwnerDocument.
	It is derived from XmlDocument and contains extra properties:

		IsChanged
			Tells that the document is changed.

		IsNew
			Tells that the document is created from Content.
'@
	parameters = @{
		Path = @'
		Specifies the source XML file. The file must exist unless Content is
		specified.
'@
		Content = @'
		Tells to create a new document from the specified content if the source
		file does not exist. In this case the properties IsNew and IsChanged
		are set to true.
'@
		Settings = @'
		Specifies the custom XML reader settings instead of the default.
'@
		Backup = @'
		Tells to create a backup copy of the original source file on saving of
		the changed document by Save-Xml. The backup file name is the original
		name with added ".bak".
'@
	}
	outputs = @(
		@{
			type = 'Xmlips.FileXmlDocument'
			description = 'XmlDocument with extra members IsNew, IsChanged.'
		}
	)
	examples = @(
		@{
			code = {
	$xml = Read-Xml data.xml
	...
	Save-Xml $xml
			}
			remarks = @'
	The example shows a typical scenario: an XML document is read from a file,
	some operations are performed on returned $xml, and then Save-Xml is called.
'@
		}
	)
	links = @(
		@{ text = 'Save-Xml' }
		$SiteLink
	)
}

### Remove-Xml command help
@{
	command = 'Remove-Xml'
	synopsis = 'Removes XML nodes.'
	description = @'
	This cmdlet removes the input nodes from their parents.
'@
	parameters = @{
		Xml = @{
			required = $true
			description = 'Specifies one or more nodes to be removed.'
		}
	}

	inputs = @{
		type = 'System.Xml.XmlNode'
		description = 'XML nodes to be removed.'
	}

	examples = @(
		@{
			code = {
	$xml = [xml]'<r> <e a="1"/> <e a="2"/> </r>'
	Get-Xml '//e[@a = 2]' $xml | Remove-Xml
	$xml.InnerXml
			}
			remarks = @'
	This example gets elements with a="2" and removes them.
'@
			test = {
				$r = . $args[0]
				if ($r -ne '<r><e a="1" /></r>') {throw}
			}
		}
	)

	links = @(
		$SiteLink
	)
}
