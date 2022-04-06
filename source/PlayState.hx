package;

import beatcode.Conductor;
import beatcode.RythmState;
import data.Charts.Chart;
import data.Charts.OldChart;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
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

	public function new()
	{
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

	// * fnf hit detection for now lmao
	function onHit(note:Note)
	{
		var noteDiff:Float = Math.abs(note.songTime - Conductor.songPos);
		var noteScore:Float = 300;
		var noteRating:String = "amazing";

		if (noteDiff > Conductor.safeZoneOffset)
		{
			noteRating = "miss";
			noteScore = -25;
			results.misses++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			noteRating = "shit";
			noteScore = 10;
			results.shits++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			noteRating = "bad";
			noteScore = 25;
			results.bads++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.5)
		{
			noteRating = "okay";
			noteScore = 75;
			results.okays++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			noteRating = "good";
			noteScore = 150;
			results.goods++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.1)
		{
			noteRating = "amazing";
			noteScore = 300;
			results.amazings++;
		}

		score += noteScore;
		trace('rating: ' + noteRating + '\nscore: ' + noteScore);

		if (noteRating != "miss")
			combo++;
		else
			combo = 0;

		FlxG.watch.addQuick("combo: ", combo);
	}

	public function changeState(newState:RythmState, clearChart:Bool = true)
	{
		if (clearChart)
			chart = null;
		FlxG.switchState(newState);
	}
}
