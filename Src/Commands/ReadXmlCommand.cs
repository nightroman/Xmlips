
// Copyright (c) 2015-2016 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System.Management.Automation;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommunications.Read, "Xml")]
	[OutputType(typeof(XmlElement))]
	public sealed class ReadXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0, Mandatory = true)]
		public string Path { get; set; }

		[Parameter, ValidateNotNullOrEmpty]
		public string Content { get; set; }

		[Parameter]
		public SwitchParameter Backup { get; set; }

		protected override void BeginProcessing()
		{
			Path = GetUnresolvedProviderPathFromPSPath(Path);

			var xml = new FileXmlDocument(Path, Content, Backup);

			WriteObject(xml.DocumentElement);
		}
	}
}
