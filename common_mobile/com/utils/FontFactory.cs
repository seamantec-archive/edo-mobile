using System;
using System.IO;
using flash.utils;

namespace com.utils
{
	partial class FontFactory
	{
		public static ByteArray loadDigitalFont (string path)
		{
			FileStream stream = new FileStream (path, FileMode.Open, FileAccess.Read);
			byte[] buffer = new byte[stream.Length];
			ByteArray ba = new ByteArray ();
			ba.writeBytes (buffer);
			ba.position = 0;
			return ba;
		}
	}
}

