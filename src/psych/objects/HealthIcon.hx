package psych.objects;

import flixel.graphics.frames.FlxFrame;

class HealthIcon extends FlxSprite
{
  public var sprTracker:FlxSprite;

  private var isOldIcon:Bool = false;
  private var isPlayer:Bool = false;
  private var char:String = '';

  public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
  {
    super();
    isOldIcon = (char == 'bf-old');
    this.isPlayer = isPlayer;
    changeIcon(char, allowGPU);
    scrollFactor.set();
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (sprTracker != null) setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
  }

  private var iconOffsets:Array<Float> = [0, 0];
  private var data:HealthIconAnim = null;

  public function changeIcon(char:String, ?allowGPU:Bool = true)
  {
    if (this.char != char)
    {
      var name:String = 'icons/' + char;
      if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; // Older versions of psych engine's support
      if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; // Prevents crash from missing icon

      if (Paths.fileExists('images/' + name + '.xml', TEXT) && Paths.fileExists('images/' + name + '.png', IMAGE))
      {
        frames = Paths.getSparrowAtlas(name);

        #if MODS_ALLOWED
        if (FileSystem.exists(Paths.getPath('images/$name.json', TEXT, null, true)))
        #else
        if (openfl.Assets.exists(Paths.getPath('images/$name.json')))
        #end
        {
          data = tjson.TJSON.parse(#if MODS_ALLOWED File.getContent(Paths.getPath('images/$name.json', TEXT, null,
            true)) #else openfl.Assets.getText(Paths.getPath('images/$name.json')) #end);
          trace(data);
        }

        if (data != null)
        {
          animation.addByPrefix('idle', data.animations[0], 24, true);

          if (data.animations[1] != null) animation.addByPrefix('lose', data.animations[1], 24, true);
          if (data.animations[2] != null) animation.addByPrefix('win', data.animations[2], 24, true);
        }
        else
        {
          animation.addByPrefix('idle', 'idle', 24.0, true);

          addPrefixAnim('lose', ['losing', 'death']);
          addPrefixAnim('win', ['winning', 'win']);

          iconOffsets[0] = (frameWidth - 150);
          iconOffsets[1] = (frameHeight - 150);
        }

        updateHitbox();
      }
      else if (!Paths.fileExists('images/' + name + '.xml', TEXT)
        && Paths.fileExists('images/' + name + '.png', IMAGE)) // idk how this work
      {
        var graphic = Paths.image(name, allowGPU);

        if (graphic.width > 449)
        {
          loadGraphic(graphic, true, Math.floor(graphic.width / 3), Math.floor(graphic.height));
          iconOffsets[0] = (width - 150) / 3;

          animation.add('lose', [1], 0, false, isPlayer);
          animation.add('win', [2], 0, false, isPlayer);
        }
        else if (graphic.width > 299)
        {
          loadGraphic(graphic, true, Math.floor(graphic.width / 2), Math.floor(graphic.height));
          iconOffsets[0] = (width - 150) / 2;

          animation.add('lose', [1], 0, false, isPlayer);
        }
        else if (graphic.width > 149)
        {
          loadGraphic(graphic, true, Math.floor(graphic.width), Math.floor(graphic.height));
          iconOffsets[0] = (width - 150);
        }

        iconOffsets[1] = (height - 150) / 2;

        updateHitbox();

        animation.add('idle', [0], 0, false, isPlayer);
      }

      animation.play('idle');
      this.char = char;

      if (char.endsWith('-pixel')) antialiasing = false;
      else
        antialiasing = ClientPrefs.data.antialiasing;
    }
  }

  @:access(flixel.animation.FlxAnimationController)
  function addPrefixAnim(name:String, prefixes:Array<String>):Void
  {
    if (name == null || prefixes == null)
    {
      trace("Not adding a prefix animations, because values are NULL!");
      return;
    }

    for (prefix in prefixes)
    {
      var a:Array<FlxFrame> = [];

      animation.findByPrefix(a, prefix);
      if (a.length < 1) animation.findByPrefix(a, prefix); // second try
      else
        animation.addByPrefix(name, prefix);

      if (a.length < 1)
      {
        trace('Cannot find a "$name" animation! Please check "${Std.string(prefixes)}" animations!');
        return;
      }
      else
        animation.addByPrefix(name, prefix);
    }
  }

  public var autoAdjustOffset:Bool = true;

  override function updateHitbox()
  {
    super.updateHitbox();

    if (autoAdjustOffset)
    {
      if (data != null)
      {
        if (animation != null && animation.curAnim != null)
        {
          if (animation.exists('idle') && animation.curAnim.name == "idle")
          {
            offset.x = data.animationsOffsets.idle[0];
            offset.y = data.animationsOffsets.idle[1];
          }
          else if (animation.exists('lose') && animation.curAnim.name == "lose")
          {
            offset.x = (data.animationsOffsets.lose != null ? data.animationsOffsets.lose[0] : data.animationsOffsets.idle[0]);
            offset.y = (data.animationsOffsets.lose != null ? data.animationsOffsets.lose[1] : data.animationsOffsets.idle[1]);
          }
          else if (animation.exists('win') && animation.curAnim.name == "win")
          {
            offset.x = (data.animationsOffsets.win != null ? data.animationsOffsets.win[0] : data.animationsOffsets.idle[0]);
            offset.y = (data.animationsOffsets.win != null ? data.animationsOffsets.win[1] : data.animationsOffsets.idle[1]);
          }
        }
      }
      else
      {
        offset.x = iconOffsets[0];
        offset.y = iconOffsets[1];
      }
    }
  }

  public function getCharacter():String
  {
    return char;
  }
}

typedef HealthIconAnim =
{
  animations:Array<String>,
  animationsOffsets:
  {
    idle:Array<Float>, ?lose:Array<Float>, ?win:Array<Float>
  }
}
