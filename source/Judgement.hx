package;

enum abstract Rating(String) from String to String
{
	var Marvelous = "marvelous";
	var Perfect = "perfect";
	var Great = "great";
	var Good = "good";
	var Ok = "ok";
	var Bad = "bad";
}

class Judgement
{
	public static var judgementValues:Array<Float> = [22, 45, 90, 135, 155, 180];
	public static var judgementRatings:Array<Rating> = [Marvelous, Perfect, Great, Good, Ok, Bad];

	public static function calculate(ms:Float):Rating
	{
		for (i in 0...judgementValues.length)
		{
			if (ms <= judgementValues[i])
				return judgementRatings[i];
		}

		return Bad;
	}
}
