package psych.states.debug.objects;

import psych.states.debug.ChartEditorState;
import psych.objects.Note;
import psych.shaders.RGBPalette;
import flixel.util.FlxDestroyUtil;

class ChartNote extends Note
{
  public static var noteTypeTexts:Map<Int, FlxText> = [];

  public var isEvent:Bool = false;
  public var songData:Array<Dynamic> = null;
  public var sustainSprite:FlxSprite;
  public var chartY:Float = 0;
  public var chartNoteData:Int = 0;

  public var hasSustain(get, never):Bool;

  private var _lastZoom:Float = -1.0;
  private var _noteTypeText:FlxText;

  public function new(Time:Float, Data:Int, Song:Array<Dynamic>)
  {
    super(Time, Data, null, false, true);

    this.songData = Song;
    this.strumTime = Time;
    this.chartNoteData = Data;
  }

  public function ChangeNoteData(Value:Int):Void
  {
    this.chartNoteData = Value;
    this.songData[1] = Value;
    this.noteData = Value % ChartEditorState.instance.GRID_COLUMNS_PER_PLAYER;
    this.mustPress = (Value < ChartEditorState.instance.GRID_COLUMNS_PER_PLAYER);

    loadNoteAnims();

    if (Note.globalRgbShaders.contains(rgbShader.parent)) rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(noteData));

    animation.play(Note.colArray[this.noteData % Note.colArray.length] + "Scroll");
    updateHitbox();

    if (width > height) setGraphicSize(ChartEditorState.instance.GRID_SIZE);
    else
      setGraphicSize(0, ChartEditorState.instance.GRID_SIZE);

    updateHitbox();
  }

  public function SetStrumTime(Value:Float):Void
  {
    this.songData[0] = Value;
    this.strumTime = Value;
  }

  public function SetSustainLength(Value:Float, StepCrochet:Float, Zoom:Float = 1.0):Void
  {
    this._lastZoom = Zoom;

    Value = RecalculateValue(Value, StepCrochet);
    songData[2] = sustainLength = Math.max(Math.min(Value, StepCrochet * 128), 0);

    if (sustainLength > 0)
    {
      if (sustainSprite == null) sustainSprite = MakeConstSpr();

      sustainSprite.setGraphicSize(8, GetSustainHeight(Value, StepCrochet, Zoom));
      sustainSprite.updateHitbox();
    }
  }

  public function UpdateSustainToStepCrochet(StepCrochet:Float):Void
  {
    if (_lastZoom < 0) return;

    SetSustainLength(sustainLength, StepCrochet, _lastZoom);
  }

  public function FindNoteTypeText(Num:Int):FlxText
  {
    var txt:FlxText = null;

    if (Num != 0)
    {
      if (!noteTypeTexts.exists(Num))
      {
        txt = GetNewTypeText(Num);
        noteTypeTexts.set(Num, txt);
      }
      else
        txt = noteTypeTexts.get(Num);
    }
    return (_noteTypeText = txt);
  }

  override function draw():Void
  {
    if (sustainSprite != null && sustainSprite.exists && sustainSprite.visible && sustainLength > 0)
    {
      sustainSprite.setPosition(GetDrawAxisX(sustainSprite), this.y + this.height / 2);
      sustainSprite.alpha = this.alpha;
      sustainSprite.draw();
    }

    super.draw();

    if (_noteTypeText != null && _noteTypeText.exists && _noteTypeText.visible)
    {
      _noteTypeText.setPosition(GetDrawAxisX(_noteTypeText), GetDrawAxisY(_noteTypeText));
      _noteTypeText.alpha = this.alpha;
      _noteTypeText.draw();
    }
  }

  override function destroy():Void
  {
    sustainSprite = FlxDestroyUtil.destroy(sustainSprite);
    super.destroy();
  }

  function MakeConstSpr():FlxSprite
  {
    var const:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
    const.scrollFactor.x = 0;

    return const;
  }

  function GetDrawAxisX(Spr:FlxSprite):Float
    return (this.x + this.width / 2 - ((Spr != null && Spr.exists && Spr.visible) ? Spr.width : 1) / 2);

  function GetDrawAxisY(Spr:FlxSprite):Float
    return (this.x + this.width / 2 - ((Spr != null && Spr.exists && Spr.visible) ? Spr.height : 1) / 2);

  function GetNewTypeText(Num:Int):FlxText
  {
    var t = new FlxText(0, 0, ChartEditorState.instance.GRID_SIZE, (Num > 0) ? Std.string(Num) : 'N\\A', 16);
    t.autoSize = false;
    t.alignment = CENTER;
    t.borderStyle = SHADOW;
    t.shadowOffset.set(2, 2);
    t.borderColor = FlxColor.BLACK;
    t.scrollFactor.x = 0;
    return t;
  }

  function GetSustainHeight(V:Float, S:Float, Z:Float):Float
    return Math.max(ChartEditorState.instance.GRID_SIZE / 4,
      (Math.round((V * ChartEditorState.instance.GRID_SIZE + ChartEditorState.instance.GRID_SIZE) / S) * Z) - ChartEditorState.instance.GRID_SIZE / 2);

  function RecalculateValue(V:Float, S:Float):Float
    return Math.round(V / (S / 2)) * (S / 2);

  function get_hasSustain()
    return (!isEvent && sustainLength > 0);
}
