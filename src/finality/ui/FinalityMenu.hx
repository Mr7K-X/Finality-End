package finality.ui;

import finality.shaders.Sharp.SharpEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.misc.NumTween;
import psych.options.OptionsState;
import finality.util.EaseUtil;
import finality.effects.IntervalShake;
import finality.shaders.VHS;
import openfl.filters.ShaderFilter;
import finality.shaders.Bloom;
import finality.util.MathUtil;
import finality.util.SoundUtil;

// TODO: NEW MAIN MENU
class FinalityMenu extends MusicBeatState
{
  static var started:Bool = false;

  final items:Array<String> = ["worlds", "extras", "credits", "options"];

  var itemsSprDat:Array<
    {
      name:String,
      details:MenuSprite,
      text:MenuSprite,
      monitor:MenuSprite,
      hitbox:FlxSprite
    }> = [];

  var tableZone:FlxSprite;
  var bloomTest:Bloom;
  var sharpTest:SharpEffect;
  var vhs:VHS;
  var body:MenuSprite;
  var vcrEffect:VcrGlitchEffect;

  override function create():Void
  {
    Paths.clearUnusedMemory();
    Paths.clearStoredMemory();

    if (FlxG.sound.music == null)
    {
      FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

      if (!started) FlxG.sound.music.stop();
    }

    Conductor.bpm = Constants.MENU_THEME_BPM;

    var bg:MenuSprite = new MenuSprite('bg');
    bg.scrollFactor.set(0.07, 0.07);
    add(bg);

    if (!ClientPrefs.data.lowQuality)
    {
      var upper:MenuSprite = new MenuSprite('upper');
      upper.setPosition(700, 100);
      upper.scrollFactor.set(0.07, 0.07);
      add(upper);
    }

    var screens:FlxSprite = new FlxSprite(-140);
    screens.y = -90;
    screens.frames = Paths.getSparrowAtlas('mainmenu/screens');
    screens.animation.addByPrefix('screens', 'screens', 24, true);
    screens.animation.play('screens');
    screens.antialiasing = ClientPrefs.data.antialiasing;
    screens.updateHitbox();
    screens.alpha = (started ? 1 : 0.001);
    screens.scrollFactor.set(0.12, 0.12);
    add(screens);

    var table:MenuSprite = new MenuSprite('table');
    table.screenCenter(X);
    table.scrollFactor.set(0.12, 0.12);
    table.y += 245;
    add(table);

    var tablAe:MenuSprite = new MenuSprite('table_atributes');
    tablAe.screenCenter(X);
    tablAe.scrollFactor.set(0.12, 0.12);
    tablAe.y += 245;
    add(tablAe);

    vhs = new VHS();
    vhs.uFrame.value = [1];
    vhs.uInterlace.value = [1.0];

    for (i in 0...items.length)
    {
      final name:String = items[i];

      var details:MenuSprite = new MenuSprite('monitors/${name}Details');

      var itemText:MenuSprite = new MenuSprite('monitors/${name}Text');
      itemText.scrollFactor.set(0.12, 0.12);
      itemText.alpha = (started ? .6 : .001);
      itemText.shader = vhs;

      var pos:FlxPoint = new FlxPoint();
      var hitbox:FlxSprite = new FlxSprite();

      switch (name)
      {
        case "worlds":
          pos.set(400, -25);

          hitbox.makeGraphic(128, 117, FlxColor.TRANSPARENT);
          hitbox.setPosition(400, 100);
        case "extras":
          pos.set(395, 275);

          hitbox.makeGraphic(183, 124, FlxColor.TRANSPARENT);
          hitbox.setPosition(395, 275);
        case "options":
          pos.set(725, 240);

          hitbox.makeGraphic(116, 131, FlxColor.TRANSPARENT);
          hitbox.setPosition(725, 240);
        case "credits":
          pos.set(625, 100);

          hitbox.makeGraphic(132, 121, FlxColor.TRANSPARENT);
          hitbox.setPosition(625, 105);
      }

      hitbox.scrollFactor.set(0.12, 0.12);
      hitbox.alpha = 0;
      hitbox.visible = false;

      var item:MenuSprite = new MenuSprite('monitors/$name');
      item.setPosition(pos.x, pos.y);
      item.scrollFactor.set(0.12, 0.12);
      if (details != null) details.setPosition(item.x, item.y);
      itemText.setPosition(item.x, item.y);
      add(item);

      if (!ClientPrefs.data.lowQuality)
      {
        details.scrollFactor.set(0.12, 0.12);
        details.visible = false;
        details.shader = vhs;
        add(details);
      }
      else
      {
        remove(details);
        details = null;
      }
      add(itemText);

      add(hitbox);

      itemsSprDat.push(
        {
          name: name,
          details: (details == null ? null : details),
          text: itemText,
          hitbox: hitbox,
          monitor: item
        });
    }

    for (i in 0...itemsSprDat.length)
    {
      if (itemsSprDat[i].details != null) glitch(itemsSprDat[i].details);
    }

    var pc1:MenuSprite = new MenuSprite('pc_ps');
    pc1.screenCenter(X);
    pc1.y += (230 - 25);
    pc1.scrollFactor.set(0.12, 0.12);
    add(pc1);

    var bgPC:MenuSprite = new MenuSprite('pcBG');
    bgPC.scrollFactor.set(0.12, 0.12);
    bgPC.shader = vhs;
    bgPC.color = (!started ? FlxColor.BLACK : FlxColor.WHITE);
    add(bgPC);

    var animText:FlxSprite = new FlxSprite(560, 295 - (10 + 25 + (!started ? 40 : 0))).loadGraphic(Paths.image('mainmenu/finalityAnim'), true, 1000, 1000);
    animText.animation.add("idle", [0, 1, 2, 3], 6, true);
    animText.animation.play('idle');
    animText.scale.set(.155, .155);
    animText.updateHitbox();
    animText.shader = vhs;
    animText.alpha = (started ? 1 : 0.001);
    animText.scrollFactor.set(0.12, 0.12);
    add(animText);

    var pc:MenuSprite = new MenuSprite('pc');
    pc.screenCenter(X);
    pc.y += (230 - 25);
    pc.scrollFactor.set(0.12, 0.12);
    bgPC.setPosition(pc.x, pc.y);
    add(pc);

    var head:MenuSprite = new MenuSprite('head');
    head.setPosition(852.5 + 10, 340 - 25);
    head.scrollFactor.set(0.12, 0.12);
    add(head);

    if (!ClientPrefs.data.lowQuality)
    {
      body = new MenuSprite('body');
      body.setPosition(1075, 450);
      body.scrollFactor.set(0.2, 0.2);
      add(body);

      var coke:MenuSprite = new MenuSprite('coke');
      coke.setPosition(245 + 10, 365 - 60);
      coke.scrollFactor.set(0.12, 0.12);
      add(coke);

      var overlay:MenuSprite = new MenuSprite('overlay');
      overlay.scrollFactor.set(0.25, 0.25);
      overlay.setGraphicSize(overlay.width * 1);
      overlay.updateHitbox();
      overlay.x -= 10;
      overlay.y -= 10;
      add(overlay);
    }

    super.create();

    tableZone = new FlxSprite(370, 80).makeGraphic(555, 400, FlxColor.TRANSPARENT);
    tableZone.alpha = .0;
    tableZone.scrollFactor.set(0.12, 0.12);
    tableZone.visible = false;
    add(tableZone);

    if (started)
    {
      FlxG.camera.zoom = 1.08;
    }
    else
    {
      FlxG.camera.zoom = 3.5;
      FlxG.camera.scroll.y -= 450;

      var blackout:FlxSprite = new FlxSprite(-100, -100).makeGraphic(1, 1, FlxColor.BLACK);
      blackout.scale.set(FlxG.width * 2, FlxG.height * 2);
      FlxTween.tween(blackout, {alpha: 0}, 2,
        {
          ease: FlxEase.circInOut,
          startDelay: 0.7,
          onComplete: (t:FlxTween) -> {
            t = null;

            remove(blackout);
            blackout.destroy();

            FlxTween.color(bgPC, 0.4, FlxColor.BLACK, FlxColor.WHITE,
              {
                ease: EaseUtil.easeInOutCirc,
                onComplete: (_) -> {
                  FlxTween.tween(animText, {alpha: 1, y: animText.y + 40}, 0.25, {ease: FlxEase.quartOut});

                  new FlxTimer().start(0.1, (_) -> {
                    for (i in 0...itemsSprDat.length)
                    {
                      FlxTween.tween(itemsSprDat[i].text, {alpha: 0.6}, 0.2, {ease: FlxEase.quartInOut});
                    }
                  });
                }
              });

            FlxTween.tween(FlxG.camera, {zoom: 1.08, "scroll.y": 0}, 2.5,
              {
                ease: FlxEase.quadIn,
                onComplete: (t:FlxTween) -> {
                  t = null;
                }
              });
          }
        });
      add(blackout);

      new FlxTimer().start(6, (t:FlxTimer) -> {
        t = null;

        started = true;
        FlxTween.tween(screens, {alpha: 1}, 0.4, {ease: FlxEase.quadOut});
        FlxG.sound.music.play();
        FlxG.sound.music.fadeIn(1, 0, 1);

        FlxG.camera.fade(FlxColor.BLACK, 0.6, true);
      });
    }

    sharpTest = new SharpEffect();
    sharpTest.intensity = .25;

    bloomTest = new Bloom();
    bloomTest.rgba =
      {
        r: 170,
        g: 177,
        b: 232,
        a: 242
      };
    FlxG.camera.filters = [new ShaderFilter(bloomTest.shader), new ShaderFilter(sharpTest.shader)];
    FlxG.signals.postDraw.add(postDraw);

    if (ClientPrefs.data.shaders)
    {
      vcrEffect = new VcrGlitchEffect();
      FlxG.camera.setFilters([new ShaderFilter(vcrEffect.shader)]);
    }
  }

