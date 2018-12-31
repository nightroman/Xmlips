
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

using System.Xml;

namespace Xmlips
{
	class AttributeChange
	{
		public string Attribute { get; internal set; }
		public string OldValue { get; internal set; }
		public string NewValue { get; internal set; }
		public XmlElement Element { get; internal set; }
	}
}
