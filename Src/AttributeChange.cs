
// Copyright (c) 2015-2016 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

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
