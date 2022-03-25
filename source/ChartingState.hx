package;

import beatcode.Conductor;
import beatcode.RythmState;
import data.Charts.Chart;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;

class ChartingState extends RythmState
{
	public var chart:Chart;

	private var minY:Float;
	private var maxY:Float;
	private var minTime:Float;
	private var maxTime:Float;
	private var time:Float;

	private var strumLine:FlxSprite;

	private var gridGroup:FlxTypedGroup<FlxSprite>;
	private var noteGroup:FlxTypedGroup<Note>;

	private var divisor:Float = 20;

	private var camFollow:FlxObject;

	private static inline final GRID_SIZE:Int = 40;

	public function new(chart:Chart)
	{
		super();

		if (chart != null)
		{
			this.chart = chart;
			return;
		}

		chart = {
			name: "Test",
			notes: [],
			bpm: 100,
			speed: 1
		}

		this.chart = chart;
	}

	override function create()
	{
		gridGroup = new FlxTypedGroup<FlxSprite>();
		add(gridGroup);
		noteGroup = new FlxTypedGroup<Note>();
		add(noteGroup);

		FlxG.sound.playMusic('assets/music/blammed.ogg');
		Conductor.song.pause();

		generateGrid();

		strumLine = new FlxSprite(0, 0).makeGraphic(FlxG.width, 10, FlxColor.PURPLE);
		strumLine.alpha = .5;
		add(strumLine);

		FlxG.camera.follow(strumLine, LOCKON);

		minY = 0;
		maxY = gridGroup.members[gridGroup.length - 1].y + GRID_SIZE;
		minTime = 0;
		maxTime = Conductor.songLen;
		super.create();
	}

	override function update(elapsed:Float)
	{
		strumLine.y = mapSongPositionToY(Conductor.songPos);

		if (FlxG.keys.justPressed.SPACE)
		{
			if (Conductor.song.playing)
				Conductor.song.pause();
			else
				Conductor.song.play();
		}

		if (FlxG.keys.pressed.W)
		{
			Conductor.song.time -= Conductor.stepCrochet;
		}
		else if (FlxG.keys.pressed.S)
		{
			Conductor.song.time += Conductor.stepCrochet;
		}

		if (FlxG.keys.justPressed.ENTER)
			FlxG.switchState(new PlayState());

		var oldCamPosition = new FlxPoint(FlxG.camera.x, FlxG.camera.y);

		if (FlxG.keys.justPressed.UP)
			camFollow.y -= GRID_SIZE;
		else if (FlxG.keys.justPressed.DOWN)
			camFollow.y += GRID_SIZE;

		if (FlxG.camera.x != oldCamPosition.x && FlxG.camera.y != oldCamPosition.y)
		{
			setGridsStatus();
			trace('sust');
		}

		if (FlxG.keys.justPressed.E)
			addNote();
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			save();
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.L)
			load();

		super.update(elapsed);
	}

	private function setGridsStatus()
	{
		#if debug
		var currentGridsAlive:Int = 0;
		#end

		gridGroup.forEach(function(grid:FlxSprite)
		{
			if (!grid.isOnScreen(FlxG.camera))
				grid.kill();
			else
				grid.revive();
		});

		#if debug
		gridGroup.forEachAlive(function(grid:FlxSprite)
		{
			currentGridsAlive += 1;
		});
		#end
	}

	private function generateGrid()
	{
		var sLen:Float = Conductor.songLen;
		var totalGridHeight:Float = 0;

		while (totalGridHeight < sLen / divisor)
		{
			var grid:FlxSprite = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE);
			totalGridHeight += GRID_SIZE;
			if (gridGroup.length > 0)
				grid.y = gridGroup.members[gridGroup.members.length - 1].y + GRID_SIZE;
			else
				grid.y = minY;

			grid.screenCenter(X);
			grid.x += GRID_SIZE;

			gridGroup.add(grid);
		}

		maxY = totalGridHeight;
	}

	private function addNote()
	{
		var data = Math.floor(FlxG.mouse.x / GRID_SIZE);
		trace(data);
		var songPos = mapYToSongPosition(FlxG.mouse.y) / divisor;

		var note = [songPos, data];
		chart.notes.push(note);

		trace("note_data_shit: " + note);

		updateGrid();
		return note;
	}

	private function updateGrid()
	{
		var noteSprite:Note;
		var latestNote = chart.notes[chart.notes.length - 1];
		noteSprite = new Note(latestNote[0], latestNote[1]);
		noteGroup.add(noteSprite);
		noteSprite.y = mapSongPositionToY(latestNote[0] * divisor);
		noteSprite.x = gridGroup.members[0].x + (latestNote[1] % 4) * GRID_SIZE;
		// trace(latestNote + " sprite made");
	}

	private function mapYToSongPosition(y:Float)
	{
		var scaledY:Float = (y - minY) / (maxY - minY);
		return minTime + (scaledY * (maxTime - minTime));
	}

	private function mapSongPositionToY(songPosition:Float)
	{
		var scaledTime = (songPosition - minTime) / (maxTime - minTime);
		return minY + (scaledTime * (maxY - minY));
	}

	private inline function seek(by:Float)
	{
		return Conductor.song.time += by;
	}

	private function rerenderAllNotes()
	{
		noteGroup.clear();

		for (i in chart.notes)
		{
			var note:Note = new Note(i[0], i[1]);
			note.x = gridGroup.members[0].x + (i[1] % 4) * GRID_SIZE;
			note.y = mapSongPositionToY(i[0]) * divisor;
			noteGroup.add(note);
		}
	}

	private function load()
	{
		var fr:FileReference = new FileReference();
		fr.addEventListener(Event.SELECT, load_onSelect);
		fr.addEventListener(Event.CANCEL, load_onCancel);
		fr.browse([new FileFilter("JSON files", "*.json")]);
	}

	@:noCompletion
	private function load_onSelect(e:Event)
	{
		var fr:FileReference = cast(e.target, FileReference);
		fr.addEventListener(Event.COMPLETE, load_onComplete);
		fr.load();
	}

	@:noCompletion
	private function load_onComplete(e:Event)
	{
		var fr:FileReference = cast(e.target, FileReference);
		chart = null;
		chart = cast Json.parse(fr.data.toString());
		fr.removeEventListener(Event.COMPLETE, load_onComplete);
		rerenderAllNotes();
	}

	@:noCompletion
	private function load_onCancel(e:Event)
	{
		trace("cancelled!");
	}

	private function save()
	{
		var fr:FileReference = new FileReference();
		fr.save(Json.stringify(chart), "leJson.json");
	}
}
