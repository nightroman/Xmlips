
// Copyright (c) 2015-2016 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System.Management.Automation;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommon.New, "Xml")]
	[OutputType(typeof(XmlElement))]
	public sealed class NewXmlCommand : PSCmdlet
	{
		protected override void BeginProcessing()
		{
			var document = new XmlDocument();
			var root = document.CreateElement("root");
			WriteObject(root);
		}
	}
}
