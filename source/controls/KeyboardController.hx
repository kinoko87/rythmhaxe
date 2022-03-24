package controls;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionSet;
import flixel.input.keyboard.FlxKey;
import haxe.ds.StringMap;

enum abstract Action(String) from String to String
{
	var Up:String = "up";
	var Left:String = "left";
	var Right:String = "right";
	var Down:String = "down";
	var Up_P:String = "up-pressed";
	var Left_P:String = "left-pressed";
	var Right_P:String = "right-pressed";
	var Down_P:String = "down-pressed";
	var Up_R:String = "up-released";
	var Left_R:String = "left-released";
	var Right_R:String = "right-released";
	var Down_R:String = "down-released";
	var PauseSong:String = "pause-song";
	var PauseGame:String = "pause";
	var Accept:String = "accept";
	var Back:String = "back";
}

class Controller extends FlxActionSet
{
	private var _up:FlxActionDigital;
	private var _left:FlxActionDigital;
	private var _right:FlxActionDigital;
	private var _down:FlxActionDigital;
	private var _upP:FlxActionDigital;
	private var _leftP:FlxActionDigital;
	private var _rightP:FlxActionDigital;
	private var _downP:FlxActionDigital;
	private var _upR:FlxActionDigital;
	private var _leftR:FlxActionDigital;
	private var _rightR:FlxActionDigital;
	private var _downR:FlxActionDigital;
	private var _pauseSong:FlxActionDigital;
	private var _pauseGame:FlxActionDigital;
	private var _accept:FlxActionDigital;
	private var _back:FlxActionDigital;

	public var up:Bool;
	public var left:Bool;
	public var right:Bool;
	public var down:Bool;
	public var up_p:Bool;
	public var left_p:Bool;
	public var right_p:Bool;
	public var down_p:Bool;
	public var up_r:Bool;
	public var left_r:Bool;
	public var right_r:Bool;
	public var down_r:Bool;
	public var pause_song:Bool;
	public var pause_game:Bool;
	public var accept:Bool;
	public var back:Bool;

	public function new(name:String)
	{
		super(name);
		generateActions();
	}

	private function generateActions()
	{
		addDigitalAction(_up, Up, [UP, W], PRESSED);
		addDigitalAction(_left, Left, [LEFT, A], PRESSED);
		addDigitalAction(_right, Right, [RIGHT, D], PRESSED);
		addDigitalAction(_down, Down, [DOWN, S], PRESSED);
		addDigitalAction(_upP, Up_P, [UP, W]);
		addDigitalAction(_leftP, Left_P, [LEFT, A]);
		addDigitalAction(_rightP, Right_P, [RIGHT, D]);
		addDigitalAction(_downP, Down_P, [DOWN, S]);
		addDigitalAction(_upR, Up_R, [UP, W], JUST_RELEASED);
		addDigitalAction(_leftR, Left_R, [LEFT, A], JUST_RELEASED);
		addDigitalAction(_rightR, Right_R, [RIGHT, D], JUST_RELEASED);
		addDigitalAction(_downR, Down_R, [DOWN, S], JUST_RELEASED);
		addDigitalAction(_pauseSong, PauseSong, [SPACE], JUST_PRESSED);
		addDigitalAction(_pauseGame, PauseGame, [ESCAPE], JUST_PRESSED);
		addDigitalAction(_accept, Accept, [ENTER], JUST_PRESSED);
		addDigitalAction(_back, Back, [BACKSPACE, ESCAPE], JUST_PRESSED);

		return digitalActions;
	}

	private function generateChecks()
	{
		up = _up.check();
		left = _left.check();
		right = _right.check();
		down = _down.check();
		up_p = _upP.check();
		left_p = _leftP.check();
		right_p = _rightP.check();
		down_p = _downP.check();
		up_r = _upR.check();
		left_r = _leftR.check();
		right_r = _rightR.check();
		down_r = _downR.check();
		pause_song = _pauseSong.check();
		pause_game = _pauseGame.check();
		accept = _accept.check();
		back = _back.check();
	}

	public override function update()
	{
		generateChecks();
		super.update();
	}

	private function addDigitalAction(action:FlxActionDigital, name:String, ?keys:Array<FlxKey>, ?inputState:FlxInputState = JUST_PRESSED)
	{
		if (action != null)
		{
			if (digitalActions.contains(action))
				remove(action);
			action = null;
		}
		action = new FlxActionDigital(name);
		add(action);

		if (keys != null && keys.length > 0)
		{
			for (i in keys)
				action.addKey(i, inputState);
		}

		return action;
	}
}
