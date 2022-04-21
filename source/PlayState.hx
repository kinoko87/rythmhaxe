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
import flixel.util.FlxSort;
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

	public var despawnedNotes:Array<Note>;

	var notePos0:Float;
	var notePos1:Float;
	var notePos2:Float;
	var notePos3:Float;

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

		notePos3 = (FlxG.width / 2) - 40 * 3;
		notePos2 = (FlxG.width / 2) - 40 * 2;
		notePos1 = (FlxG.width / 2) - 40 * 1;
		notePos0 = (FlxG.width / 2) - 40 * 0;

		super.create();
	}

	var sorted:Bool = false;

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
				switch (note.data)
				{
					case 0:
						note.x = notePos3;
					case 1:
						note.x = notePos2;
					case 2:
						note.x = notePos1;
					case 3:
						note.x = notePos0;
				}

				if (note.scale.x != 3.3 && note.scale.y != 3.3)
					note.scale.set(3.3, 3.3);

				note.y = (thing.y - (Conductor.songPos - note.songTime) * (0.45 * FlxMath.roundDecimal(chart.speed, 2)));

				if (!sorted)
				{
					noteGroup.sort(FlxSort.byY, FlxSort.DESCENDING);
					sorted = true;

					for (note in 0...noteGroup.members.length)
					{
						if (note != 0)
						{
							var oldNote = noteGroup.members[note - 1];
							var note = noteGroup.members[note];
							note.prevNote = oldNote;
							#if debug
							note.prevNote.color = FlxColor.RED;
							#end
						}
					}
				}
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

			if (canHit)
			{
				switch (note.data)
				{
					case 0:
						if (controls.left_p)
						{
							noteHit(note);
						}
					case 1:
						if (controls.down_p)
						{
							noteHit(note);
						}
					case 2:
						if (controls.up_p)
						{
							noteHit(note);
						}
					case 3:
						if (controls.right_p)
						{
							noteHit(note);
						}
				}
			}
		});
	}

	var previousNote:Note;

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

			var score:Float = Judgement.score(timeDiff);
			var rating:Rating = Judgement.calculate(timeDiff);

			trace('infos:\ndiff: $timeDiff', '\nrating: $rating');

			deleteNote(note);
		}
	}

	function deleteNote(note:Note)
	{
		// note.kill();
		noteGroup.remove(note, true);
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