  override function destroy():Void
  {
    if (FlxG.signals.postDraw.has(postDraw)) FlxG.signals.postDraw.remove(postDraw);

    FlxG.camera.bgColor = 0x000000;
    FlxG.camera.filters = [];

    super.destroy();
  }

  var requestedZoom = 0.0;

  function postDraw():Void
  {
    requestedZoom = FlxMath.lerp(1.5, FlxG.camera.zoom, 0.4);

    bloomTest.pos =
      {
        x: (-FlxG.camera.scroll.x * 1.15 + 500) / FlxG.width * requestedZoom,
        y: (-FlxG.camera.scroll.y * 1.15 + 111) / FlxG.height * requestedZoom
      }
  }

  var mouseZoneSelect:Int = 0;
  var mouseItemsSelect:Array<Int> = [0, 0, 0, 0];
  var zoomingCam:FlxTween;
  var curSelected:Int = 0;
  var selected:Bool = false;
  var whiteTween:Array<NumTween> = [null, null, null, null];

  override function update(elapsed:Float):Void
  {
    if (vcrEffect != null) vcrEffect.update(elapsed);

    if (FlxG.sound.music != null && FlxG.sound.music.playing) Conductor.songPosition = FlxG.sound.music.time;
    SoundUtil.volumeMax(0.7, 0.35, FlxG.sound.music);

    if (FlxG.keys.justPressed.R) MusicBeatState.resetState();

    if (started && !selected)
    {
      #if debug
      if (FlxG.keys.anyJustPressed(ClientPrefs.keyBinds.get('debug_1')))
      {
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;
        selected = true;

        FlxG.switchState(() -> new psych.states.editors.MasterEditorMenu());
      }
      #end

      FlxG.mouse.visible = true;

      FlxG.camera.scroll.x = MathUtil.coolLerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX - (FlxG.width / 2)) * .15, 0.153);
      FlxG.camera.scroll.y = MathUtil.coolLerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY - (FlxG.width / 2) - (6 + (mouseZoneSelect == 2 ? 800 : 0))) * .15,
        0.1);

      if (FlxG.mouse.overlaps(tableZone) && mouseZoneSelect < 1)
      {
        mouseZoneSelect = 2;

        if (zoomingCam != null) zoomingCam.cancel();

        zoomingCam = FlxTween.tween(FlxG.camera, {zoom: 1.3}, 0.25,
          {
            ease: FlxEase.circInOut,
            onComplete: (t:FlxTween) -> {
              t = null;
            }
          });
      }
      else if (!FlxG.mouse.overlaps(tableZone) && mouseZoneSelect == 2)
      {
        mouseZoneSelect = 0;

        if (zoomingCam != null) zoomingCam.cancel();

        zoomingCam = FlxTween.tween(FlxG.camera, {zoom: 1.08}, 0.25,
          {
            ease: FlxEase.circIn,
            onComplete: (t:FlxTween) -> {
              t = null;
            }
          });
      }

      for (i in 0...itemsSprDat.length)
      {
        var o:Bool = FlxG.mouse.overlaps(itemsSprDat[i].hitbox);
        if (o && mouseItemsSelect[i] < 1)
        {
          mouseItemsSelect[i] = 2;

          itemsSprDat[i].text.alpha = 1.0;
          if (itemsSprDat[i].details != null) itemsSprDat[i].details.visible = true;

          if (IntervalShake.isShaking(itemsSprDat[i].text)) IntervalShake.stopShaking(itemsSprDat[i].text);

          IntervalShake.shake(itemsSprDat[i].text, 0.15, 0.02, 0.01, 0, FlxEase.quadOut);

          curSelected = i;

          FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        else if (!o && mouseItemsSelect[i] == 2)
        {
          mouseItemsSelect[i] = 0;

          itemsSprDat[i].text.alpha = .6;
          if (itemsSprDat[i].details != null) itemsSprDat[i].details.visible = false;
        }

        if (mouseItemsSelect[i] == 2)
        {
          if (FlxG.mouse.justPressed)
          {
            selected = true;
            FlxG.sound.play(Paths.sound('confirmMenu'));
            selection(i);
          }
        }
      }
    }

    super.update(elapsed);
  }

  function selection(index:Int):Void
  {
    var scrolling:FlxPoint = new FlxPoint();
    var nextState:flixel.FlxState = null;

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;

    for (i in 0...itemsSprDat.length)
    {
      if (index != i) FlxTween.tween(itemsSprDat[i].text, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
    }

    if (timers[0] != null) timers[0].cancel();
    if (timers[1] != null) timers[1].cancel();
    if (timers[2] != null) timers[2].cancel();

    flixel.effects.FlxFlicker.flicker(itemsSprDat[index].text, 1, 0.06, false, false);

    if (IntervalShake.isShaking(itemsSprDat[index].text)) IntervalShake.stopShaking(itemsSprDat[index].text);

    IntervalShake.shake(itemsSprDat[index].text, 1, 0.07, 0.03, 0, FlxEase.quadInOut);

    if (body != null) remove(body);

    if (itemsSprDat[index].details != null) FlxTween.tween(itemsSprDat[index].details, {alpha: 1}, 1, {ease: FlxEase.cubeOut});

    switch (itemsSprDat[index].name)
    {
      case "worlds":
        nextState = new StoryMenuState();
        scrolling.set(-1042, -1512);
        FlxTween.tween(FlxG.camera, {angle: -2.5}, 0.55, {ease: FlxEase.cubeOut, startDelay: 0.2});
      case "extras":
        nextState = new FreeplayState();
        scrolling.set(-1211, -121);
        FlxTween.tween(FlxG.camera, {angle: -1.5}, 0.55, {ease: FlxEase.cubeOut, startDelay: 0.2});
      case "credits":
        nextState = new CreditsVideo();
        scrolling.set(1054, -1319);
        FlxTween.tween(FlxG.camera, {angle: 1.5}, 0.55, {ease: FlxEase.cubeOut, startDelay: 0.2});
      case "options":
        nextState = new OptionsState();

        OptionsState.onPlayState = false;
        if (PlayState.SONG != null)
        {
          PlayState.SONG.arrowSkin = null;
          PlayState.SONG.splashSkin = null;
          PlayState.stageUI = 'normal';
        }

        scrolling.set(1494.2, -521);
        FlxTween.tween(FlxG.camera, {angle: -2.5}, 0.55, {ease: FlxEase.cubeOut, startDelay: 0.2});
    }

    new FlxTimer().start(0.2, (_) -> FlxG.camera.fade(FlxColor.BLACK, 0.45));

    FlxTween.tween(FlxG.camera, {"scroll.x": scrolling.x, "scroll.y": scrolling.y}, 0.67, {ease: FlxEase.quartInOut});
    FlxTween.tween(FlxG.camera, {zoom: 4.25}, 1, {ease: FlxEase.cubeInOut});

    new FlxTimer().start(1, (_) -> {
      MusicBeatState.switchState(nextState);
    });
  }

  var timers:Array<FlxTimer> = [null, null, null];

  function glitch<T:FlxSprite>(spr:T):Void
  {
    if (!selected)
    {
      spr.alpha = FlxG.random.float(0.4, 0.7);

      timers[0] = new FlxTimer().start(FlxG.random.float(.02, .1), (t:FlxTimer) -> {
        t = null;

        spr.alpha = FlxG.random.float(0.23, 0.4);

        timers[1] = new FlxTimer().start(FlxG.random.float(.03, .07), (t:FlxTimer) -> {
          t = null;

          spr.alpha = FlxG.random.float(0.25, 0.91);

          timers[2] = new FlxTimer().start(FlxG.random.float(.04, .12), (t:FlxTimer) -> {
            t = null;

            glitch(spr);
          });
        });
      });
    }
  }
}

private class MenuSprite extends FlxSprite
{
  public function new(image:String):Void
  {
    super(0, 0);

    loadGraphic(Paths.image('mainmenu/$image'));
    antialiasing = ClientPrefs.data.antialiasing;
    updateHitbox();
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }
}
