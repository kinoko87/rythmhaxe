package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

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
		y += 2000;
		setColorByData(data);
	}

	public function setColorByData(data:Int)
	{
		switch (data)
		{
			case 0 | 3:
				color = FlxColor.BLUE;
			case 1 | 2:
				color = FlxColor.WHITE;
		}
	}
}
