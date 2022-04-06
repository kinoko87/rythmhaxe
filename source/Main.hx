package;

import charting.ChartingState;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.Sprite;

class Main extends Sprite
{
	public var targetState:Class<FlxState>;

	public function new()
	{
		super();

		#if debug
		targetState = ChartingState;
		#end

		addChild(new FlxGame(0, 0, targetState));
	}
}
