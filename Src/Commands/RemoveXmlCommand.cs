
// Copyright (c) 2015 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System.Management.Automation;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommon.Remove, "Xml")]
	public sealed class RemoveXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0, ValueFromPipeline = true)]
		public XmlNode[] Xml { get; set; }

		protected override void ProcessRecord()
		{
			if (Xml == null)
				return;

			foreach(var node in Xml)
				node.ParentNode.RemoveChild(node);
		}
	}
}
