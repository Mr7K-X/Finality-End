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
      }
      else
      {
        var jaw1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('transitionSwag/jaw1'));
        jaw1.antialiasing = ClientPrefs.data.antialiasing;
        jaw1.updateHitbox();
        jaw1.scrollFactor.set();

        var jaw2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('transitionSwag/jaw2'));
        jaw2.antialiasing = ClientPrefs.data.antialiasing;
        jaw2.updateHitbox();
        jaw2.scrollFactor.set();

        jaw1.y = -FlxG.height;
        jaw2.y = FlxG.height;

        FlxTween.tween(jaw1, {y: 0}, _timer, {ease: FlxEase.expoInOut});
        FlxTween.tween(jaw2, {y: 0}, _timer, {ease: FlxEase.expoInOut});

        add(jaw2);
        add(jaw1);
      }

      new FlxTimer().start(_timer, (_) -> (_onComplete != null ? _onComplete() : {}));
    }
    else
    {
      if (!_isBlack)
      {
        var jaw1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('transitionSwag/jaw1'));
        jaw1.antialiasing = ClientPrefs.data.antialiasing;
        jaw1.updateHitbox();
        jaw1.scrollFactor.set();

        var jaw2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('transitionSwag/jaw2'));
        jaw2.antialiasing = ClientPrefs.data.antialiasing;
        jaw2.updateHitbox();
        jaw2.scrollFactor.set();

        FlxTween.tween(jaw1, {y: -FlxG.height}, _timer,
          {
            ease: FlxEase.expoInOut, // lol
            onComplete: (_) -> {
              jaw1.kill();
              remove(jaw1);
              jaw1.destroy();
            }
          });
        FlxTween.tween(jaw2, {y: FlxG.height}, _timer,
          {
            ease: FlxEase.expoInOut,
            onComplete: (_) -> {
              jaw2.kill();
              remove(jaw2);
              jaw2.destroy();
            }
          });

        add(jaw2);
        add(jaw1);
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
      }

      new FlxTimer().start(_timer, (_) -> {
        if (_onComplete != null) _onComplete();

        close();
      });
    }
  }
}
