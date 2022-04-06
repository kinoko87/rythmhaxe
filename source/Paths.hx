package;

import openfl.utils.Assets;
import sys.FileSystem;

class Paths
{
	public static inline function ui(key:String, ?ext:String = 'png')
	{
		return 'assets/images/ui/$key.$ext';
	}

	public static inline function cache(key:String, ?ext:String = 'json')
	{
		return 'cache/$key.$ext';
	}

	public static inline function mod(key:String)
	{
		return 'mods/$key';
	}

	public static inline function plugin(key:String)
	{
		return 'plugins/$key';
	}

	public static inline function music(key:String, ?ext:String = 'ogg')
	{
		return 'assets/music/$key.$ext';
	}

	public static inline function sound(key:String, ?ext:String = 'ogg')
	{
		return 'assets/sound/$key.$ext';
	}

	public static inline function data(key:String, ?ext:String = 'json')
	{
		return 'assets/data/$key.$ext';
	}

	public static inline function exists(path:String)
	{
		return Assets.exists(path);
	}
}
