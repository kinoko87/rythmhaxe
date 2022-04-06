package beatcode;

import flixel.FlxG;
import flixel.system.FlxSound;

class Conductor
{
	public static var bpm:Int = 100;
	public static var crochet(get, never):Float;
	public static var stepCrochet(get, never):Float;
	public static var songPos(get, never):Float;
	public static var songLen(get, never):Float;
	public static var song(get, never):FlxSound;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset(get, never):Float;

	static function get_crochet():Float
		return 60 / bpm * 1000;

	static function get_stepCrochet():Float
		return crochet / 4;

	static function get_songLen():Float
		return song != null ? song.length : 0;

	static function get_songPos():Float
		return song != null ? song.time : 0;

	static function get_song():FlxSound
		return FlxG.sound.music;

	static function get_safeZoneOffset():Float
	{
		return (safeFrames / 60) * 1000;
	}
}
