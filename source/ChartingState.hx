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
import openfl.net.FileReference;

class ChartingState extends RythmState
{
	public var chart:Chart;

	private var minY:Float;
	private var maxY:Float;
	private var minTime:Float;
	private var maxTime:Float;
	private var time:Float;

	private var gridGroup:FlxTypedGroup<FlxSprite>;

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

		FlxG.sound.playMusic('assets/music/blammed.ogg');
		Conductor.song.pause();

		generateGrid();

		camFollow = new FlxObject(FlxG.camera.x, FlxG.camera.y, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON);

		minY = 0;
		maxY = gridGroup.members[gridGroup.length - 1].y + GRID_SIZE;
		minTime = 0;
		maxTime = Conductor.songLen;
		super.create();
	}

	override function update(elapsed:Float)
	{
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

		while (totalGridHeight < sLen)
		{
			var grid:FlxSprite = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE);
			totalGridHeight += GRID_SIZE;
			if (gridGroup.length > 0)
				grid.y = gridGroup.members[gridGroup.members.length - 1].y + GRID_SIZE;
			else
				grid.y = minY;
			gridGroup.add(grid);
		}

		maxY = totalGridHeight;
	}

	private function addNote()
	{
		var data = Math.floor(FlxG.mouse.x / GRID_SIZE);
		trace(data);
		var songPos = mapYToSongPosition(FlxG.mouse.y);

		var note = [songPos, data];
		chart.notes.push(note);

		updateGrid();
		return note;
	}

	private function updateGrid()
	{
		var noteSprite:FlxSprite;
		noteSprite = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE, FlxColor.BLUE);
		add(noteSprite);
		var latestNote = chart.notes[chart.notes.length - 1];
		noteSprite.y = mapSongPositionToY(latestNote[0]);
		noteSprite.x = gridGroup.members[0].x + latestNote[1] * GRID_SIZE;
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

	private function save()
	{
		var fr:FileReference = new FileReference();
		fr.save(Json.stringify(chart), "leJson.json");
	}
}
