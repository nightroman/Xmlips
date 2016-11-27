
// Copyright (c) 2015-2016 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System.Management.Automation;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommon.Copy, "Xml")]
	public sealed class CopyXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0)]
		public XmlElement Source { get; set; }

		[Parameter(Position = 1)]
		public XmlElement Target { get; set; }

		protected override void BeginProcessing()
		{
			if (Source == null) throw new PSArgumentNullException("Source");
			if (Target == null) throw new PSArgumentNullException("Target");

			var xml1 = Source.InnerXml;
			var xml2 = Target.InnerXml;
			if (xml1 != xml2)
				Target.InnerXml = xml1;
		}
	}
}
