package;

import beatcode.Conductor;
import beatcode.RythmState;
import data.Charts.Chart;
import data.Charts.OldChart;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import haxe.Json;
import lime.utils.Assets;

class PlayState extends RythmState
{
	public var chart:Chart;

	public var songName:String;
	public var speed:Float;
	public var notes:Array<Array<Dynamic>>;

	public var noteGroup:FlxTypedGroup<Note>;

	public var thing:FlxObject;

	public function new()
	{
		super();
		chart = cast Json.parse(Assets.getText('assets/data/leJson.json'));
		speed = chart.speed;
		Conductor.bpm = chart.bpm;
		songName = chart.name;
		notes = chart.notes;
	}

	var musicGenned:Bool = false;

	override function create()
	{
		FlxG.sound.playMusic('assets/music/blammed.ogg');

		noteGroup = new FlxTypedGroup<Note>();

		add(noteGroup);

		thing = new FlxObject(0, 0, 1, 1);
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

		musicGenned = true;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (musicGenned)
		{
			noteGroup.forEachAlive(function(note:Note)
			{
				note.x = thing.x;
				note.y = (thing.y + (Conductor.songPos - note.songTime) * (0.45 * FlxMath.roundDecimal(chart.speed, 2)));
			});
		}
	}
}
