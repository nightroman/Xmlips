
// Copyright (c) 2015 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System.Management.Automation;
using System.Xml;

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
		public SwitchParameter Fragment { get; set; }

		[Parameter]
		public SwitchParameter Backup { get; set; }

		protected override void BeginProcessing()
		{
			Path = GetUnresolvedProviderPathFromPSPath(Path);

			if (Fragment)
			{
				var document = new XmlDocument();

				var settings = new XmlReaderSettings();
				settings.ConformanceLevel = ConformanceLevel.Fragment;

				using (var reader = XmlReader.Create(Path, settings))
				{
					XmlNode node;
					while ((node = document.ReadNode(reader)) != null)
					{
						if (node.NodeType == XmlNodeType.Element)
							WriteObject(node);
					}
				}
			}
			else
			{
				WriteObject(new FileXmlDocument(Path, Content, Backup));
			}
		}
	}
}
