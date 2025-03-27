package psych.backend;

import flixel.util.FlxGradient;

class CustomFadeTransition extends MusicBeatSubstate
{
  var _fadeIn:Null<Bool> = null;
  var _onComplete:Null<Void->Void> = null;
  var _timer:Null<Float> = null;
  var _isBlack:Null<Bool> = null;

  public function new(timer:Float, ?fadeIn:Bool = true, ?newCamera:FlxCamera, ?onComplete:Void->Void, ?isBlack:Bool = false):Void
  {
    super();

    this.camera = (newCamera == null ? cameras[cameras.length - 1] : newCamera);

    _fadeIn = fadeIn;
    _onComplete = onComplete;
    _timer = timer;
    _isBlack = isBlack;

    trans();
  }

  function trans():Void
  {
    if (_fadeIn)
    {
      if (_isBlack)
      {
        var black:FlxSprite = new FlxSprite(-1, -1).makeGraphic(FlxG.width + 2, FlxG.height + 2, FlxColor.BLACK);
        black.updateHitbox();
        black.scrollFactor.set();
        black.alpha = .001;

        FlxTween.tween(black, {alpha: 1}, _timer, {ease: FlxEase.quadInOut});

        add(black);

        new FlxTimer().start(_timer, (_) -> (_onComplete != null ? _onComplete() : {}));
      }
      else
      {
        var jaw:FlxSprite = new FlxSprite();
        jaw.frames = Paths.getSparrowAtlas('transitionSwag/jaw');
        jaw.animation.addByPrefix('jaw', 'jaw', 38, false);
        jaw.animation.play('jaw');
        jaw.antialiasing = ClientPrefs.data.antialiasing;
        jaw.updateHitbox();
        jaw.scrollFactor.set();
        add(jaw);

        new FlxTimer().start(1 / 2, (_) -> (_onComplete != null ? _onComplete() : {}));
      }
    }
    else
    {
      if (!_isBlack)
      {
        var jaw:FlxSprite = new FlxSprite();
        jaw.frames = Paths.getSparrowAtlas('transitionSwag/jaw');
        jaw.animation.addByPrefix('jaw', 'jaw', 38, false);
        jaw.animation.play('jaw', false, true);
        jaw.antialiasing = ClientPrefs.data.antialiasing;
        jaw.updateHitbox();
        jaw.scrollFactor.set();
        add(jaw);

        new FlxTimer().start(1 / 2, (_) -> {
          jaw.kill();
          remove(jaw);
          jaw.destroy();
        });
      }
      else
      {
        var black:FlxSprite = new FlxSprite(-1, -1).makeGraphic(FlxG.width + 2, FlxG.height + 2, FlxColor.BLACK);
        black.updateHitbox();
        black.scrollFactor.set();
        black.alpha = 1;

        FlxTween.tween(black, {alpha: .001}, _timer,
          {
            ease: FlxEase.quadInOut,
            onComplete: (_) -> {
              black.kill();
              remove(black);
              black.destroy();
            }
          });

        add(black);

        new FlxTimer().start(_timer, (_) -> {
          if (_onComplete != null) _onComplete();

          close();
        });
      }
    }
  }
}
