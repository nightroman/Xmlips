
// Copyright (c) 2015-2016 Roman Kuzmin
// http://www.apache.org/licenses/LICENSE-2.0

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
