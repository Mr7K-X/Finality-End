package psych.states.debug;

import psych.backend.ui.PsychUIEventHandler.PsychUIEvent;
import psych.backend.ui.*;

class ChartEditorState extends MusicBeatState implements PsychUIEvent
{
  override function create():Void
  {
    super.create();
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }

  public function UIEvent(id:String, sender:Dynamic):Void
  {
    trace(id, sender);
  }
}
