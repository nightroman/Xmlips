
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

using System.IO;
using System.Xml;

namespace Xmlips
{
	class FileXmlDocument : XmlDocument
	{
		public bool IsNew { get; private set; }
		public bool IsChanged { get; private set; }
		public string FileName { get; private set; }
		bool _backup;

		public FileXmlDocument(string fileName, string content, bool backup)
		{
			FileName = Path.GetFullPath(fileName);
			try
			{
				Load(FileName);
				_backup = backup;
				AddChangeHandlers();
			}
			catch (FileNotFoundException)
			{
				if (content == null)
					throw;

				LoadXml(content);
				IsNew = IsChanged = true;
			}
		}

		void AddChangeHandlers()
		{
			NodeChanged += OnChanged;
			NodeRemoved += OnChanged;
			NodeInserted += OnChanged;
		}

		void RemoveChangeHandlers()
		{
			NodeChanged -= OnChanged;
			NodeRemoved -= OnChanged;
			NodeInserted -= OnChanged;
		}

		void OnChanged(object sender, XmlNodeChangedEventArgs e)
		{
			IsChanged = true;
			RemoveChangeHandlers();
		}

		internal void Save()
		{
			if (!IsChanged)
				return;

			var tmp = FileName + ".tmp";
			Save(tmp);

			if (IsNew)
				File.Move(tmp, FileName);
			else if (!_backup)
				File.Replace(tmp, FileName, null);
			else
				File.Replace(tmp, FileName, FileName + ".bak");

			IsChanged = false;
			AddChangeHandlers();
		}
	}
}
