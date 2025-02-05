package finality;

import openfl.display.Sprite;

@:access(psych.backend.PsychSetup)
class Finality extends Sprite
{
  public static var instance:Finality;

  public static function main():Void
    openfl.Lib.current.addChild(new Finality());

  public function new():Void
  {
    instance = this;

    super();

    if (stage != null) _init();
    else
      addEventListener(openfl.events.Event.ADDED_TO_STAGE, _init);
  }

  function _init(?e:openfl.events.Event):Void
  {
    if (hasEventListener(openfl.events.Event.ADDED_TO_STAGE)) removeEventListener(openfl.events.Event.ADDED_TO_STAGE, _init);

    psych.backend.PsychSetup.addGame();
  }
}
