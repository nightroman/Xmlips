
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

using System.Management.Automation;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommon.Remove, "Xml")]
	public sealed class RemoveXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0, ValueFromPipeline = true)]
		public XmlNode[] Xml
		{
			get { return _Xml; }
			set
			{
				_Xml = value;
				_XmlSet = true;
			}
		}
		XmlNode[] _Xml;
		bool _XmlSet;

		protected override void ProcessRecord()
		{
			if (!_XmlSet) throw new PSArgumentException("Xml is required.");
			if (Xml == null) return;

			foreach(var node in Xml)
			{
				if (node == null) throw new PSArgumentNullException("Xml (item)");
				var attr = node as XmlAttribute;
				if (attr == null)
				{
					node.ParentNode.RemoveChild(node);
				}
				else
				{
					attr.OwnerElement.Attributes.Remove(attr);
				}
			}
		}
	}
}
