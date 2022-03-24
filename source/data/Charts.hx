package data;

typedef Section =
{
	var notes:Array<Array<Dynamic>>;
	var sectionLength:Int;
	var ?sectionType:String;
}

typedef OldChart =
{
	var name:String;
	var sections:Array<Section>;
	var bpm:Int;
	var speed:Float;
}

typedef Chart =
{
	var name:String;
	var notes:Array<Array<Dynamic>>;
	var bpm:Int;
	var speed:Int;
}
