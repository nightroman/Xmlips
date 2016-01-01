
// Copyright (c) 2015-2016 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System;
using System.IO;
using System.Management.Automation;
using System.Text;
using System.Xml;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsData.Export, "Xml")]
	public sealed class ExportXmlCommand : PSCmdlet, IDisposable
	{
		[Parameter(Position = 0, Mandatory = true)]
		public string Path { get; set; }

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
		public SwitchParameter Append { get; set; }

		FileStream _stream;
		XmlTextWriter _writer;

		public void Dispose()
		{
			if (_writer != null)
				_writer.Close();
			if (_stream != null)
				_stream.Close();
		}

		protected override void BeginProcessing()
		{
			Path = GetUnresolvedProviderPathFromPSPath(Path);

			_stream = new FileStream(Path, Append ? FileMode.Append : FileMode.Create, FileAccess.Write, FileShare.Read);
			_writer = new XmlTextWriter(_stream, Encoding.UTF8);
		}

		void ProcessItem(XmlElement xml)
		{
			if (xml == null) throw new PSArgumentNullException("Xml (item)");

			xml.WriteTo(_writer);
			_writer.WriteWhitespace("\r\n");
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
