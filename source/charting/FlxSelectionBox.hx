package charting;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;

/**
 * Made by codescape https://github.com/codescapade/flixel-select-box
 */
class FlxSelectionBox extends FlxSprite
{
	public var dragging = false;

	private var dragStartX:Int;
	private var dragStartY:Int;

	public var onClick:FlxTypedSignal<FlxSelectionBox->Void>;
	public var onRelease:FlxTypedSignal<FlxSelectionBox->Void>;

	public function new(?color:FlxColor = 0x668888ff)
	{
		super();
		makeGraphic(1, 1, color);
		onClick = new FlxTypedSignal<FlxSelectionBox->Void>();
		onRelease = new FlxTypedSignal<FlxSelectionBox->Void>();

		#if debug
		onClick.add(function(box)
		{
			trace('CLICKED! (FlxSelectionBox)');
		});
		onRelease.add(function(box)
		{
			trace('RELEASED! (FlxSelectionBox)');
		});
		#end
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.mouse.pressed && !dragging)
		{
			dragging = true;
			dragStartX = FlxG.mouse.x;
			dragStartY = FlxG.mouse.y;
		}

		if (dragging)
		{
			visible = true;
			var currentX = FlxG.mouse.x;
			var currentY = FlxG.mouse.y;
			var sizeX = Math.abs(currentX - dragStartX);
			var sizeY = Math.abs(currentY - dragStartY);

			x = dragStartX < currentX ? dragStartX : currentX;
			y = dragStartY < currentY ? dragStartY : currentY;
			scale.set(sizeX, sizeY);
			updateHitbox();
		}
		else
		{
			visible = false;
			scale.set(1, 1);
		}
		super.update(elapsed);
	}
}
