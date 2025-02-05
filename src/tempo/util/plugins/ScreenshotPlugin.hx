package tempo.util.plugins;

import psych.backend.Paths;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import finality.Finality;
import psych.backend.PsychSetup;
import psych.backend.ClientPrefs;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

typedef ScreenshotPluginParams =
{
  var ?region:Rectangle;
  var shouldHideMouse:Bool;
  var flashColor:Null<FlxColor>;
  var fancyPreview:Bool;
}

class ScreenshotPlugin extends FlxBasic
{
  // STATIC VARIABLES, FUNCTIONS AND ETC.
  public static final DEFAULT_SCREENSHOT_PARAMS:ScreenshotPluginParams =
    {
      flashColor: ClientPrefs.data.flashing ? FlxColor.WHITE : null,
      shouldHideMouse: false,
      fancyPreview: true
    };

  public static function initialize():Void
    FlxG.plugins.addPlugin(new ScreenshotPlugin(DEFAULT_SCREENSHOT_PARAMS));

  public static final PREVIEW_INITIAL_DELAY:Float = .25;
  public static final PREVIEW_FADE_IN_DURATION:Float = .3;
  public static final PREVIEW_FADE_OUT_DELAY:Float = 1.25;
  public static final PREVIEW_FADE_OUT_DURATION:Float = .3;

  // DONT TOUCH THIS ASS (LMAO)
  @:private var _region:Null<Rectangle> = null;
  @:private var _shouldHideMouse:Null<Bool> = null;
  @:private var _flashColor:Null<FlxColor> = null;
  @:private var _fancyPreview:Null<Bool> = null;

  // TOUCH THIS IF YOU CAN (LOL)
  public var onPreScreenshot(default, null):FlxTypedSignal<Void->Void>;
  public var onPostScreenshot(default, null):FlxTypedSignal<Bitmap->Void>;

