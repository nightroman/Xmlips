
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

using System.Management.Automation;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsData.Save, "Xml")]
	public sealed class SaveXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0)]
		public XmlNode Xml { get; set; }

		protected override void BeginProcessing()
		{
			if (Xml == null) throw new PSArgumentNullException("Xml");

			var doc = Xml.OwnerDocument as FileXmlDocument;
			if (doc == null) throw new PSArgumentException("Element must belong to document read by Read-Xml.");

			doc.Save();
		}
	}
}
