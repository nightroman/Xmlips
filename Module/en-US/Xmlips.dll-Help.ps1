
<#
.Synopsis
	Help script (https://github.com/nightroman/Helps)
#>

# Import the module to make commands available for the builder.
Import-Module Xmlips

$SiteLink = @{ text = 'Project site:'; URI = 'https://github.com/nightroman/Xmlips' }

### Add-Xml command help
@{
	command = 'Add-Xml'
	synopsis = 'Adds an XML element.'
	description = @'
	The command creates and adds a new XML element to the specified.
'@
	parameters = @{
		Name = @{
			required = $true
			description = 'Specifies the new element name.'
		}
		Xml = @{
			required = $true
			description = 'Specifies the parent element.'
		}
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
		Name = @{
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

### Set-Xml command help
@{
	command = 'Set-Xml'
	synopsis = 'Sets XML attributes.'
	description = @'
	The cmdlet sets the specified attribute values.
'@
	parameters = @{
		Attribute = @{
			required = $true
			description = @'
		Specifies the list of attribute names followed by values to be set.
'@
		}
		Xml = @{
			required = $true
			description = @'
		Specifies the XML element which attributes are set.
'@
		}
		Changed = @'
		Tells to set only changed values and return information about changes.

		The same values are not set and the document is not changed. This may
		avoid unnecessary saving of a document read by Read-Xml.

		For each changed value an object describing the change is written.
		The properties are Attribute, OldValue, NewValue, Element.
'@
	}
	inputs = @{
		type = 'System.Xml.XmlElement'
		description = 'XML element which attributes are set.'
	}
	outputs = @{
		type = 'None or change information objects'
		description = 'Change information is retuned if Changed is specified.'
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
	synopsis = 'Reads an XML document or fragments from a file.'
	description = @'
	The cmdlet reads an XML document from a file. The returned document watches for
	changes. Its method Save() saves XML to the source file if the document is
	changed.

	The returned XmlDocument contains extra members:

		Save()
			Saves the changed document to the source file.

		IsNew
			Tells that the document is created from Content.

		IsChanged
			Tells that the document is changed.
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
		Backup = @'
		Tells to create a backup copy of the original source file on saving of
		the changed document by Save(). The backup file name is the original
		name with added ".bak".
'@
		Fragment = @'
		Tells that the source file contains XML fragments instead of a
		well-formed XML. In this case the cmdlet reads and returns nodes.
'@
	}
	outputs = @(
		@{
			type = 'Xmlips.FileXmlDocument'
			description = 'XmlDocument with extra members Save(), IsNew, IsChanged.'
		}
		@{
			type = 'System.Xml.XmlNode'
			description = 'XML nodes are returned if Fragment is specified.'
		}
	)
	examples = @(
		@{
			code = {
	$xml = Read-Xml data.xml
	...
	$xml.Save()
			}
			remarks = @'
	The example shows a typical scenario: an XML document is read from a file,
	some operations are performed on returned $xml, and then Save() is called.
'@
		}
	)
	links = @(
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
		Xml = @'
		Specifies one or more nodes to be removed.
'@
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
