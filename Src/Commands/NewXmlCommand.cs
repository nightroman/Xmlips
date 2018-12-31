
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

using System.Management.Automation;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommon.New, "Xml")]
	[OutputType(typeof(XmlElement))]
	public sealed class NewXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0)]
		public string Tag { get; set; }

		[Parameter(Position = 1)]
		public string[] Attribute { get; set; }

		protected override void BeginProcessing()
		{
			var tag = string.IsNullOrEmpty(Tag) ? "root" : Tag;
			var xml = (new XmlDocument()).CreateElement(tag);

			if (Attribute != null)
			{
				// attribute name/value pairs
				for (int i = 1; i < Attribute.Length; i += 2)
				{
					var name = Attribute[i - 1];
					if (string.IsNullOrEmpty(name)) throw new PSArgumentException("Parameter Attribute contains null or empty name.", "Attribute");

					var value = Attribute[i];
					xml.SetAttribute(name, value);
				}

				// text as the last odd item
				if (Attribute.Length % 2 == 1)
				{
					var value = Attribute[Attribute.Length - 1];
					xml.InnerText = value;
				}
			}

			WriteObject(xml);
		}
	}
}
