package;

class Cache
{
	public static var images:Array<Bitmap>;
	public static var audio:Array<FlxSound>;

	public static function cacheImages(?folders:Array<String>) {}

	public static function cacheAudio(?folders:Array<String>) {}
}
