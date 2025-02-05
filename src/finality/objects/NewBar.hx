package finality.objects;

import flixel.graphics.FlxGraphic;
import flixel.ui.FlxBar;
import flixel.group.FlxSpriteGroup;

class NewBar extends FlxSpriteGroup
{
  public var bar_1:Null<FlxBar> = null;
  public var bar_2:Null<FlxBar> = null;

  public var bg:Null<FlxSprite> = null;

  public function new(y:Float, pd:Dynamic, vr:String):Void
  {
    super();

    antialiasing = ClientPrefs.data.antialiasing;

    bg = new FlxSprite(0, y).loadGraphic(Paths.image('fhealthbar'));
    bg.scrollFactor.set();
    bg.alpha = 1.0;

    var aGraph:FlxGraphic = Paths.image('hhealthbar');

    bar_1 = new FlxBar(145, bg.y + 135, RIGHT_TO_LEFT, aGraph.width, aGraph.height, pd, vr, 0, 2);
    bar_1.scrollFactor.set();
    bar_1.createImageBar(Paths.image('ehealthbar'), Paths.image('hhealthbar'), FlxColor.TRANSPARENT, FlxColor.TRANSPARENT);

    bar_2 = new FlxBar(bar_1.x, bar_1.y, LEFT_TO_RIGHT, bar_1.graphic.width, bar_1.graphic.height, pd, vr, 0, 2);
    bar_2.scrollFactor.set();
    bar_2.createImageBar(Paths.image('hhealthbar'), Paths.image('ehealthbar'), FlxColor.TRANSPARENT, FlxColor.TRANSPARENT);
    add(bar_2);

    add(bar_1);

    add(bg);
  }
}
