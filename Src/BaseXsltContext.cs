
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

using System.Xml.XPath;
using System.Xml.Xsl;

namespace Xmlips
{
	abstract class BaseXsltContext : XsltContext
	{
		public override bool Whitespace
		{
			get { return true; }
		}
		public override bool PreserveWhitespace(XPathNavigator node)
		{
			return true;
		}
		public override int CompareDocument(string doc1, string doc2)
		{
			return 0;
		}
		public override IXsltContextFunction ResolveFunction(string prefix, string name, XPathResultType[] ArgTypes)
		{
			return null;
		}
	}
}
