
// Copyright (c) 2015 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System.Xml.Xsl;

namespace Xmlips
{
	class SimpleXsltContext : BaseXsltContext
	{
		readonly XsltContextVariable _value;
		public SimpleXsltContext(string value)
		{
			_value = new XsltContextVariable(value);
		}
		public override IXsltContextVariable ResolveVariable(string prefix, string name)
		{
			return _value;
		}
	}
}
