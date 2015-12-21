
// Copyright (c) 2015 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System;
using System.Globalization;
using System.Xml.XPath;
using System.Xml.Xsl;

namespace Xmlips
{
	class XsltContextVariable : IXsltContextVariable
	{
		readonly object _value;
		readonly XPathResultType _type;
		public XsltContextVariable(object value)
		{
			// unwrap and keep
			_value = value = PS.BaseObject(value);

			if (value is String)
			{
				_type = XPathResultType.String;
				return;
			}

			if (value is double || value is int || value is long)
			{
				_type = XPathResultType.Number;
				return;
			}

			if (value is bool)
			{
				_type = XPathResultType.Boolean;
				return;
			}

			if (value is XPathNavigator)
			{
				_type = XPathResultType.Navigator;
				return;
			}

			if (value is XPathNodeIterator)
			{
				_type = XPathResultType.NodeSet;
				return;
			}

			if (!(value is IConvertible))
			{
				_type = XPathResultType.Any;
				return;
			}

			try
			{
				_value = Convert.ToDouble(value, CultureInfo.InvariantCulture);
				_type = XPathResultType.Number;
			}
			catch
			{
				_type = XPathResultType.Any;
			}
		}
		public XPathResultType VariableType
		{
			get { return _type; }
		}
		public object Evaluate(XsltContext context)
		{
			return _value;
		}
		public bool IsLocal
		{
			get { return false; }
		}
		public bool IsParam
		{
			get { return false; }
		}
	}
}
