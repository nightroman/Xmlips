
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

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
		public XmlReaderSettings Settings { get; set; }

		[Parameter]
		public SwitchParameter Backup { get; set; }

		protected override void BeginProcessing()
		{
			Path = GetUnresolvedProviderPathFromPSPath(Path);

			var xml = new FileXmlDocument(Path, Content, Backup, Settings);

			WriteObject(xml.DocumentElement);
		}
	}
}
