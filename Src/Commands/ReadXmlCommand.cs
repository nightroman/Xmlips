
// Copyright (c) 2015-2016 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System.Management.Automation;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommunications.Read, "Xml")]
	[OutputType(typeof(FileXmlDocument))]
	public sealed class ReadXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0, Mandatory = true)]
		public string Path { get; set; }

		[Parameter]
		public string Content { get; set; }

		[Parameter]
		public SwitchParameter Backup { get; set; }

		protected override void BeginProcessing()
		{
			Path = GetUnresolvedProviderPathFromPSPath(Path);
			WriteObject(new FileXmlDocument(Path, Content, Backup));
		}
	}
}
