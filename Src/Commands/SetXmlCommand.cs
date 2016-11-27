
// Copyright (c) 2015-2016 Roman Kuzmin
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
		public SwitchParameter Change { get; set; }

		[Parameter]
		public SwitchParameter Changed { get; set; }

		protected override void BeginProcessing()
		{
			if (Attribute == null) throw new PSArgumentNullException("Attribute");
			if (Attribute.Length == 0) throw new PSArgumentException("Parameter Attribute must not be empty.", "Attribute");
			for (int i = 1; i < Attribute.Length; i += 2)
				if (string.IsNullOrEmpty(Attribute[i - 1])) throw new PSArgumentException("Parameter Attribute contains null or empty name.", "Attribute");
			if (Changed)
				Change = true;
		}

		void ProcessItem(XmlElement xml)
		{
			if (xml == null) throw new PSArgumentNullException("Xml (item)");

			// attribute name/value pairs
			for (int i = 1; i < Attribute.Length; i += 2)
			{
				var attribute = Attribute[i - 1];
				var newValue = Attribute[i];
				if (Change)
				{
					var oldValue = xml.GetAttribute(attribute);
					if (oldValue == newValue)
						continue;

					if (Changed)
					{
						WriteObject(new AttributeChange()
						{
							Attribute = attribute,
							OldValue = oldValue,
							NewValue = newValue,
							Element = xml
						});
					}
				}
				xml.SetAttribute(attribute, newValue);
			}

			// text as the last odd item
			if (Attribute.Length % 2 == 1)
			{
				var newValue = Attribute[Attribute.Length - 1];
				if (Change)
				{
					var oldValue = xml.InnerText;
					if (oldValue == newValue)
						return;

					if (Changed)
					{
						WriteObject(new AttributeChange()
						{
							Attribute = string.Empty,
							OldValue = oldValue,
							NewValue = newValue,
							Element = xml
						});
					}
				}
				xml.InnerText = newValue;
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
