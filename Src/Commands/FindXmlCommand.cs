
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
		public string Tag { get; set; }

		[Parameter(Position = 1)]
		public string Key { get; set; }

		[Parameter(Position = 2)]
		public string Value { get; set; }

		[Parameter(Position = 3, ValueFromPipeline = true)]
		public XmlElement[] Xml
		{
			get { return _Xml; }
			set
			{
				_Xml = value;
				_XmlSet = true;
			}
		}
		XmlElement[] _Xml;
		bool _XmlSet;

		protected override void BeginProcessing()
		{
			if (string.IsNullOrEmpty(Tag)) throw new PSArgumentNullException("Tag");
			if (string.IsNullOrEmpty(Key)) throw new PSArgumentNullException("Key");
			if (string.IsNullOrEmpty(Value)) throw new PSArgumentNullException("Value");
		}

		void ProcessItem(XmlElement xml)
		{
			if (xml == null) throw new PSArgumentNullException("Xml (item)");

			var xpath = string.Format(null, "{0}[@{1} = $x]", Tag, Key);
			var node = xml.SelectSingleNode(xpath, new SimpleXsltContext(Value));

			if (node == null)
			{
				var elem = xml.OwnerDocument.CreateElement(Tag);
				elem.SetAttribute(Key, Value);
				xml.AppendChild(elem);
				node = elem;
			}

			WriteObject(node);
		}

		protected override void ProcessRecord()
		{
			if (!_XmlSet) throw new PSArgumentException("Xml is required.");
			if (Xml == null) return;

			foreach (var item in Xml)
				ProcessItem(item);
		}
	}
}
