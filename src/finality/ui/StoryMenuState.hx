package finality.ui;

import flixel.addons.transition.FlxTransitionableState;
import psych.backend.Highscore;
import psych.substates.StickerSubState;
import psych.backend.Song;
import psych.backend.WeekData;
import psych.substates.GameplayChangersSubstate;
import psych.substates.ResetScoreSubState;
import flixel.addons.display.FlxRuntimeShader;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import psych.objects.MenuCharacter;
import psych.objects.MenuItem;
import openfl.filters.ShaderFilter;

class StoryMenuState extends MusicBeatState
{
  public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

  var scoreText:FlxText;

  private static var curWeek:Int = 0;

  var curDifficulty:Int = 1;

  private static var lastDifficultyName:String = '';

  var backgrounds:FlxTypedGroup<FlxSprite>;

  var bgShader:FlxRuntimeShader;

  var lock:FlxSprite;

  var loadedWeeks:Array<WeekData> = [];

  var stickerSubState:StickerSubState;

  var camGame:FlxCamera;
  var camStick:FlxCamera;

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
    camGame = initPsychCamera();

    camStick = new FlxCamera();
    camStick.bgColor.alpha = 0;
    FlxG.cameras.add(camStick, false);

    if (stickerSubState != null)
    {
      stickerSubState.cameras = [camStick];
      @:privateAccess
      stickerSubState.grpStickers.cameras = [camStick];
    }
    else
      Paths.clearStoredMemory();

    Paths.clearUnusedMemory();

    PlayState.isStoryMode = true;
    WeekData.reloadWeekFiles(true);

    if (curWeek >= WeekData.weeksList.length) curWeek = 0;

    persistentUpdate = persistentDraw = true;

    bgShader = new FlxRuntimeShader(shaderInfo);

    bgShader.setFloat('iTime', 0);
    bgShader.setFloat('vignetteMult', 1);
    backgrounds = new FlxTypedGroup<FlxSprite>();
    add(backgrounds);

    #if DISCORD_ALLOWED
    // Updating Discord Rich Presence
    DiscordClient.instance.changePresence({details: "In the Menus"});
    #end

    var num:Int = 0;
    for (i in 0...WeekData.weeksList.length)
    {
      var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
      var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
      if (!isLocked || !weekFile.hiddenUntilUnlocked)
      {
        loadedWeeks.push(weekFile);
        WeekData.setDirectoryFromWeek(weekFile);

        addWeek(weekFile.weekBackground, weekFile.weekName, isLocked);
        num++;
      }
    }

    WeekData.setDirectoryFromWeek(loadedWeeks[0]);

    scoreText = new FlxText(0, 20, FlxG.width, 'Score: 0');
    scoreText.setFormat(Paths.font("HelpMe.ttf"), 32, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
    scoreText.scrollFactor.set();
    add(scoreText);

    lock = new FlxSprite(0, 520).loadGraphic(Paths.image('storymenu/lock'));
    lock.screenCenter();
    lock.alpha = 0;
    lock.scale.set(1.2, 1.2);
    add(lock);

    var par:FlxSprite = new FlxSprite();
    par.frames = Paths.getSparrowAtlas('par');
    par.animation.addByPrefix('par', 'par', 1, false);
    par.animation.play('par');
    par.antialiasing = ClientPrefs.data.antialiasing;
    par.updateHitbox();
    par.scrollFactor.set();
    add(par);

    changeItem();

    super.create();

    camGame.filters = [new ShaderFilter(bgShader)];

    if (stickerSubState != null)
    {
      openSubState(stickerSubState);
      stickerSubState.degenStickers();
    }
  }

  function addWeek(name:String, iconName:String, ?isLocked:Bool = false):FlxSprite
  {
    var itemID = backgrounds.length;
    var spr = new FlxSprite(itemID * FlxG.width).loadGraphic(Paths.image('storymenu/backgrounds/' + name));
    spr.ID = itemID;
    backgrounds.add(spr);

    return spr;
  }

