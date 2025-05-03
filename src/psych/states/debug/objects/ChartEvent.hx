package psych.states.debug.objects;

import psych.states.debug.objects.ChartNote;
import psych.states.debug.ChartEditorState;
import psych.objects.Note;
import psych.shaders.RGBPalette;
import flixel.util.FlxDestroyUtil;

class ChartEvent extends ChartNote
{
  public var eventText:FlxText;
  public var events:Array<Array<String>>;

  public function new(Time:Float, EventData:Dynamic)
  {
    super(Time, -1, EventData);

    this.isEvent = true;
    events = EventData[1];

    loadGraphic(Paths.image('eventArrow'));
    setGraphicSize(ChartEditorState.instance.GRID_SIZE);
    updateHitbox();

    eventText = new FlxText(0, 0, 400, '', 12);
    eventText.setFormat(Paths.font('vcr.ttf'), 12, FlxColor.WHITE, RIGHT);
    eventText.scrollFactor.x = 0;
    UpdateEventText();
  }

  override function draw():Void
  {
    if (eventText != null && eventText.exists && eventText.visible)
    {
      eventText.y = GetDrawAxisY(eventText);
      eventText.alpha = this.alpha;
      eventText.draw();
    }

    super.draw();
  }

  override function SetSustainLength(Value:Float, StepCrochet:Float, Zoom:Float = 1.0):Void {}

  public function UpdateEventText():Void
  {
    var myTime:Float = Math.floor(this.strumTime);
    if (events.length == 1)
    {
      var event = events[0];
      eventText.text = 'Name: ${event[0]} ($myTime ms)\nV1: ${event[1]}\nV2: ${event[2]}';
    }
    else if (events.length > 1)
    {
      var eventNames:Array<String> = [for (event in events) event[0]];
      eventText.text = '${events.length} Events ($myTime ms):\n${eventNames.join(', ')}';
    }
    else
      eventText.text = "Error!";
  }

  override function destroy():Void
  {
    eventText = FlxDestroyUtil.destroy(eventText);
    super.destroy();
  }
}
