
// Copyright (c) 2015 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System.Collections;
using System.Management.Automation;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommon.Set, "Xml")]
	public sealed class SetXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0)]
		public string[] Attribute { get; set; }

		[Parameter(Position = 1, ValueFromPipeline = true)]
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

		[Parameter]
		public SwitchParameter Changed { get; set; }

		protected override void BeginProcessing()
		{
			if (Attribute == null) throw new PSArgumentNullException("Attribute");
			if (Attribute.Length == 0) throw new PSArgumentException("Parameter Attribute must not be empty.", "Attribute");
			if (Attribute.Length % 2 != 0) throw new PSArgumentException("Parameter Attribute must contain even number of items.", "Attribute");
			for (int i = Attribute.Length; (i -= 2) >= 0;)
				if (string.IsNullOrEmpty(Attribute[i])) throw new PSArgumentException("Parameter Attribute contains null or empty name.", "Attribute");
		}

		void ProcessItem(XmlElement xml)
		{
			if (xml == null) throw new PSArgumentNullException("Xml (item)");

			for (int i = 0; i < Attribute.Length; i += 2)
			{
				var attribute = Attribute[i];
				var newValue = Attribute[i + 1];
				if (Changed)
				{
					var oldValue = xml.GetAttribute(attribute);
					if (oldValue == newValue)
						continue;
					WriteObject(new AttributeChange() {
						Attribute = attribute,
						OldValue = oldValue,
						NewValue = newValue,
						Element = xml
					});
				}
				xml.SetAttribute(attribute, newValue);
			}
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
