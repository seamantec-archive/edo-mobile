using System;
using com.sailing.units;

namespace com.sailing.datas
{
	partial class BaseSailData
	{
		public Unit this [string key] {
			get {
				return new Unit ();
			}
		}
	}
}

