package data;

import flixel.input.keyboard.FlxKey;

typedef Keybind =
{
	var Up:FlxKey;
	var Left:FlxKey;
	var Right:FlxKey;
	var Down:FlxKey;
}

enum abstract ScrollType(Int) from Int to Int
{
	var Downscroll:Int = 0;
	var Upscroll:Int = 1;
	var CustomFromFile:Int = 2;
}

enum abstract GraphicsType(Int) from Int to Int
{
	var VeryLow:Int = 0;
	var Low:Int = 1;
	var Medium:Int = 2;
	var High:Int = 3;
}

class Settings
{
	public static var keybinds:Keybind;
	public static var scrollType:ScrollType;
	public static var graphics:GraphicsType;

	private static var _settings:Dynamic;
}
