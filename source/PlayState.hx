package;

import Judgement.Rating;
import beatcode.Conductor;
import beatcode.RythmState;
import charting.ChartingState;
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
	public static var chart:Chart = null;

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

		thing = new FlxSprite(0, 0).makeGraphic(FlxG.width, 60);
		thing.screenCenter();

		add(thing);
		trace(thing);

		for (i in notes)
		{
			var note = new Note(i[0], i[1]);
			noteGroup.add(note);
			// trace(note);
		}

		// trace(notes);

		songLoaded = true;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		controls.update();

		if (FlxG.keys.justPressed.ENTER)
			changeState(new ChartingState(null));

		if (songLoaded)
		{
			hitNote();
			noteGroup.forEachAlive(function(note:Note)
			{
				note.x = thing.x;
				note.y = (thing.y - (Conductor.songPos - note.songTime) * (0.45 * FlxMath.roundDecimal(chart.speed, 2)));
			});
		}
	}

	function hitNote()
	{
		noteGroup.forEachAlive(function(note:Note)
		{
			var canHit:Bool = false;
			var early:Bool = true;
			if (note.overlaps(thing))
			{
				canHit = true;
				early = false;
			}

			var lateMissCondition = note.y < thing.y * .80;
			var earlyMissCondition = note.y < thing.y * 1.20 && note.y > thing.y * 1.22;

			if (canHit)
			{
				switch (note.data)
				{
					case 0:
						if (controls.left_p)
						{
							if (!earlyMissCondition)
								noteHit(note);
						}
					case 1:
						if (controls.down_p)
						{
							if (!earlyMissCondition)
								noteHit(note);
						}
					case 2:
						if (controls.up_p)
						{
							if (!earlyMissCondition)
								noteHit(note);
						}
					case 3:
						if (controls.right_p)
						{
							if (!earlyMissCondition)
								noteHit(note);
						}
				}
			}
		});
	}

	function noteHit(note:Note)
	{
		if (getDataFromKeyPress() == note.data)
		{
			var timeDiff = Math.abs(Conductor.songPos - note.songTime);

			if (timeDiff >= 210)
			{
				noteMiss(note);
				return;
			}

			var score:Int = 0;
			var rating:Rating = Judgement.calculate(timeDiff);
			var missed:Bool = false;

			trace('infos:\ndiff: $timeDiff', '\nrating: $rating');

			// not really  a legit ntoe miss, just to destroy the note
			noteMiss(note);
		}
	}

	function deleteNote(note:Note)
	{
		note.kill();
		noteGroup.remove(note, true);
		note.destroy();
	}

	function noteMiss(note:Note)
	{
		deleteNote(note);
		score -= Math.abs(Conductor.songPos - note.songTime) / 3;
	}

	function getDataFromKeyPress()
	{
		if (controls.left_p)
			return 0;
		if (controls.down_p)
			return 1;
		if (controls.up_p)
			return 2;
		if (controls.right_p)
			return 3;
		return -1;
	}

	public function changeState(newState:RythmState, clearChart:Bool = true)
	{
		if (clearChart)
			chart = null;
		FlxG.switchState(newState);
	}
}
