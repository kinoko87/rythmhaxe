package;

import flixel.FlxSprite;

class Note extends FlxSprite
{
	public var songTime:Float;
	public var data:Int;

	public function new(songTime:Float, data:Int)
	{
		super(0, 0);
		this.songTime = songTime;
		this.data = data;
		makeGraphic(40, 40);
	}
}
