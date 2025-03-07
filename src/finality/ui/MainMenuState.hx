package finality.ui;

import psych.substates.StickerSubState;
import openfl.filters.ShaderFilter;
import lime.app.Application;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState.defaultTransIn;
import flixel.addons.transition.FlxTransitionableState.defaultTransOut;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class MainMenuState extends MusicBeatState
{
  /**
   * VERSIONS LOLLOL
   */
  public static final psychEngineVersion:String = '0.7.3';

  public static final GAME_VERSION:String = #if debug 'Finality End: DELUXE (3.0)' #else 'Finality End: DELUXE 3.0' #end;

  /**
   * VURADO DOEBANDO DATA SHIT
   */
  final buttonsPath:String = "mainmenu/items/";

  var all_shit:Array<ItemOptions> = [
    {
      tag: 'worlds',
      sticker: true,
      menu: new StoryMenuState(),
      x: 540,
      y: 190,
      pitch:
        {
          name: 'worlds',
          scale: 1,
          addX: 1550,
          addY: -100,
          prefix:
            {
              name: 'headlooped3',
              anims: [
                {name: 'idle', xml: 'headlooped3', fps: 24}],
              idleAnim: 'idle'
            }
        }
    },
    {
      tag: 'extras',
      sticker: true,
      x: (FlxG.width - 480),
      y: 285,
      pitch:
        {
          name: 'extras',
          scale: 1,
          addX: 0,
          addY: -1150,
          prefix:
            {
              name: 'headlooped2',
              anims: [
                {name: 'idle', xml: 'headlopped2', fps: 24}],
              idleAnim: 'idle'
            }
        }
    },
    {
      tag: 'options',
      sticker: true,
      menu: new psych.options.OptionsState(),
      x: 80,
      y: (FlxG.height - 440),
      pitch:
        {
          name: 'options',
          scale: 1,
          addX: 0,
          addY: -1140,
          prefix:
            {
              name: 'headlooped4',
              anims: [
                {name: 'idle', xml: 'headlopped4', fps: 24}],
              idleAnim: 'idle'
            }
        }
    },
    {
      tag: 'credits',
      sticker: true,
      menu: new CreditsVideo(),
      x: (FlxG.width - 765),
      y: (FlxG.height - 650),
      pitch:
        {
          name: 'credits',
          scale: 1.05,
          addX: 0,
          addY: -1180,
          prefix:
            {
              name: 'headlooped',
              anims: [
                {name: 'idle', xml: 'headlopped', fps: 24}],
              idleAnim: 'idle'
            }
        }
    },
  ];
  final cacheShit:Array<String> = ['headlooped3'];

  /**
   * SELECTION SHIT
   */
  static var curSelected:Int = 0; // 0 - story, 1 - freeplay, 2 - options, 3 - credits

  static var curUpDownSel:Int = 0; // 0 - up, 1 - down

  var camGame:FlxCamera;
  var camStuff:FlxCamera;

  /**
   * SHADER SHIT
   */
  var vcrEffect:VcrGlitchEffect;

  /**
   * GROUPS
   */
  var firstClass:FlxSpriteGroup;

  var buttonGrp:FlxSpriteGroup;
  var pitchGrp:FlxSpriteGroup;
  var camGrp:FlxSpriteGroup;

  /**
   * This object is bullshit lol lol lol
   */
  var camFollow:FlxObject;

  /**
   * Creating many many stuff
   */
  var stickerSubState:StickerSubState;

  public function new(?stickers:StickerSubState = null)
  {
    super();

    if (stickers != null)
    {
      stickerSubState = stickers;
    }
  }

  override function create()
  {
    Paths.clearUnusedMemory();

    #if LUA_ALLOWED
    Mods.pushGlobalMods();
    #end
    Mods.loadTopMod();

    if (FlxG.sound.music == null)
    {
      FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
      FlxG.sound.music.fadeIn(4, 0, 0.7);
    }

    Conductor.bpm = 130;

    if (stickerSubState != null)
    {
      openSubState(stickerSubState);
      stickerSubState.degenStickers();
      // FlxG.sound.playMusic(Paths.music('freakyMenu'));
    }
    else
      Paths.clearStoredMemory();

    camGame = initPsychCamera();

    camStuff = new FlxCamera();
    camStuff.bgColor.alpha = 0;
    FlxG.cameras.add(camStuff, false);

    if (!FlxG.sound.music.playing)
    {
      FlxG.sound.music.loadEmbedded(Paths.music('freakyMenu'));
      FlxG.sound.music.play();
    }

    FlxG.mouse.visible = true;

    stuffVariables();

    super.create();

    firstClass = new FlxSpriteGroup();
    add(firstClass);

    var bg = new FlxSprite().loadGraphic(Paths.image('newpc'));
    bg.antialiasing = ClientPrefs.data.antialiasing;
    bg.screenCenter();
    bg.scrollFactor.set(0.15, 0.15);
    bg.updateHitbox();
    firstClass.add(bg);

    pitchGrp = new FlxSpriteGroup();
    add(pitchGrp);

    var da:FlxSprite = new FlxSprite(1090);
    da.y = 405;
    da.frames = Paths.getSparrowAtlas('speaker');
    da.animation.addByPrefix('speaker', 'speaker', 24, true);
    da.animation.play('speaker');
    da.antialiasing = ClientPrefs.data.antialiasing;
    da.scrollFactor.set(0.15, 0.15);
    da.updateHitbox();
    da.scrollFactor.set();
    firstClass.add(da);

    var bg = new FlxSprite().loadGraphic(Paths.image('blockpc'));
    bg.antialiasing = ClientPrefs.data.antialiasing;
    bg.screenCenter();
    bg.scrollFactor.set(0.15, 0.15);
    bg.updateHitbox();
    firstClass.add(bg);

    buttonGrp = new FlxSpriteGroup();
    add(buttonGrp);

    camGrp = new FlxSpriteGroup();
    camGrp.scrollFactor.set();
    camGrp.cameras = [camStuff];
    add(camGrp);

    for (shit in all_shit)
    {
      if (shit.pitch.prefix != null)
      {
        var pp:FlxSprite = new FlxSprite();
        pp.frames = Paths.getSparrowAtlas(shit.pitch.prefix.name);
        for (i in 0...shit.pitch.prefix.anims.length)
        {
          final ppLooped:Bool = (shit.pitch.prefix.anims[i].loop != null ? shit.pitch.prefix.anims[i].loop : true);
          pp.animation.addByPrefix(shit.pitch.prefix.anims[i].name, shit.pitch.prefix.anims[i].xml, shit.pitch.prefix.anims[i].fps, ppLooped);
        }
        pp.visible = false;
        pp.animation.play(shit.pitch.prefix.idleAnim);
        pp.antialiasing = ClientPrefs.data.antialiasing;
        pp.setGraphicSize(pp.width * (shit.pitch.scale != null ? shit.pitch.scale : 1));
        pp.screenCenter();
        pp.x += (shit.pitch.addX != null ? shit.pitch.addX : 0);
        pp.y += (shit.pitch.addY != null ? shit.pitch.addY : 0);
        pp.scrollFactor.set(0.15, 0.15);
        pp.updateHitbox();
        pitchGrp.add(pp);
        trace("ermm " + shit.pitch.name);
      }

      if (shit.pitch.text != null)
      {
        var pp:FlxText = new FlxText(0, 0, 500, shit.pitch.text, 20);
        pp.setFormat(Paths.font('HelpMe.ttf'), 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        pp.visible = false;
        pp.screenCenter();
        pp.scrollFactor.set(0.15, 0.15);
        pp.updateHitbox();
        pitchGrp.add(pp);
        trace('ermm ' + shit.pitch.name);
      }

      var item:FlxSprite = new FlxSprite(shit.x, shit.y);
      item.frames = Paths.getSparrowAtlas(buttonsPath + shit.tag);
      item.antialiasing = ClientPrefs.data.antialiasing;
      item.animation.addByPrefix('idle', shit.tag + " basic", 24);
      item.animation.addByPrefix('select', shit.tag + " white", 24);
      item.animation.play('idle');
      item.alpha = .6;
      item.scale.set(0.9, 0.9);
      item.scrollFactor.set(0.25, 0.25);
      item.updateHitbox();
      buttonGrp.add(item);
    }

    var staticLol:FlxSprite = new FlxSprite();
    staticLol.frames = Paths.getSparrowAtlas('staticShit');
    staticLol.animation.addByPrefix('idle', 'StaticIdle', 24, true);
    staticLol.animation.play('idle');
    staticLol.visible = ClientPrefs.data.flashing;
    staticLol.setGraphicSize(staticLol.width * 1.6);
    staticLol.setPosition(-100, -100);
    staticLol.scrollFactor.set();
    staticLol.updateHitbox();
    camGrp.add(staticLol);

    var vuradoImport:FlxText = new FlxText(5, FlxG.height - 24, 0, GAME_VERSION, 12);
    vuradoImport.scrollFactor.set();
    vuradoImport.setFormat(Paths.font('HelpMe.ttf'), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
    camGrp.add(vuradoImport);

    if (ClientPrefs.data.shaders)
    {
      vcrEffect = new VcrGlitchEffect();
      FlxG.camera.setFilters([new ShaderFilter(vcrEffect.shader)]);
    }

    FlxG.camera.zoom = 1.15;
    changeSelection(0, false, true);
  }

  var selected:Bool = false;

  override function update(e:Float)
  {
    if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

    musicVolumeFix(e);

    super.update(e);

    if (vcrEffect != null) vcrEffect.update(e);

    var lerpVal:Float = boundTo(e * 2.4, 0, 1);
    if (!selected)
    {
      FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX - (FlxG.width / 2)) * 0.15, lerpVal);
      FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY - (FlxG.height / 2) - 6) * 0.15, lerpVal);

      if (controls.BACK || FlxG.mouse.justPressedRight) select();
      if (controls.ACCEPT) select('custom');

      #if debug
      FlxG.mouse.visible = true;
      #end

      final curMouse = FlxG.mouse;

      if (curMouse.overlaps(buttonGrp.members[curSelected])) if (FlxG.mouse.justPressed) select('custom');

      if (curMouse.justMoved)
      {
        // lol

        for (i in 0...buttonGrp.members.length)
        {
          if (curMouse.overlaps(buttonGrp.members[i]))
          {
            if (i == curSelected) continue;

            changeSelection(i, true);
          }
        }
      }
      else
      {
        if (controls.UI_LEFT_P) changeSelection(-1);
        if (controls.UI_RIGHT_P) changeSelection(1);

        if (controls.UI_UP_P) changeUpDown(-1);
        if (controls.UI_DOWN_P) changeUpDown(1);

        #if debug
        if (controls.justPressed('debug_1'))
        {
          selected = true;
          MusicBeatState.switchState(new psych.states.editors.MasterEditorMenu());
        }
        #end
      }
    }
  }

  static function boundTo(value:Float, min:Float, max:Float):Float
  {
    return Math.max(min, Math.min(max, value));
  }

  function changeUpDown(v:Int)
  {
    curUpDownSel += v;

    if (curUpDownSel >= 2) curUpDownSel = 0;
    if (curUpDownSel < 0) curUpDownSel = 1;

    changeSelection(0);
  }

  var staticTween:FlxTween;

  function changeSelection(v:Int, ?isMouse:Bool = false, ?isCreateFunc:Bool = false)
  {
    FlxG.sound.play(Paths.sound('scrollMenu'));

    if (staticTween != null) staticTween.cancel();

    camGrp.members[0].alpha = (isCreateFunc ? 0.001 : FlxG.random.float(0.4, 0.6));

    staticTween = FlxTween.tween(camGrp.members[0], {alpha: 0.05}, 0.6, {ease: FlxEase.quadOut, onComplete: (t:FlxTween) -> t = null});

    buttonGrp.members[curSelected].animation.play('idle');
    buttonGrp.members[curSelected].alpha = .6;
    buttonGrp.members[curSelected].scale.set(1, 1);
    buttonGrp.members[curSelected].centerOffsets;
    buttonGrp.members[curSelected].updateHitbox();

    pitchGrp.members[curSelected].visible = false;
    pitchGrp.members[curSelected].updateHitbox();

    if (!isMouse)
    {
      curSelected += v;

      if (curUpDownSel == 0)
      {
        if (curSelected >= 2) curSelected = 0;
        if (curSelected < 0) curSelected = 1;
      }
      else if (curUpDownSel == 1)
      {
        if (curSelected >= 4) curSelected = 2;
        if (curSelected < 2) curSelected = 3;
      }
    }
    else
    {
      curSelected = v;

      // for keys support shit
      if (curSelected == 0 || curSelected == 1) curUpDownSel = 0;
      else
        curUpDownSel = 1;
    }

    buttonGrp.members[curSelected].alpha = 1;
    buttonGrp.members[curSelected].scale.set(1.05, 1.05);
    buttonGrp.members[curSelected].centerOffsets;
    pitchGrp.members[curSelected].visible = true;
  }

  function select(value:String = 'title')
  {
    FlxG.mouse.visible = false;

    if (all_shit[curSelected].sticker == null || !all_shit[curSelected].sticker)
    {
      if (staticTween != null) staticTween.cancel();

      camGrp.members[0].alpha = 0.25;

      staticTween = FlxTween.tween(camGrp.members[0], {alpha: 0.075}, 0.35, {ease: FlxEase.quadIn, onComplete: (t:FlxTween) -> t = null});
      FlxTween.tween(camGrp.members[0], {alpha: 1}, 1.25, {ease: FlxEase.cubeInOut, startDelay: 0.35, onComplete: (t:FlxTween) -> t = null});
    }

    var lerpVal:Float = boundTo(FlxG.elapsed * 2.4, 0, 1);
    switch (value)
    {
      case 'custom':
        if (buttonGrp == null)
        {
          FlxG.sound.play(Paths.sound('cancelMenu'));
          trace('fuck, buttonGrp is null!');

          return;
        }

        FlxG.sound.play(Paths.sound('confirmMenu'));
        selected = true;

        if (all_shit[curSelected].sticker == null || !all_shit[curSelected].sticker)
        {
          FlxG.camera.fade(FlxColor.BLACK, 1);

          camStuff.fade(FlxColor.BLACK, 1);
        }

        FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, buttonGrp.members[curSelected].getScreenPosition().x, lerpVal);
        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, buttonGrp.members[curSelected].getScreenPosition().y, lerpVal);

        if (all_shit[curSelected].tag == 'credits' || all_shit[curSelected].tag == 'extras') FlxG.sound.music.fadeOut(1, 0, (_) -> {
          FlxG.sound.music.stop();
        });

        FlxFlicker.flicker(buttonGrp.members[curSelected], 1, 0.06, false, false, (_) -> {
          switch (all_shit[curSelected].tag)
          {
            case 'options':
              psych.options.OptionsState.onPlayState = false;
              if (PlayState.SONG != null)
              {
                PlayState.SONG.arrowSkin = null;
                PlayState.SONG.splashSkin = null;
                PlayState.stageUI = 'normal';
              }
            default: // nothing bitch
          }

          if (all_shit[curSelected].menu != null
            && (all_shit[curSelected].sticker == null
              || !all_shit[curSelected].sticker)) MusicBeatState.switchState(all_shit[curSelected].menu);
          else if (all_shit[curSelected].sticker != null || all_shit[curSelected].sticker)
          {
            switch (all_shit[curSelected].tag)
            {
              case 'worlds':
                openSubState(new StickerSubState(null, (sticker:StickerSubState) -> new StoryMenuState(sticker)));
              case 'extras':
                openSubState(new StickerSubState(null, (sticker:StickerSubState) -> new FreeplayState(sticker)));
              case 'options':
                openSubState(new StickerSubState(null, (sticker:StickerSubState) -> new psych.options.OptionsState(sticker)));
              case 'credits':
                openSubState(new StickerSubState(null, (sticker:StickerSubState) -> new CreditsVideo(sticker)));
            }
          }
        });

        for (i in 0...buttonGrp.members.length)
        {
          if (i == curSelected) continue;

          {
            ease: FlxEase.quadOut,
            onComplete: (_:FlxTween) -> {
              _ = null;
              buttonGrp.members[i].kill();
            }
          };
        }

      default:
        // nothing
    }
  }

  private function musicVolumeFix(e:Float)
  {
    if (FlxG.sound.music != null && FlxG.sound.music.playing) if (FlxG.sound.music.volume < 0.8)
    {
      FlxG.sound.music.volume += 0.5 * e;
      if (FreeplayState.vocals != null && FreeplayState.vocals.playing) FreeplayState.vocals.volume += 0.5 * e;
    }
  }

  private function stuffVariables()
  {
    #if MODS_ALLOWED
    Mods.pushGlobalMods();
    #end
    Mods.loadTopMod();

    #if DISCORD_ALLOWED
    DiscordClient.instance.changePresence({details: "Main Menu"});
    #end

    for (f in cacheShit)
      Paths.image(f);

    transIn = defaultTransIn;
    transOut = defaultTransOut;

    persistentUpdate = persistentUpdate = true;
  }
}

typedef ItemOptions =
{
  var tag:String;
  var ?menu:Null<FlxState>;
  var x:Float;
  var y:Float;
  var ?sticker:Bool;
  var pitch:PitchOptions;
}

typedef PitchOptions =
{
  var name:String;
  var ?addX:Float;
  var ?addY:Float;
  var ?scale:Float;
  var ?prefix:PrefixLol;
  var ?text:String;
}

typedef PrefixLol =
{
  var name:String;
  var anims:Array<AnimData>;
  var idleAnim:String;
}

typedef AnimData =
{
  var name:String;
  var xml:String;
  var fps:Float;
  var ?loop:Bool;
}
