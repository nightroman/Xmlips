
// Copyright (c) 2015 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System.Management.Automation;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommon.Add, "Xml")]
	[OutputType(typeof(XmlElement))]
	public sealed class AddXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0)]
		public string Name { get; set; }

		[Parameter(Position = 2, ValueFromPipeline = true)]
		public XmlElement[] Xml { get; set; }

		protected override void BeginProcessing()
		{
			if (string.IsNullOrEmpty(Name)) throw new PSArgumentNullException("Name");
		}

		void ProcessItem(XmlElement xml)
		{
			var elem = xml.OwnerDocument.CreateElement(Name);
			xml.AppendChild(elem);
			WriteObject(elem);
		}

		protected override void ProcessRecord()
		{
			if (Xml == null) throw new PSArgumentNullException("Xml");

			foreach (var item in Xml)
				ProcessItem(item);
		}
	}
}