  public function new(params:ScreenshotPluginParams):Void
  {
    super();

    _region = params?.region ?? null;
    _shouldHideMouse = params.shouldHideMouse;
    _flashColor = params.flashColor;
    _fancyPreview = params.fancyPreview;

    onPreScreenshot = new FlxTypedSignal<Void->Void>();
    onPostScreenshot = new FlxTypedSignal<Bitmap->Void>();
  }

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);
    @:privateAccess if (psych.backend.Controls.instance.justPressed('screenshot')) capture();
  }

  public function capture():Void
  {
    onPreScreenshot.dispatch();

    var wasMouseHidden:Bool = false;
    if (_shouldHideMouse && FlxG.mouse.visible)
    {
      wasMouseHidden = true;
      FlxG.mouse.visible = false;
    }

    final bitmap:Bitmap = new Bitmap(BitmapData.fromImage(FlxG.stage.window.readPixels()));
    if (wasMouseHidden) FlxG.mouse.visible = true;

    saveFile(bitmap);

    showCaptureFeedback();
    if (_fancyPreview) showFancyPreview(bitmap);

    onPostScreenshot.dispatch(bitmap);
  }

  static function saveFile(bitmap:Bitmap):Void
  {
    initPath();
    final targetPath:String = getPath();
    final pngData:ByteArray = encodePNG(bitmap);

    if (pngData == null)
    {
      trace('[WARNING] Failed to encode PNG data. Returning...');
      return;
    }
    else
    {
      trace('File saved to: $targetPath');
      tempo.util.FileUtil.writeBytesToPath(targetPath, pngData);
    }
  }

  static function encodePNG(bitmap:Bitmap):ByteArray
    return bitmap.bitmapData.encode(bitmap.bitmapData.rect, new openfl.display.PNGEncoderOptions());

  static function initPath():Void
  {
    tempo.util.FileUtil.createFolderIfNotExist(Constants.SCREENSHOT_FOLDER);
  }

  static function getPath():String
    return '${Constants.SCREENSHOT_FOLDER}/finality-${DateUtil.generateTimestamp()}.${Constants.EXT_IMAGE}';

  final FLASH_DURATION:Float = .15;

  function showCaptureFeedback():Void
  {
    @:privateAccess var flashBitmap:Bitmap = new Bitmap(new BitmapData(PsychSetup.gameData.w, PsychSetup.gameData.h, false));
    var flashSpr:Sprite = new Sprite();
    flashSpr.addChild(flashBitmap);
    Finality.instance.addChild(flashSpr);
    FlxTween.tween(flashSpr, {alpha: 0}, FLASH_DURATION,
      {
        ease: FlxEase.quadOut,
        onComplete: (t:FlxTween) -> {
          t = null;
          Finality.instance.addChild(flashSpr);
        }
      });

    FlxG.sound.play(flixel.system.FlxAssets.getSound(Paths.getLibraryPath('sounds/screenshot.${Constants.EXT_SOUND}', 'embed')));
  }

  function openScreenshotsFolder(e:MouseEvent):Void
  {
    psych.backend.CoolUtil.openFolder(Constants.SCREENSHOT_FOLDER);
  }

  function showFancyPreview(bitmap:Bitmap):Void
  {
    // ermmm stealing this??
    var wasMouseHidden = false;
    if (!FlxG.mouse.visible)
    {
      wasMouseHidden = true;
      FlxG.mouse.visible = false;
    }

    // so that it doesnt change the alpha when tweening in/out
    var changingAlpha:Bool = false;

    // fuck it, cursed locally scoped functions, purely because im lazy
    // (and so we can check changingAlpha, which is locally scoped.... because I'm lazy...)
    final onHover = (e:MouseEvent) -> if (!changingAlpha) e.target.alpha = 0.6;
    final onHoverOut = (e:MouseEvent) -> if (!changingAlpha) e.target.alpha = 1;
    final scale:Float = .25;
    final w:Int = Std.int(bitmap.bitmapData.width * scale);
    final h:Int = Std.int(bitmap.bitmapData.height * scale);

    var preview:BitmapData = new BitmapData(w, h, true);
    var matrix:openfl.geom.Matrix = new openfl.geom.Matrix();

    matrix.scale(scale, scale);
    preview.draw(bitmap.bitmapData, matrix);

    // used for movement + button stuff
    var previewSprite = new Sprite();
    previewSprite.buttonMode = true;
    previewSprite.addEventListener(MouseEvent.MOUSE_DOWN, openScreenshotsFolder);
    previewSprite.addEventListener(MouseEvent.MOUSE_OVER, onHover);
    previewSprite.addEventListener(MouseEvent.MOUSE_OUT, onHoverOut);
    Finality.instance.addChild(previewSprite);

    previewSprite.alpha = 0.0;
    previewSprite.y -= 10;

    var previewBitmap = new Bitmap(preview);
    previewSprite.addChild(previewBitmap);

    new FlxTimer().start(PREVIEW_INITIAL_DELAY, (t:FlxTimer) -> {
      t = null;

      // Fade in.
      changingAlpha = true;
      FlxTween.tween(previewSprite, {alpha: 1.0, y: 0}, PREVIEW_FADE_IN_DURATION,
        {
          ease: FlxEase.quartOut,
          onComplete: (t:FlxTween) -> {
            t = null;
            changingAlpha = false;

            // Wait to fade out.
            new FlxTimer().start(PREVIEW_FADE_OUT_DELAY, (t:FlxTimer) -> {
              t = null;
              changingAlpha = true;

              // Fade out.
              FlxTween.tween(previewSprite, {alpha: 0.0, y: 10}, PREVIEW_FADE_OUT_DURATION,
                {
                  ease: FlxEase.quartInOut,
                  onComplete: (t:FlxTween) -> {
                    t = null;
                    if (wasMouseHidden) FlxG.mouse.visible = false;

                    previewSprite.removeEventListener(MouseEvent.MOUSE_DOWN, openScreenshotsFolder);
                    previewSprite.removeEventListener(MouseEvent.MOUSE_OVER, onHover);
                    previewSprite.removeEventListener(MouseEvent.MOUSE_OUT, onHoverOut);
                    Finality.instance.removeChild(previewSprite);
                  }
                });
            });
          }
        });
    });
  }
}
