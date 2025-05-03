package psych.states.debug.backend;

class AboutSubState extends MusicBeatSubstate
{
  var cam:FlxCamera;
  var secret:FlxSprite;

  public function new(title:String, desc:String, author:String, width:Float, height:Float)
  {
    super();

    cam = new FlxCamera();
    cam.bgColor.alpha = 0;
    FlxG.cameras.add(cam, false);

    this.cameras = [cam];
    this.camera = cam;

    var bg:FlxSprite = new FlxSprite(-1, -1).makeGraphic(FlxG.width + 2, FlxG.height + 2, FlxColor.BLACK);
    bg.scrollFactor.set();
    bg.alpha = .6;
    add(bg);

    var back:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
    back.scale.set(width + 2, height + 2);
    back.scrollFactor.set();
    back.screenCenter();
    add(back);

    var back:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
    back.scale.set(width, height);
    back.scrollFactor.set();
    back.screenCenter();
    add(back);

    secret = new FlxSprite().loadGraphic(Paths.image('editors/secret'));
    secret.setGraphicSize(width, height);
    secret.alpha = .001;
    secret.scrollFactor.set();
    secret.screenCenter();
    add(secret);

    var titleText = new FlxText(0, 0, FlxG.width, title, 32);
    titleText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
    titleText.scrollFactor.set();
    titleText.screenCenter();
    titleText.y -= 100;
    add(titleText);

    var des = new FlxText(0, 0, FlxG.width, desc, 18);
    des.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
    des.scrollFactor.set();
    des.screenCenter();
    des.y -= 50;
    add(des);

    var aut = new FlxText(0, 0, FlxG.width, author, 20);
    aut.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
    aut.scrollFactor.set();
    aut.screenCenter();
    aut.y += 40;
    add(aut);

    FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
  }

  var secretT:FlxTween;
  var secretPress:Bool = false;

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (Controls.instance.BACK)
    {
      FlxG.state.persistentUpdate = false;
      FlxG.sound.play(Paths.sound('cancelMenu'), 0.7);
      close();
    }

    if (FlxG.keys.justPressed.V)
    {
      secretPress = !secretPress;

      if (secretT != null) secretT.cancel();

      secretT = FlxTween.tween(secret, {alpha: (secretPress ? 1.0 : .001)}, 0.4,
        {
          ease: FlxEase.bounceInOut,
          onComplete: (t) -> {
            t = null;
          }
        });
    }
  }

  override function destroy():Void
  {
    FlxG.cameras.remove(cam);

    super.destroy();
  }
}
