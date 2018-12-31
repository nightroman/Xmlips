
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

using System.Management.Automation;
using System.IO;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsData.Import, "Xml", DefaultParameterSetName = "Path")]
	[OutputType(typeof(XmlElement))]
	public sealed class ImportXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0, Mandatory = true, ParameterSetName = "Path")]
		public string Path { get; set; }

		[Parameter(Mandatory = true, ParameterSetName = "Content")]
		public string[] Content { get; set; }

		void Read(XmlReader reader)
		{
			var document = new XmlDocument();
			var root = document.CreateElement("root");

			XmlNode node;
			while ((node = document.ReadNode(reader)) != null)
			{
				if (node.NodeType == XmlNodeType.Element)
					root.AppendChild(node);
			}
			WriteObject(root);
		}

		protected override void BeginProcessing()
		{
			var settings = new XmlReaderSettings();
			settings.ConformanceLevel = ConformanceLevel.Fragment;
			settings.IgnoreComments = true;
			settings.IgnoreWhitespace = true;

			if (ParameterSetName == "Content")
			{
				using (var strReader = new StringReader(string.Join("\n", Content)))
				using (var xmlReader = XmlReader.Create(strReader, settings))
					Read(xmlReader);
			}
			else
			{
				Path = GetUnresolvedProviderPathFromPSPath(Path);
				using (var xmlReader = XmlReader.Create(Path, settings))
					Read(xmlReader);
			}
		}
	}
}