  function weekIsLocked(name:String):Bool
  {
    var leWeek:WeekData = WeekData.weeksLoaded.get(name);
    trace(name);
    return (!leWeek.startUnlocked
      && leWeek.weekBefore.length > 0
      && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
  }

  override function closeSubState()
  {
    persistentUpdate = true;
    changeItem();
    super.closeSubState();
  }

  var selectedWeek:Bool = false;

  override function update(elapsed:Float)
  {
    lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
    if (Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

    scoreText.text = "WEEK SCORE:" + lerpScore;

    bgShader.setFloat('iTime', bgShader.getFloat('iTime') + elapsed);

    if (!selectedWeek)
    {
      if (controls.UI_LEFT_P)
      {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        changeItem(-1);
      }

      if (controls.UI_RIGHT_P)
      {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        changeItem(1);
      }

      if (controls.ACCEPT)
      {
        selectedWeek = true;

        FlxTween.tween(FlxG.camera, {alpha: 0, zoom: 5}, 0.8, {ease: FlxEase.quartInOut, startDelay: 0, onComplete: _ -> selectWeek()});
        FlxTween.num(1, 0, 0.8, {ease: FlxEase.quartInOut, startDelay: 0}, _ -> bgShader.setFloat('vignetteMult', _));
      }
      if (controls.BACK)
      {
        selectedWeek = true;
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        FlxG.sound.play(Paths.sound('cancelMenu'));
        MusicBeatState.switchState(new FinalityMenu());
      }
    }
    super.update(elapsed);
  }

  var stopspamming:Bool = false;

  function selectWeek()
  {
    if (!weekIsLocked(loadedWeeks[curWeek].fileName))
    {
      // We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
      var songArray:Array<String> = [];
      var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
      for (i in 0...leWeek.length)
      {
        songArray.push(leWeek[i][0]);
      }

      // Nevermind that's stupid lmao
      try
      {
        PlayState.storyPlaylist = songArray;
        PlayState.isStoryMode = true;

        var diffic = Difficulty.getFilePath(curDifficulty);
        if (diffic == null) diffic = '';

        PlayState.storyDifficulty = curDifficulty;

        PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
        PlayState.campaignScore = 0;
        PlayState.campaignMisses = 0;
      }
      catch (e:Dynamic)
      {
        trace('ERROR! $e');
        return;
      }

      LoadingState.loadAndSwitchState(new PlayState(), true);
      FreeplayState.destroyFreeplayVocals();
    }
    else
      FlxG.sound.play(Paths.sound('cancelMenu'));
  }

  var lerpScore:Int = 0;
  var intendedScore:Int = 0;

  function changeItem(?v:Int = 0)
  {
    curWeek += v;

    if (curWeek < 0) curWeek = backgrounds.length - 1;

    if (curWeek > backgrounds.length - 1) curWeek = 0;

    var leWeek:WeekData = loadedWeeks[curWeek];
    WeekData.setDirectoryFromWeek(leWeek);

    PlayState.storyWeek = curWeek;

    Difficulty.loadFromWeek();

    if (Difficulty.list.contains(Difficulty.getDefault())) curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
    else
      curDifficulty = 0;

    var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
    // trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
    if (newPos > -1) curDifficulty = newPos;

    #if ! switch
    intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
    #end

    FlxTween.cancelTweensOf(FlxG.camera.scroll);
    FlxTween.tween(FlxG.camera.scroll, {x: FlxG.width * (curWeek)}, 0.8, {ease: FlxEase.sineInOut, startDelay: 0.2});

    backgrounds.forEach(spr -> {
      FlxTween.cancelTweensOf(spr);
      FlxTween.color(spr, 0.6, spr.color, spr.ID == curWeek ? 0xFFFFFFFF : 0xFF000000, {ease: FlxEase.sineInOut});
    });

    if (weekIsLocked(loadedWeeks[curWeek].fileName))
    {
      var nowCurrent = curWeek;
      FlxTween.cancelTweensOf(lock);
      FlxTween.tween(lock, {y: 300, alpha: 1}, 0.4,
        {
          ease: FlxEase.sineInOut,
          startDelay: 0.9,
          onStart: _ -> {
            lock.x = 560 + FlxG.width * nowCurrent;
            lock.y = 280;
            lock.alpha = 0;
          }
        });
    }
    else
    {
      // lock.visible = false;
    }
  }

  private static var shaderInfo:String = '
    #pragma header

    #define round(a) floor(a + 0.5)
    #define iResolution vec3(openfl_TextureSize, 0.)
    uniform float iTime;
    uniform float vignetteMult;
    #define iChannel0 bitmap
    uniform sampler2D iChannel1;
    uniform sampler2D iChannel2;
    uniform sampler2D iChannel3;
    #define texture flixel_texture2D

    // third argument fix
    vec4 flixel_texture2D(sampler2D bitmap, vec2 coord, float bias) {
    	vec4 color = texture2D(bitmap, coord, bias);
    	if (!hasTransform)
    	{
    		return color;
    	}
    	if (color.a == 0.0)
    	{
    		return vec4(0.0, 0.0, 0.0, 0.0);
    	}
    	if (!hasColorTransform)
    	{
    		return color * openfl_Alphav;
    	}
    	color = vec4(color.rgb / color.a, color.a);
    	mat4 colorMultiplier = mat4(0);
    	colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
    	colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
    	colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
    	colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
    	color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
    	if (color.a > 0.0)
    	{
    		return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
    	}
    	return vec4(0.0, 0.0, 0.0, 0.0);
    }

    // variables which is empty, they need just to avoid crashing shader
    uniform float iTimeDelta;
    uniform float iFrameRate;
    uniform int iFrame;
    #define iChannelTime float[4](iTime, 0., 0., 0.)
    #define iChannelResolution vec3[4](iResolution, vec3(0.), vec3(0.), vec3(0.))
    uniform vec4 iMouse;
    uniform vec4 iDate;

        float onOff(float a, float b, float c)
        {
            return step(c, sin(iTime + a*cos(iTime*b)));
        }

        float ramp(float y, float start, float end)
        {
            float inside = step(start,y) - step(end,y);
            float fact = (y-start)/(end-start)*inside;
            return (1.-fact) * inside;

        }

        vec4 getVideo(vec2 uv)
          {
            vec2 look = uv;
                float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
                look.x = look.x + (sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window)*(0.1*2.);
                float vShift = 0.4*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) +
                                                     (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
                look.y = mod(look.y + vShift*0.1, 1.);

            vec4 video = texture(iChannel0,look);

            return video;
          }

        vec2 screenDistort(vec2 uv)
        {
            uv = (uv - 0.5) * 2.0;
            uv *= 1.1;
            uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
            uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
            uv  = (uv / 2.0) + 0.5;
            uv =  uv *0.92 + 0.04;
            return uv;

            return uv;
        }
        float random(vec2 uv)
        {
            return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
        }
        float noise(vec2 uv)
        {
            vec2 i = floor(uv);
            vec2 f = fract(uv);

            float a = random(i);
            float b = random(i + vec2(1.,0.));
            float c = random(i + vec2(0., 1.));
            float d = random(i + vec2(1.));

            vec2 u = smoothstep(0., 1., f);

            return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;

        }


        vec2 scandistort(vec2 uv) {
            float scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
            float scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0) ;
            float amount = scan1 * scan2 * uv.x;

            //uv.x -= 0.05 * mix(texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.9);

            return uv;

        }
        void mainImage( out vec4 fragColor, in vec2 fragCoord )
        {
            vec2 uv = fragCoord/iResolution.xy;
          vec2 curUV = screenDistort(uv);
            uv = scandistort(curUV);
            vec4 video = getVideo(uv);
          float vigAmt = 1.0;
          float x =  0.;


          video.r = getVideo(vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
          video.g = getVideo(vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
          video.b = getVideo(vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
          video.r += 0.08*getVideo(0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
          video.g += 0.05*getVideo(0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
          video.b += 0.08*getVideo(0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

          video = clamp(video*0.6+0.4*video*video*1.0,0.0,1.0);
              vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));

            float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));

             video *= vignette * vignetteMult;


          fragColor = mix(video,vec4(noise(uv * 75.)),.05);

          if(curUV.x<0. || curUV.x>1. || curUV.y<0. || curUV.y>1.){
            fragColor = vec4(0.,0.,0.,texture(iChannel0, uv).a);
          }

        }

        void main() {
            mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
        }
    ';
}
