package psych.backend;

import flixel.util.FlxGradient;

class CustomFadeTransition extends MusicBeatSubstate
{
	public static var finishCallback:Void->Void;

	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;
	var blackfuck:FlxSprite;
	var duration:Float;

	public function new(duration:Float, isTransIn:Bool)
	{
		super();

		this.duration = duration;
		this.isTransIn = isTransIn;
	}

	override function create()
	{
		super.create();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];

		var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));

		transGradient = FlxGradient.createGradientFlxSprite(
			width, 1, (isTransIn ? [FlxColor.TRANSPARENT, FlxColor.BLACK] : [FlxColor.BLACK, FlxColor.TRANSPARENT]), 1, 0);
		transGradient.scale.y = height;
		transGradient.updateHitbox();
		transGradient.scrollFactor.set();
		transGradient.screenCenter(X);
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scale.set(width, height + 400);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		add(transBlack);

		if(isTransIn)
			transGradient.x = transBlack.x - transBlack.width;
		else
			transGradient.x = -transGradient.width;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		final width:Float = FlxG.width * Math.max(camera.zoom, 0.001);
		final targetPos:Float = transGradient.width - 50 * Math.max(camera.zoom, 0.001);

		if(duration > 0)
			transGradient.x += (width + targetPos) * elapsed / duration;
		else
			transGradient.x = (targetPos) * elapsed;

		if(isTransIn) {
			transBlack.x = transGradient.x + transGradient.width;
		} else
			transBlack.x = transGradient.x - transGradient.width;

		if(transGradient.x >= targetPos)
		{
			close();
			if(finishCallback != null) finishCallback();
			finishCallback = null;
		}
	}
}