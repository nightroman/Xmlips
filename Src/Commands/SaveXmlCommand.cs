
// Copyright (c) 2015-2016 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

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
