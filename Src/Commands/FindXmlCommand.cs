
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

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

		XmlNode GetElement(XmlElement xml)
		{
			if (xml == null) throw new PSArgumentNullException("Xml (item)");

			foreach (XmlNode it in xml.ChildNodes)
			{
				if (it.Name == Tag && it.NodeType == XmlNodeType.Element && ((XmlElement)it).GetAttribute(Key) == Value)
					return it;
			}

			var elem = xml.OwnerDocument.CreateElement(Tag);
			elem.SetAttribute(Key, Value);
			xml.AppendChild(elem);
			return elem;
		}

		protected override void ProcessRecord()
		{
			if (!_XmlSet) throw new PSArgumentException("Xml is required.");
			if (Xml == null) return;

			foreach (var item in Xml)
				WriteObject(GetElement(item));
		}
	}
}
