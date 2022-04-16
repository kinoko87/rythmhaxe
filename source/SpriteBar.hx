package;

import flixel.FlxSprite;
import flixel.ui.FlxBar;

class SpriteBar extends FlxBar
{
	public var sprite:FlxSprite;

	public function new(x:Float, y:Float, assetPath:String, direction:FlxBarFillDirection, width:Int, height:Int, min:Float = 0, max:Float = 100,
			showBorder:Bool = false)
	{
		super(x, y, direction, width, height, min, max);
		sprite = new FlxSprite(x, y, assetPath);
	}

	override function draw()
	{
		super.draw();

		if (percent > 0)
		{
			sprite.x = (width * (percent / 100));
		}
	}
}
