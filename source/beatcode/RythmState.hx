package beatcode;

import flixel.FlxState;

class RythmState extends FlxState
{
	public var curStep:Int;
	public var curBeat:Int;

	public function new()
	{
		super();
		#if debug
		if (!FlxG.debugger.drawDebug)
			FlxG.debugger.drawDebug = true;
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var oldStep:Int = curStep;

		updateCurStep();
		updateCurBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();
	}

	public function stepHit()
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit() {}

	private function updateCurStep()
	{
		curStep = Math.floor(Conductor.songPos / Conductor.songLen);
	}

	public function updateCurBeat()
	{
		curBeat = Math.floor(curStep / 4);
	}
}
