
// Xmlips - XML in PowerShell
// Copyright (c) Roman Kuzmin

using System.Management.Automation;

namespace Xmlips
{
	static class PS
	{
		public static object BaseObject(object value)
		{
			if (value == null)
				return null;
			var ps = value as PSObject;
			return ps == null ? value : ps.BaseObject;
		}
	}
}
