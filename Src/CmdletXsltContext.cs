
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Xml.XPath;
using System.Xml.Xsl;

namespace Xmlips
{
	class CmdletXsltContext : BaseXsltContext
	{
		readonly PSCmdlet _cmdlet;
		readonly Dictionary<string, XsltContextVariable> _variables = new Dictionary<string, XsltContextVariable>(StringComparer.OrdinalIgnoreCase);

		//TODO name table?
		public CmdletXsltContext(PSCmdlet cmdlet)
		{
			_cmdlet = cmdlet;
		}

		public override IXsltContextVariable ResolveVariable(string prefix, string name)
		{
			if (!string.IsNullOrEmpty(prefix))
				return null;

			XsltContextVariable xsltVariable;
			if (!_variables.TryGetValue(name, out xsltVariable))
			{
				var psVariable = _cmdlet.SessionState.PSVariable.Get(name);
				if (psVariable == null)
					throw new InvalidOperationException(string.Format(null, "Variable '{0}' is not found.", name));

				xsltVariable = new XsltContextVariable(psVariable.Value);
				_variables.Add(name, xsltVariable);
			}
			return xsltVariable;
		}
	}
}
