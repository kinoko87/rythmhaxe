package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Note extends FlxSprite
{
	public var songTime:Float;
	public var data:Int;

	public var hit:Bool = false;
	public var prevNote:Note;

	public function new(songTime:Float, data:Int)
	{
		super(0, 0);

		if (prevNote == null)
			prevNote = this;

		this.songTime = songTime;
		this.data = data;
		loadGraphic(Paths.image('rythm_objects/arrow'));
		setGraphicSize(40, 40);
		antialiasing = false;
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
