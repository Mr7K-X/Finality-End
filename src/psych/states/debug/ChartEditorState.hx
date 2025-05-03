package psych.states.debug;

import psych.states.debug.backend.AboutSubState;
import psych.backend.StageData;
import flixel.util.FlxDestroyUtil;
import psych.objects.StrumNote;
import psych.objects.HealthIcon;
import tempo.util.TempoSave;
import flixel.input.keyboard.FlxKey;
import finality.util.MathUtil;
import psych.states.debug.formats.*;
import psych.states.debug.formats.Undo;
import psych.states.debug.formats.Theme;
import psych.states.debug.objects.*;
import psych.backend.ui.PsychUIEventHandler.PsychUIEvent;
import psych.backend.ui.*;

@:allow(psych.states.debug.objects.ChartNote)
@:allow(psych.states.debug.objects.ChartEvent)
@:allow(psych.states.debug.objects.ChartGrid)
class ChartEditorState extends MusicBeatState implements PsychUIEvent
{
  public static final DEFAULT_EVENTS:Array<Array<String>> = [
    ['', "Nothing. Yep, that's right."],
    [
      'Hey!',
      "Plays the \"Hey!\" animation from Bopeebo,\nValue 1: BF = Only Boyfriend, GF = Only Girlfriend,\nSomething else = Both.\nValue 2: Custom animation duration,\nleave it blank for 0.6s"
    ],
    [
      'Set GF Speed',
      "Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"
    ],
    ['Add Camera Zoom', "camera change"],
    [
      'Play Animation',
      "Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"
    ],
    [
      'Camera Follow Pos',
      "Value 1: X\nValue 2: Y\n\nThe camera won't change the follow point\nafter using this, for getting it back\nto normal, leave both values blank."
    ],
    [
      'Alt Idle Animation',
      "Sets a specified suffix after the idle animation name.\nYou can use this to trigger 'idle-alt' if you set\nValue 2 to -alt\n\nValue 1: Character to set (Dad, BF or GF)\nValue 2: New suffix (Leave it blank to disable)"
    ],
    [
      'Screen Shake',
      "Value 1: Camera shake\nValue 2: HUD shake\n\nEvery value works as the following example: \"1, 0.05\".\nThe first number (1) is the duration.\nThe second number (0.05) is the intensity."
    ],
    [
      'Change Character',
      "Value 1: Character to change (Dad, BF, GF)\nValue 2: New character's name"
    ],
    [
      'Change Scroll Speed',
      "Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."
    ],
    ['Set Property', "Value 1: Variable name\nValue 2: New value"],
    [
      'Play Sound',
      "Value 1: Sound file name\nValue 2: Volume (Default: 1), ranges from 0 to 1"
    ]
  ];
  static var VORTEX_KEYS:Array<FlxKey> = [ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT];
  static var gridColors:Array<FlxColor> = [0xFFB8B8B8, 0xFF818181];
  static var gridColorsPrev:Array<FlxColor> = [0xFF3D3D3D, 0xFF202020];
  static var gridColorsNext:Array<FlxColor> = [0xFFE2E2E2, 0xFFB9B9B9];

