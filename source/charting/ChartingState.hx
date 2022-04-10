package charting;

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

	private var hologram:FlxSprite;

	private static inline final GRID_SIZE:Int = 40;

	private var dragSelectBox:FlxSprite;

	var selectBox:FlxSelectionBox;

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

	var placementContext:String;

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
		strumLine.x -= (FlxG.width / 2) -= GRID_SIZE * 2;

		hologram = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE, FlxColor.BLUE);
		hologram.alpha = .3;
		add(hologram);

		strumLine.alpha = .3;
		add(strumLine);

		FlxG.camera.follow(strumLine, LOCKON);

		minY = 0;
		maxY = gridGroup.members[gridGroup.length - 1].y + GRID_SIZE;
		minTime = 0;
		maxTime = Conductor.songLen;

		selectBox = new FlxSelectionBox();
		add(selectBox);

		selectBox.onRelease.add(function(box:FlxSelectionBox)
		{
			if (FlxG.mouse.overlaps(noteGroup))
			{
				noteGroup.forEach(function(note:Note)
				{
					if (FlxG.overlap(note, box))
					{
						selectedNotesGraphics.push(note);
						selectedNotes.push([note.songTime, note.data]);
					}
				});
			}
		});

		selectBox.onClick.add(function(box:FlxSelectionBox)
		{
			selectedNotes = [];
			selectedNotesGraphics = [];
		});

		super.create();
	}

	public var selectedNotesGraphics:Array<Note>;
	public var selectedNotes:Array<Array<Dynamic>>;
	public var copiedNotes:Array<Array<Dynamic>> = [];

	override function update(elapsed:Float)
	{
		noteGroup.forEachAlive(function(note:Note)
		{
			if (!note.isOnScreen())
			{
				note.kill();
			}
			else
			{
				note.revive();
			}
		});

		strumLine.y = mapSongPositionToY(Conductor.songPos);

		FlxG.sound.music.looped = true;

		if (!FlxG.keys.pressed.SHIFT)
			hologram.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		else
			hologram.y = FlxG.mouse.y;

		hologram.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;

		if (FlxG.keys.justPressed.SPACE)
		{
			if (Conductor.song.playing)
				Conductor.song.pause();
			else
				Conductor.song.play();
		}

		if (FlxG.keys.pressed.V)
			trace(Conductor.songPos);

		if (FlxG.keys.pressed.W)
		{
			Conductor.song.time -= Conductor.stepCrochet;
		}
		else if (FlxG.keys.pressed.S)
		{
			Conductor.song.time += Conductor.stepCrochet;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.switchState(new PlayState());
			// PlayState.chart = chart;
		}

		manageGrids();

		if (FlxG.keys.justPressed.E)
		{
			if (!FlxG.mouse.overlaps(noteGroup) || FlxG.mouse.overlaps(noteGroup) && FlxG.keys.pressed.CONTROL)
				addNote(hologram.y);
			else if (FlxG.mouse.overlaps(noteGroup) && !FlxG.keys.pressed.CONTROL)
				removeNote();
		}
		if (FlxG.keys.justPressed.X)
			addNote(strumLine.y);
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			save();
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.L)
			load();

		super.update(elapsed);
	}

	private function manageGrids()
	{
		for (i in gridGroup)
		{
			if (!i.isOnScreen(FlxG.camera) && i.alive)
			{
				i.kill();
			}
			else if (i.isOnScreen(FlxG.camera) && !i.alive)
			{
				i.revive();
			}
		}

		#if debug
		var aliveCtr = 0;
		gridGroup.forEachAlive(function(s:FlxSprite)
		{
			aliveCtr++;
		});
		#end
	}

	private function generateGrid()
	{
		var totalGridHeight:Float = 0;

		while (totalGridHeight < Conductor.songLen / divisor)
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

	private function pasteNotes()
	{
		var cloned = [];
		for (i in copiedNotes)
		{
			var newNote = [i[0], i[1]];
			cloned.push(newNote);
		}

		for (i in 0...cloned.length)
		{
			cloneNote(cloned[i][0] + Conductor.songPos, Std.int(cloned[i][1]));
		}
	}

	private function cloneNote(songTime:Float, data:Int)
	{
		var pos = mapSongPositionToY(songTime);
		chart.notes.push([pos, data]);
		addNoteGraphics();
		trace('added note: ' + [pos, data]);
	}

	private function addNote(y:Float)
	{
		var data = Math.floor(FlxG.mouse.x / GRID_SIZE) % 4;
		trace('raw: ' + FlxG.mouse.x / GRID_SIZE + '\nsemi-raw(floored): ' + Math.floor(FlxG.mouse.x / GRID_SIZE) + '\nunraw: ' + data);
		var songPos = mapYToSongPosition(y); // / divisor;

		trace("\nNOTE: " + songPos + "\nSONG: " + Conductor.songPos);

		var note = [songPos, data];
		chart.notes.push(note);
		addNoteGraphics();
		trace("Added note: " + note);
		return note;
	}

	private function removeNote(note:Note = null)
	{
		if (note != null)
		{
			for (i in chart.notes)
			{
				if (note.songTime == i[0] && note.data == i[1])
				{
					chart.notes.remove(i);
					inline removeNoteGraphics(note);
				}
			}
		}
		noteGroup.forEachAlive(function(note:Note)
		{
			if (FlxG.mouse.overlaps(note))
			{
				for (i in chart.notes)
				{
					if (note.songTime == i[0] && note.data == i[1])
					{
						chart.notes.remove(i);
						inline removeNoteGraphics(note);
						trace('Removed Note: ' + i);
					}
				}
			}
		});
	}

	private function addNoteGraphics()
	{
		var noteSprite:Note;
		var latestNote = chart.notes[chart.notes.length - 1];
		noteSprite = new Note(latestNote[0], latestNote[1]);
		noteGroup.add(noteSprite);
		noteSprite.y = mapSongPositionToY(latestNote[0]);
		noteSprite.x = gridGroup.members[0].x + (latestNote[1]) * GRID_SIZE;
		// trace(latestNote + " sprite made");
	}

	private function removeNoteGraphics(note:Note)
	{
		noteGroup.remove(note);
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
