using System;
using com.sailing.datas;

namespace com.sailing
{
	partial class SailData
	{
		public BaseSailData this [string key] {
			get {
				return (BaseSailData)this.GetType ().GetField (key).GetValue (this);
			}
		}
	}
}

