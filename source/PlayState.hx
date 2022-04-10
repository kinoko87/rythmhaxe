package;

import beatcode.Conductor;
import beatcode.RythmState;
import controls.KeyboardController;
import data.Charts.Chart;
import data.Charts.OldChart;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;

typedef GameResult =
{
	var misses:Int;
	var shits:Int;
	var bads:Int;
	var okays:Int;
	var goods:Int;
	var amazings:Int;
	var score:Int;
	var marvelous:Int;
	var perfects:Int;
	var rating:String;
}

class PlayState extends RythmState
{
	public static var chart:Chart;

	public var score:Float = 0;
	public var combo:Int = 0;

	public var songName:String;
	public var speed:Float;
	public var notes:Array<Array<Dynamic>>;

	public var noteGroup:FlxTypedGroup<Note>;

	public var thing:FlxSprite;

	public var results:GameResult;

	public var health:Float = 100;

	public var controls:Controller;

	public function new()
	{
		controls = new Controller("controls");
		super();
		if (chart == null)
			chart = cast Json.parse(Assets.getText('assets/data/leJson.json'));
		speed = chart.speed;
		Conductor.bpm = chart.bpm;
		songName = chart.name;
		notes = chart.notes;

		results = {
			misses: 0,
			shits: 0,
			bads: 0,
			okays: 0,
			goods: 0,
			amazings: 0,
			score: 0,
			marvelous: 0,
			perfects: 0,
			rating: "Uncalculated"
		};
	}

	var songLoaded:Bool = false;

	override function create()
	{
		FlxG.sound.playMusic('assets/music/blammed.ogg');

		noteGroup = new FlxTypedGroup<Note>();

		add(noteGroup);

		thing = new FlxSprite(0, 0).makeGraphic(FlxG.width, 25);
		thing.screenCenter();

		add(thing);
		trace(thing);

		for (i in notes)
		{
			var note = new Note(i[0], i[1]);
			noteGroup.add(note);
			trace(note);
		}

		trace(notes);

		songLoaded = true;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (songLoaded)
		{
			noteGroup.forEachAlive(function(note:Note)
			{
				note.x = thing.x;
				note.y = (thing.y - (Conductor.songPos - note.songTime) * (0.45 * FlxMath.roundDecimal(chart.speed, 2)));
			});
		}
	}

	function hitNote(note:Note)
	{
		var data = -1;
		if (controls.left_p)
		{
			data = 0;
		}
		else if (controls.down_p)
		{
			data = 1;
		}
		else if (controls.up_p)
		{
			data = 2;
		}
		else if (controls.left_p)
		{
			data = 3;
		}
		if (controls.up_p || controls.down_p || controls.left_p || controls.right_p) {}
	}

	// * fnf hit detection for now lmao
	function onHit(note:Note, intendedData:Int)
	{
		var noteDiff = Math.abs(Conductor.songPos - note.songTime);
		var noteYDiff = Math.abs(thing.y - note.y);

		var score:Int = 0;
		var rating:String = "uncalculated";
		var missed:Bool = false;

		if (intendedData != note.data)
			missed = true;
		#if debug
		if (missed)
			note.color = FlxColor.RED;
		#end
	}

	public function changeState(newState:RythmState, clearChart:Bool = true)
	{
		if (clearChart)
			chart = null;
		FlxG.switchState(newState);
	}
}