  final BACKUP_EXT = ".autosave";
  final GRID_SIZE = 40;
  final GRID_PLAYERS = 2;
  final GRID_COLUMNS_PER_PLAYER = 4;
  final SHOW_EVENT_COLUMN = true;
  final QUANTS:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 96, 192];
  final QUANTS_COLORS:Array<FlxColor> = [
    FlxColor.RED,
    FlxColor.BLUE,
    FlxColor.PURPLE,
    FlxColor.YELLOW,
    FlxColor.WHITE,
    FlxColor.PINK,
    FlxColor.ORANGE,
    FlxColor.CYAN,
    FlxColor.LIME,
    FlxColor.GRAY,
    FlxColor.BLACK
  ];
  final ZOOM_LIST:Array<Float> = [.25, .5, 1, 2, 3, 4, 6, 8, 12, 16, 24];

  public static var instance:ChartEditorState;

  var curEditSection:Int = 0;
  var curZoom:Float = 1;
  var endSection:Int = 0;
  var curSong:String = "test";

  var mainBox:PsychUIBox;
  var mainBoxPosition:FlxPoint = new FlxPoint(920, 40);

  var infoBox:PsychUIBox;
  var infoBoxPosition:FlxPoint = new FlxPoint(1000, 360);

  var upperBox:PsychUIBox;

  var camEditor:FlxCamera;

  var sectionFirstNoteID:Int = 0;
  var sectionFirstEventID:Int = 0;

  var curQuant(default, set):Int = 16;
  var instVolume(default, set):Float = 0.6;
  var vocalsVolume(default, set):Float = 1.0;
  var vocalsVolume_enemy(default, set):Float = 1.0;

  var copiedNotes:Array<Dynamic> = [];
  var copiedEvents:Array<Dynamic> = [];

  var icons:Array<HealthIcon> = [];
  var events:Array<ChartEvent> = [];
  var notes:Array<ChartNote> = [];

  var prevGridBG:ChartGrid;
  var curGridBG:ChartGrid;
  var nextGridBG:ChartGrid;
  var instWaveform:FlxSprite;
  var vocalsWaveform:FlxSprite;
  var enemyWaveform:FlxSprite;

  var behindRenderedNotes:FlxTypedGroup<ChartNote> = new FlxTypedGroup<ChartNote>();
  var curRenderedNotes:FlxTypedGroup<ChartNote> = new FlxTypedGroup<ChartNote>();
  var movingNotes:FlxTypedGroup<ChartNote> = new FlxTypedGroup<ChartNote>();
  var strumNotes:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();

  var eventLockOverlay:FlxSprite;
  var vortexIndicator:FlxSprite;
  var dummyArrow:FlxSprite;

  var selectionStart:FlxPoint = new FlxPoint();
  var selectionBox:FlxSprite;

  var isMovingNotes:Bool = false;
  var movingNotesLastData:Int = 0;
  var movingNotesLastY:Float = 0;
  var scrollY:Float = 0;

  var vocals:FlxSound = new FlxSound();
  var enemy:FlxSound = new FlxSound();
  var save:TempoSave = new TempoSave();

  private var _keysPressedBuffer:Array<Bool> = [];
  private var _shouldReset:Bool = true;

  public function new(?shouldReset:Bool = true)
  {
    this._shouldReset = shouldReset;
    super();
    instance = this;
  }

  var bg:FlxSprite;
  var eventIcon:FlxSprite;
  var mustHitIndicator:FlxSprite;
  var theme:ChartingTheme = DEFAULT;
  var tipBg:FlxSprite;
  var fullTipText:FlxText;

  override function create():Void
  {
    SetWindowIcon('icon-1');

    @:privateAccess
    save.bind('charting', ClientPrefs._path());

    if (Difficulty.list.length < 1) Difficulty.resetList();
    _keysPressedBuffer.resize(VORTEX_KEYS.length);

    if (_shouldReset) Conductor.songPosition = 0;

    persistentUpdate = false;

    FlxG.sound.list.add(vocals);
    FlxG.sound.list.add(enemy);

    vocals.autoDestroy = false;
    vocals.looped = true;
    enemy.autoDestroy = false;
    enemy.looped = true;

    initPsychCamera();

    camEditor = new FlxCamera();
    camEditor.bgColor.alpha = 0;
    FlxG.cameras.add(camEditor, false);

    bg = new FlxSprite(-1, -1).makeGraphic(FlxG.width + 2, FlxG.height + 2, FlxColor.WHITE);
    bg.scrollFactor.set();
    bg.color = FlxColor.fromString('0x130B2B');
    add(bg);

    MakeGrids();

    var columns:Int = 0;
    var iconX:Float = curGridBG.x;
    var iconY:Float = 50;

    if (SHOW_EVENT_COLUMN)
    {
      eventIcon = new FlxSprite(0, iconY).loadGraphic(Paths.image('eventArrow'));
      eventIcon.antialiasing = ClientPrefs.data.antialiasing;
      eventIcon.alpha = .6;
      eventIcon.setGraphicSize(30, 30);
      eventIcon.updateHitbox();
      eventIcon.scrollFactor.set();
      add(eventIcon);

      eventIcon.x = iconX + (GRID_SIZE * .5) - eventIcon.width / 2;
      iconX += GRID_SIZE;

      columns++;
    }

    var gridStripes:Array<Int> = [];
    for (i in 0...GRID_PLAYERS)
    {
      if (columns > 0) gridStripes.push(columns);
      columns += GRID_COLUMNS_PER_PLAYER;

      var icon:HealthIcon = new HealthIcon();
      icon.autoAdjustOffset = false;
      icon.y = iconY;
      icon.alpha = .6;
      icon.scrollFactor.set();
      icon.scale.set(.3, .3);
      icon.updateHitbox();
      icon.ID = i + 1;
      add(icon);

      icons.push(icon);

      icon.x = iconX + GRID_SIZE * (GRID_COLUMNS_PER_PLAYER / 2) - icon.width / 2;
      iconX += GRID_SIZE * GRID_COLUMNS_PER_PLAYER;
    }

    prevGridBG.stripes = nextGridBG.stripes = curGridBG.stripes = gridStripes;

    selectionBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLUE);
    selectionBox.alpha = .6;
    selectionBox.blend = ADD;
    selectionBox.scrollFactor.set();
    selectionBox.visible = false;
    add(selectionBox);

    var b = new FlxSprite(-1, -1).makeGraphic(FlxG.width + 2, 22, FlxColor.BLACK);
    b.scrollFactor.set();
    b.cameras = [camEditor];
    add(b);

    upperBox = new PsychUIBox(0, 0, 550, 50, ['File', 'Edit', 'View', 'Audio', 'Display', 'Help']);
    upperBox.scrollFactor.set();
    upperBox.isMinimized = true;
    upperBox.minimizeOnFocusLost = true;
    upperBox.canMove = false;
    upperBox.cameras = [camEditor];
    upperBox.bg.visible = false;
    add(upperBox);

    if (PlayState.SONG == null) NewChart();

    MakeTab_File();
    MakeTab_Edit();
    MakeTab_View();
    MakeTab_Audio();
    MakeTab_Display();
    MakeTab_Help();

    curSong = Paths.formatToSongPath(PlayState.SONG.song);
    LoadAudio();
    ReloadGridUI();
    Conductor.bpm = PlayState.SONG.bpm;
    Conductor.mapBPMChanges(PlayState.SONG);

    endSection = Math.floor((FlxG.sound.music.length / 16) / 100);
    trace("Ending Section: " + endSection + "th");

    for (i in 0...endSection)
    {
      // AddSection();
    }

    DiscordClient.instance.changePresence({details: "New Chart Editor", state: "IN PROGRESS, NOT USING IN CURRENT MOMENT!"});

    super.create();

    FlxG.mouse.visible = true;

    SetWindowTitle(PlayState.SONG.song
      + ' | Editing ${curEditSection}th Section | In ${Std.string(MathUtil.recalculateTime(Conductor.songPosition))} time'
      + ' ['
      + PlayState.SONG.bpm
      + ' BPM / '
      + PlayState.SONG.notes.length
      + ' NOTES / '
      + (PlayState.SONG.events != null ? (PlayState.SONG.events.length + ' EVENTS') : "")
      + ' / GOOD LUCK]');
  }

  override function update(elapsed:Float):Void
  {
    this.curStep = RecalculateCurStep();

    super.update(elapsed);

    if (FlxG.sound.music != null)
    {
      if (FlxG.sound.music.time < 0)
      {
        FlxG.sound.music.pause();
        FlxG.sound.music.time = 0;
      }
      else if (FlxG.sound.music.time > FlxG.sound.music.length)
      {
        FlxG.sound.music.pause();
        FlxG.sound.music.time = 0;
        ChangeSectionUI();
      }

      Conductor.songPosition = FlxG.sound.music.time;
    }
  }

  var ignoreClickForThisFrame:Bool = false;

  public function UIEvent(id:String, sender:Dynamic):Void
  {
    switch (id)
    {
      case PsychUIButton.CLICK_EVENT, PsychUIDropDownMenu.CLICK_EVENT:
        ignoreClickForThisFrame = true;

      case PsychUIBox.CLICK_EVENT:
        ignoreClickForThisFrame = true;
        if (sender == upperBox) UpdateUpperBox();

      case PsychUIBox.MINIMIZE_EVENT:
        if (sender == upperBox)
        {
          upperBox.bg.visible = !upperBox.isMinimized;
          UpdateUpperBox();
        }

      case PsychUIBox.DROP_EVENT:
        save.data.mainBoxPosition = [mainBox.x, mainBox.y];
        save.data.infoBoxPosition = [infoBox.x, infoBox.y];
    }
  }

  function UpdateUpperBox():Void
  {
    if (upperBox.selectedTab != null)
    {
      final m = upperBox.selectedTab.menu;

      upperBox.bg.x = upperBox.x + upperBox.selectedIndex * (upperBox.width / upperBox.tabs.length);
      upperBox.bg.setGraphicSize(m.width, m.height + 21);
      upperBox.bg.updateHitbox();
    }
  }

  function MakeTab_File():Void
  {
    var tab = upperBox.getTab('File');
    var tab_group = tab.menu;
    var btnX = tab.x - upperBox.x;
    var btnY = 1;
    var btnWid = tab.width;

    function createButton(text:String, onCallback:Void->Void)
    {
      var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  $text', onCallback, btnWid);
      btn.text.alignment = LEFT;
      tab_group.add(btn);
    }

    createButton('New', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not Finished!');
    });

    btnY++;
    btnY += 20;
    createButton('Open Chart...', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY += 20;
    createButton('Open Events...', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY++;
    btnY += 20;
    createButton('Save', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY += 20;
    createButton('Save as...', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY += 20;
    createButton('Save Events', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY += 20;
    createButton('Save Events as...', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY++;
    btnY += 20;
    createButton('Reload', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY++;
    btnY += 20;
    createButton('Preview', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY += 20;
    createButton('Playtest', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY++;
    btnY += 20;
    createButton('Exit', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });
  }

  function MakeTab_Edit():Void
  {
    var tab = upperBox.getTab('Edit');
    var tab_group = tab.menu;
    var btnX = tab.x - upperBox.x;
    var btnY = 1;
    var btnWid = tab.width;

    function createButton(text:String, onCallback:Void->Void)
    {
      var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  $text', onCallback, btnWid);
      btn.text.alignment = LEFT;
      tab_group.add(btn);
    }

    createButton('TEST', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });
  }

  function MakeTab_View():Void
  {
    var tab = upperBox.getTab('View');
    var tab_group = tab.menu;
    var btnX = tab.x - upperBox.x;
    var btnY = 1;
    var btnWid = tab.width;

    function createButton(text:String, onCallback:Void->Void)
    {
      var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  $text', onCallback, btnWid);
      btn.text.alignment = LEFT;
      tab_group.add(btn);
    }

    createButton('TEST', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });
  }

  function MakeTab_Audio():Void
  {
    var tab = upperBox.getTab('Audio');
    var tab_group = tab.menu;
    var btnX = tab.x - upperBox.x;
    var btnY = 1;
    var btnWid = tab.width;

    function createButton(text:String, onCallback:Void->Void)
    {
      var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  $text', onCallback, btnWid);
      btn.text.alignment = LEFT;
      tab_group.add(btn);
    }

    createButton('TEST', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });
  }

  function MakeTab_Display():Void
  {
    var tab = upperBox.getTab('Display');
    var tab_group = tab.menu;
    var btnX = tab.x - upperBox.x;
    var btnY = 1;
    var btnWid = tab.width;

    function createButton(text:String, onCallback:Void->Void)
    {
      var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  $text', onCallback, btnWid);
      btn.text.alignment = LEFT;
      tab_group.add(btn);
    }

    createButton('TEST', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });
  }

  function MakeTab_Help():Void
  {
    var tab = upperBox.getTab('Help');
    var tab_group = tab.menu;
    var btnX = tab.x - upperBox.x;
    var btnY = 1;
    var btnWid = tab.width;

    function createButton(text:String, onCallback:Void->Void)
    {
      var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  $text', onCallback, btnWid);
      btn.text.alignment = LEFT;
      tab_group.add(btn);
    }

    createButton('Welcome', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY += 20;

    createButton('Show Binds', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      trace('Not finished!');
    });

    btnY += 20;

    createButton('Guide', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      CoolUtil.browserLoad('https://www.youtube.com/watch?v=E4WlUXrJgy4');

      trace('Great!');
    });

    btnY++;
    btnY += 20;

    createButton('About', () -> {
      upperBox.isMinimized = true;
      upperBox.bg.visible = false;

      FlxG.state.persistentUpdate = true;
      FlxG.state.openSubState(new AboutSubState('Chart Editor - Finality End Special', 'A reworked chart editor from psych 0.7.3-1.0.3.',
        'Authors:\nMrzk(X) - Created Special Editor\nShadowMario - Created Psych Editors and UI.', 695, 425));

      trace('Not finished!');
    });
  }

  function MakeGrids():Void
  {
    var destroyed:Bool = false;
    var stripes:Array<Int> = null;

    if (prevGridBG != null)
    {
      stripes = prevGridBG.stripes;

      remove(prevGridBG);
      remove(curGridBG);
      remove(nextGridBG);

      prevGridBG = FlxDestroyUtil.destroy(prevGridBG);
      curGridBG = FlxDestroyUtil.destroy(curGridBG);
      nextGridBG = FlxDestroyUtil.destroy(nextGridBG);

      destroyed = true;
    }

    final count:Int = (GRID_COLUMNS_PER_PLAYER * GRID_PLAYERS) + (SHOW_EVENT_COLUMN ? 1 : 0);

    curGridBG = new ChartGrid(count, gridColors[0], gridColors[1]);
    curGridBG.screenCenter(X);

    prevGridBG = new ChartGrid(count, gridColorsPrev[0], gridColorsPrev[1]);
    nextGridBG = new ChartGrid(count, gridColorsNext[0], gridColorsNext[1]);

    prevGridBG.x = nextGridBG.x = curGridBG.x;
    prevGridBG.stripes = nextGridBG.stripes = curGridBG.stripes = stripes;

    if (destroyed)
    {
      insert(getFirstNull(), prevGridBG);
      insert(getFirstNull(), nextGridBG);
      insert(getFirstNull(), curGridBG);

      LoadSectionUI();
    }
    else
    {
      add(prevGridBG);
      add(nextGridBG);
      add(curGridBG);
    }
  }

  function NewChart():Void
  {
    PlayState.SONG =
      {
        song: "Undead",
        notes: [],
        events: [],
        bpm: 150.00,
        needsVoices: true,
        player1: 'bffreak',
        player2: 'bffreak',
        gfVersion: 'bffreak',
        speed: 1,
        stage: '22'
      };
    StageData.loadDirectory(PlayState.SONG);
    Conductor.bpm = PlayState.SONG.bpm;
  }

  function LoadAudio():Void
  {
    if (FlxG.sound.music != null) FlxG.sound.music.stop();

    FlxG.sound.playMusic(Paths.inst(curSong), instVolume, false);
    FlxG.sound.music.autoDestroy = false;
    FlxG.sound.music.onComplete = () -> {
      FlxG.sound.music.pause();
      Conductor.songPosition = 0;
      UpdateGridUI();
      UpdateSectionUI();
    };
    FlxG.sound.music.stop();
    trace(FlxG?.sound?.music ?? null);
    trace(curSong);
    Conductor.songPosition = GetSectionStartTime();
    FlxG.sound.music.time = Conductor.songPosition;

    final goodTime:Bool = true;
    var curTime = .0;
    if (PlayState.SONG.notes.length <= 1 && (PlayState.SONG.events != null ? PlayState.SONG.events.length <= 1 : goodTime))
    {
      trace("Firsty Tasty!");

      while (curTime < FlxG.sound.music.length)
      {
        // AddSection();
        curTime += CalculateCurTime(PlayState.SONG.bpm);
      }
    }

    FlxG.sound.music.stop(); // for smth
  }

  function ReloadGridUI():Void {}

  function UpdateGridUI():Void {}

  function ChangeSectionUI():Void {}

  function LoadSectionUI():Void {}

  function UpdateSectionUI():Void {}

  function UpdateVortexColor():Void
  {
    // color there
  }

  function SetWindowTitle(id:String):Void
    openfl.Lib.application.window.title = Constants.TITLE + " - Chart Editor - " + id;

  function SetWindowIcon(id:String):Void
    openfl.Lib.application.window.setIcon(lime.graphics.Image.fromFile('assets/engine/ui/${id}.tsg'));

  function set_curQuant(v:Int):Int
  {
    this.curQuant = v;
    UpdateVortexColor();

    return curQuant;
  }

  function set_instVolume(v:Float):Float
  {
    instVolume = v;

    if (FlxG.sound.music != null) FlxG.sound.music.volume = v;

    return instVolume;
  }

  function set_vocalsVolume(v:Float):Float
  {
    vocalsVolume = v;

    return vocalsVolume;
  }

  function set_vocalsVolume_enemy(v:Float):Float
  {
    vocalsVolume_enemy = v;

    return vocalsVolume_enemy;
  }

  function RecalculateCurStep(Adding:Float = .0):Int
  {
    var l:BPMChangeEvent = {stepTime: 0, songTime: 0, bpm: 0};
    for (i in 0...Conductor.bpmChangeMap.length)
      if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime) l = Conductor.bpmChangeMap[i];

    final recalculated:Int = l.stepTime + Math.floor((FlxG.sound.music.time - l.songTime + Adding) / Conductor.stepCrochet);
    updateBeat(recalculated);

    return recalculated;
  }

  function CalculateCurTime(BPM:Float):Float
    return (60 / BPM) * 4000;

  function GetSectionStartTime(Adding:Int = 0):Float
  {
    if (PlayState.SONG == null)
    {
      return 0;
    }

    var daBPM:Float = PlayState.SONG.bpm;
    var daPos:Float = 0;
    for (i in 0...curEditSection + Adding)
    {
      if (PlayState.SONG.notes[i] != null)
      {
        if (PlayState.SONG.notes[i].changeBPM)
        {
          daBPM = PlayState.SONG.notes[i].bpm;
        }

        daPos += Conductor.getSectionBeats(PlayState.SONG, i) * (Conductor.calculateCrochet(daBPM));
      }
    }

    return daPos;
  }

  static function SetVortexKeys(vType:VType):Void
    ChartEditorState.VORTEX_KEYS = (vType == NUM_KEYS ? [ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT] : (vType == WASD_ARROWS ? [A, S, W, D, LEFT, DOWN, UP, RIGHT] : []));
}
