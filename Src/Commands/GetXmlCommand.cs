
// Copyright (c) 2015-2016 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.XPath;

namespace Xmlips.Commands
{
	[Cmdlet(VerbsCommon.Get, "Xml")]
	[OutputType(typeof(XmlElement))]
	public sealed class GetXmlCommand : PSCmdlet
	{
		[Parameter(Position = 0)]
		public string XPath { get; set; }

		[Parameter(Position = 1, ValueFromPipeline = true)]
		public XmlNode[] Xml
		{
			get { return _Xml; }
			set
			{
				_Xml = value;
				_XmlSet = true;
			}
		}
		XmlNode[] _Xml;
		bool _XmlSet;

		[Parameter]
		public IDictionary Namespace { get; set; }

		[Parameter]
		public SwitchParameter Single { get; set; }

		[Parameter]
		public object[] Property { get; set; }

		CmdletXsltContext _context;
		List<XPathProperty> _expressions;

		class XPathProperty
		{
			public string Name;
			public XPathExpression Expression;
			public Type Type;
		}

		protected override void BeginProcessing()
		{
			if (string.IsNullOrEmpty(XPath)) throw new PSArgumentNullException("XPath");

			_context = new CmdletXsltContext(this);

			if (Namespace != null)
			{
				foreach (DictionaryEntry kv in Namespace)
				{
					var prefix = kv.Key.ToString();
					var uri = kv.Value.ToString();
					_context.AddNamespace(prefix, uri);
				}
			}

			if (Property != null)
			{
				_expressions = new List<XPathProperty>();
				foreach (var it in Property)
				{
					var select = PS.BaseObject(it);

					var dic = select as IDictionary;
					if (dic != null)
					{
						if (dic.Count != 1)
							throw new PSArgumentException("Parameter Property dictionary must contain 1 key/value.");

						foreach (DictionaryEntry kv in dic)
						{
							var name = kv.Key.ToString();
							var xpath = kv.Value as string;
							if (xpath != null)
							{
								_expressions.Add(new XPathProperty() { Name = name, Expression = XPathExpression.Compile(xpath, _context) });
								break;
							}

							var list = kv.Value as IList;
							if (list == null || list.Count != 2)
								throw new PSArgumentException("Parameter Property dictionary value must be string or array with 2 items.");

							var type = list[1] as Type;
							if (type == null)
								throw new PSArgumentException("Parameter Property dictionary value second item must be Type.");

							xpath = list[0].ToString();
							_expressions.Add(new XPathProperty() { Name = name, Expression = XPathExpression.Compile(xpath, _context), Type = type });
							break;
						}
						continue;
					}

					var str = select as string;
					if (str == null)
						throw new PSArgumentException("Parameter Property item must be string or dictionary.");

					_expressions.Add(new XPathProperty() { Name = str, Expression = XPathExpression.Compile(str, _context) });
				}
			}
		}

		void WriteItem(XmlNode xml)
		{
			//_160102_015732
			if (xml == null)
				return;

			if (Property == null)
			{
				WriteObject(xml);
				return;
			}

			var ps = new PSObject();
			var properties = ps.Properties;
			var navigator = xml.CreateNavigator();
			foreach (var info in _expressions)
			{
				var result = navigator.Evaluate(info.Expression);
				var iter = result as XPathNodeIterator;
				if (iter != null)
				{
					if (iter.Count == 1)
					{
						iter.MoveNext();
						result = iter.Current.Value;
					}
					else
					{
						var results = new ArrayList();
						while (iter.MoveNext())
							results.Add(iter.Current.Value);
						result = results;
					}
				}

				if (info.Type != null)
				{
					try
					{
						result = LanguagePrimitives.ConvertTo(result, info.Type);
					}
					catch (PSInvalidCastException e)
					{
						throw new PSArgumentException(string.Format(null, @"Property name ""{0}"": {1}", info.Name, e.Message));
					}
				}

				properties.Add(new PSNoteProperty(info.Name, result));
			}

			WriteObject(ps);
		}

		static string _errProcessItem = "XPath problem? Ensure namespace prefixes are defined.";
		void ProcessItem(XmlNode xml)
		{
			if (xml == null) throw new PSArgumentNullException("Xml (item)");

			try
			{
				if (Single)
				{
					WriteItem(xml.SelectSingleNode(XPath, _context));
				}
				else
				{
					foreach (XmlNode node in xml.SelectNodes(XPath, _context))
						WriteItem(node);
				}
			}
			catch (ArgumentNullException e)
			{
				//_160102_022718
				throw new InvalidOperationException(_errProcessItem, e);
			}
			catch (NullReferenceException e)
			{
				//_160102_013934
				throw new InvalidOperationException(_errProcessItem, e);
			}
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
