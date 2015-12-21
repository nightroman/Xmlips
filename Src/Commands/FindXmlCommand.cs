
// Copyright (c) 2015 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System.Management.Automation;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommon.Find, "Xml")]
	[OutputType(typeof(XmlElement))]
	public sealed class FindXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0)]
		public string Name { get; set; }

		[Parameter(Position = 1)]
		public string Key { get; set; }

		[Parameter(Position = 2)]
		public string Value { get; set; }

		[Parameter(Position = 3, ValueFromPipeline = true)]
		public XmlElement Xml { get; set; }

		protected override void BeginProcessing()
		{
			if (string.IsNullOrEmpty(Name)) throw new PSArgumentNullException("Name");
			if (string.IsNullOrEmpty(Key)) throw new PSArgumentNullException("Key");
			if (string.IsNullOrEmpty(Value)) throw new PSArgumentNullException("Value");
		}

		protected override void ProcessRecord()
		{
			if (Xml == null) throw new PSArgumentNullException("Xml");

			var xpath = string.Format(null, "{0}[@{1} = $x]", Name, Key);
			var node = Xml.SelectSingleNode(xpath, new SimpleXsltContext(Value));

			if (node == null)
			{
				var elem = Xml.OwnerDocument.CreateElement(Name);
				elem.SetAttribute(Key, Value);
				Xml.AppendChild(elem);
				node = elem;
			}

			WriteObject(node);
		}
	}
}
