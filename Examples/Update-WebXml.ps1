
<#
.Synopsis
	Updates special XML files using Invoke-RestMethod.

.Description
	The command reads the file, determines the data to be updated, adds or
	updates attributes, saves the changed file with the backup copy of the
	original (.bak is added). Change info objects are written to output.

	HOW IT WORKS

	Create an initial XML file. Element names do not matter. Elements with
	attributes @web_root and @web_data define groups. Their child elements
	contain the attribute @web_id and define watched and updated items.

	Invoke the command with such a file.

	For each element with the attribute @web_id:

	- Invoke-RestMethod is called with Uri = ../@web_root + @web_id
	- Invoke-RestMethod is supposed to return a single JSON object
	- The object fields are defined by space separated ../@web_data
	- Fields are converted to the element attributes with same names
	- Changes are returned as: web_id, Property, OldValue, NewValue

	Later on remove or add new groups and items to be watched.

	Example initial file with GitHub repositories and users:

		<!--
		repos: https://developer.github.com/v3/repos
		users: https://developer.github.com/v3/users
		-->
		<web>
		  <repos web_root="https://api.github.com/repos/" web_data="name open_issues">
		    <repo web_id="User1/Repo1"/>
		    ...
		  </repos>
		  <users web_root="https://api.github.com/users/" web_data="name email company location">
		    <user web_id="User1"/>
		    ...
		  </users>
		</web>

	On the first run of the command with this file its elements "repo" and
	"user" are populated with attributes "name open_issues" and "name email
	company location". On next runs these attributes are updated on changes.

.Parameter Path
	Specifies the XML file for input and output.
	Default: "web.xml" in the current location.
#>

param(
	[Parameter()]
	[string]$Path = 'web.xml'
)

#requires -version 3
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module Xmlips
$xml = Read-Xml $Path -Backup

foreach($elem in Get-Xml //@web_id/.. $xml) {
	$root = $elem.ParentNode
	$uri = $root.web_root + $elem.web_id
	$data = $root.web_data.Trim() -split '\s+'

	$web = Invoke-RestMethod $uri
	foreach($name in $data) {
		if ($change = Set-Xml $name, $web.$name $elem -Changed) {
			[PSCustomObject]@{
				web_id = $elem.web_id
				Property = $change.Attribute
				OldValue = $change.OldValue
				NewValue = $change.NewValue
			}
		}
	}
}

Save-Xml $xml
