package tempo.ui.preload;

// openfl import
import finality.util.WindowsUtil;
import openfl.Lib;
import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.display.Bitmap;
#if TOUCH_HERE_TO_PLAY
import openfl.events.MouseEvent;
#end
import tempo.ui.preload.bitmaps.*;
import finality.util.EaseUtil;

class TempoPreloader extends flixel.system.FlxBasePreloader
{
  @:noUsing public static var instance:TempoPreloader;

  var ratio:Float = 0.0;
  var currentState:TempoPreloaderState = NotStarted;

  var downloadingAssetsPercent:Float = -1;
  var downloadingAssetsComplete:Bool = false;

  var preloadingPlayAssetsPercent:Float = -1;
  var preloadingPlayAssetsStartTime:Float = -1;
  var preloadingPlayAssetsComplete:Bool = false;

  var cachingGraphicsPercent:Float = -1;
  var cachingGraphicsStartTime:Float = -1;
  var cachingGraphicsComplete:Bool = false;

  var cachingAudioPercent:Float = -1;
  var cachingAudioStartTime:Float = -1;
  var cachingAudioComplete:Bool = false;

  var cachingDataPercent:Float = -1;
  var cachingDataStartTime:Float = -1;
  var cachingDataComplete:Bool = false;

  var parsingSpritesheetsPercent:Float = -1;
  var parsingSpritesheetsStartTime:Float = -1;
  var parsingSpritesheetsComplete:Bool = false;

  var parsingStagesPercent:Float = -1;
  var parsingStagesStartTime:Float = -1;
  var parsingStagesComplete:Bool = false;

  var parsingCharactersPercent:Float = -1;
  var parsingCharactersStartTime:Float = -1;
  var parsingCharactersComplete:Bool = false;

  var parsingSongsPercent:Float = -1;
  var parsingSongsStartTime:Float = -1;
  var parsingSongsComplete:Bool = false;

  var initializingScriptsPercent:Float = -1;

  var cachingCoreAssetsPercent:Float = -1;
  var completeTime:Float = -1;

  /**
   * Print for command line.
   * @param value printing string value
   * @return push in command line a value
   */
  public function print(value:Any):Void
    Sys.println(' -$value');

  public function new()
  {
    instance = this;

    super(Constants.PRELOADER_MIN_STAGE_TIME);

    Sys.println('Preloader:');
  }

  // other
  var logo:Bitmap;

  // progress
  var progressBarPiecesOfCakes:Array<Sprite>;
  var progressLines:Sprite;
  var progressLeftText:TextField;
  var progressRightText:TextField;

  // text
  var box:Sprite;
  var dspText:TextField;
  var fnfText:TextField;
  var tempoText:TextField;
  var enhancedText:TextField;
  var stereoText:TextField;

  // touch to sex
  #if TOUCH_HERE_TO_PLAY
  var touchHereToPlay:Bitmap;
  var touchHereSprite:Sprite;
  #end

  override function create():Void
  {
    super.create();

    Lib.current.stage.color = Constants.COLOR_PRELOADER_BG;

    this._width = Lib.current.stage.stageWidth;
    this._height = Lib.current.stage.stageHeight;

    ratio = this._width / Constants.PRELOADER_BASE_WIDTH / 2.0;

    logo = createBitmap(LogoImage, (/*lol*/ bpm:Bitmap) -> {
      bpm.scaleX = bpm.scaleY = ratio / 1.95;
      bpm.x = (this._width - bpm.width) / 2;
      bpm.y = (this._height - bpm.height) / 2;
    });
    logo.smoothing = true;

    // cake is a lie
    var amountOfPieceOfCake:Int = 32;
    var maxBarWidth:Float = (this._width - Constants.PRELOADER_BAR_PADDING) * 2;
    var cakeWidth:Float = maxBarWidth / amountOfPieceOfCake;
    var cakeGap:Int = 8;

    progressBarPiecesOfCakes = [];

    progressLines = new Sprite();
    progressLines.graphics.lineStyle(2, Constants.COLOR_PRELOADER_BAR);
    progressLines.graphics.drawRect(-2, 600, this._width + 4, 22.5);
    addChild(progressLines);

    for (i in 0...amountOfPieceOfCake)
    {
      var piece:Sprite = new Sprite();
      piece.graphics.beginFill(Constants.COLOR_PRELOADER_BAR);
      piece.graphics.drawRoundRect(0, 0, cakeWidth - cakeGap, Constants.PRELOADER_BAR_HEIGHT, 4, 4);
      piece.graphics.endFill();

      piece.x = i * (piece.width + cakeGap);
      piece.y = this._height - Constants.PRELOADER_BAR_PADDING - Constants.PRELOADER_BAR_HEIGHT - 82.5;
      addChild(piece);
      progressBarPiecesOfCakes.push(piece);
    }

    progressLeftText = new TextField();
    progressLeftText.defaultTextFormat = new TextFormat(Paths.font('DS-DIGI.TTF'), 32, Constants.COLOR_PRELOADER_BAR, true);
    progressLeftText.defaultTextFormat.align = TextFormatAlign.LEFT;
    progressLeftText.selectable = false;
    progressLeftText.width = this._width - Constants.PRELOADER_BAR_PADDING * 2;
    progressLeftText.text = 'Downloading assets...';
    progressLeftText.x = Constants.PRELOADER_BAR_PADDING;
    progressLeftText.y = this._height - Constants.PRELOADER_BAR_PADDING - Constants.PRELOADER_BAR_HEIGHT - 185;
    // progressLeftText.shader = new VFDOverlay();
    addChild(progressLeftText);

    // Create the progress %.
    progressRightText = new TextField();
    progressRightText.defaultTextFormat = new TextFormat(Paths.font('DS-DIGI.TTF'), 16, Constants.COLOR_PRELOADER_BAR, true);
    progressRightText.defaultTextFormat.align = TextFormatAlign.RIGHT;
    progressRightText.selectable = false;
    progressRightText.width = this._width - Constants.PRELOADER_BAR_PADDING * 2;
    progressRightText.text = '0%';
    progressRightText.x = Constants.PRELOADER_BAR_PADDING;
    progressRightText.y = this._height - Constants.PRELOADER_BAR_PADDING - Constants.PRELOADER_BAR_HEIGHT - 16 + 16;
    addChild(progressRightText);

    dspText = new TextField();
    fnfText = new TextField();
    tempoText = new TextField();
    enhancedText = new TextField();
    stereoText = new TextField();

    box = new Sprite();
    box.graphics.beginFill(Constants.COLOR_PRELOADER_BAR, 1);
    // DSP
    box.graphics.drawRoundRect(0, 0, 64, 20, 5, 5);
    // FNF
    box.graphics.drawRoundRect(145, 0, 65, 20, 5, 5);
    // TEMPO
    box.graphics.drawRoundRect(65, 0, 75, 20, 5, 5);
    box.graphics.endFill();
    box.graphics.beginFill(Constants.COLOR_PRELOADER_BAR, 0.1);
    // ENHANCED
    box.graphics.drawRoundRect(0, 0, 128, 20, 5, 5);
    box.graphics.endFill();
    box.x = 880;
    box.y = 532.5;
    addChild(box);

    dspText.selectable = false;
    dspText.textColor = 0x000000;
    dspText.width = this._width;
    dspText.height = 40;
    dspText.text = 'DSP';
    dspText.x = 10;
    dspText.y = -6.5;
    box.addChild(dspText);

    fnfText.selectable = false;
    fnfText.textColor = 0x000000;
    fnfText.width = this._width;
    fnfText.height = 40;
    fnfText.x = 147.5;
    fnfText.y = -6.5;
    fnfText.text = 'FENA';
    box.addChild(fnfText);

    tempoText.selectable = false;
    tempoText.textColor = 0x000000;
    tempoText.width = this._width;
    tempoText.height = 40;
    tempoText.x = 65;
    tempoText.y = -6.5;
    tempoText.text = 'TEMPO';
    box.addChild(tempoText);

    enhancedText.selectable = false;
    enhancedText.textColor = Constants.COLOR_PRELOADER_BAR;
    enhancedText.width = this._width;
    enhancedText.height = 100;
    enhancedText.text = 'ENHANCED';
    enhancedText.x = -100;
    enhancedText.y = 0;
    box.addChild(enhancedText);

    stereoText.selectable = false;
    stereoText.textColor = Constants.COLOR_PRELOADER_BAR;
    stereoText.width = this._width;
    stereoText.height = 100;
    stereoText.text = 'STEREO';
    stereoText.x = 0;
    stereoText.y = -40;
    box.addChild(stereoText);

    #if TOUCH_HERE_TO_PLAY
    touchHereToPlay = createBitmap(TouchHereToPlayImage, (bmp:Bitmap) -> {
      // Scale and center the touch to start image.
      // We have to do this inside the async call, after the image size is known.
      bmp.scaleX = bmp.scaleY = ratio;
      bmp.x = (this._width - bmp.width) / 2;
      bmp.y = (this._height - bmp.height) / 2;
    });
    touchHereToPlay.alpha = 0.0;

    touchHereSprite = new Sprite();
    touchHereSprite.buttonMode = false;
    touchHereSprite.addChild(touchHereToPlay);
    addChild(touchHereSprite);
    #end

    #if windows
    WindowsUtil.goAheadIco();
    #end
  }

  private var lastElapsed:Float = 0;

  override function update(percent:Float):Void
  {
    var elapsed:Float = (Date.now().getTime() - this._startTime) / 1000;

    downloadingAssetsPercent = percent;
    var loadPercent:Float = TempoPreloaderUpdater.updateState(percent, elapsed);
    updateGraphics(loadPercent, elapsed);

    lastElapsed = elapsed;
  }

  #if TOUCH_HERE_TO_PLAY
  function overTouchHereToPlay(e:MouseEvent):Void
  {
    touchHereToPlay.scaleX = touchHereToPlay.scaleY = ratio * 1.1;
    touchHereToPlay.x = (this._width - touchHereToPlay.width) / 2;
    touchHereToPlay.y = (this._height - touchHereToPlay.height) / 2;
  }

  function outTouchHereToPlay(e:MouseEvent):Void
  {
    touchHereToPlay.scaleX = touchHereToPlay.scaleY = ratio * 1;
    touchHereToPlay.x = (this._width - touchHereToPlay.width) / 2;
    touchHereToPlay.y = (this._height - touchHereToPlay.height) / 2;
  }

  function mouseDownTouchHereToPlay(e:MouseEvent):Void
  {
    touchHereToPlay.y += 10;
  }

  function onTouchHereToPlay(e:MouseEvent):Void
  {
    touchHereToPlay.x = (this._width - touchHereToPlay.width) / 2;
    touchHereToPlay.y = (this._height - touchHereToPlay.height) / 2;

    removeEventListener(MouseEvent.CLICK, onTouchHereToPlay);
    touchHereSprite.removeEventListener(MouseEvent.MOUSE_OVER, overTouchHereToPlay);
    touchHereSprite.removeEventListener(MouseEvent.MOUSE_OUT, outTouchHereToPlay);
    touchHereSprite.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownTouchHereToPlay);

    // This is the actual thing that makes the game load.
    immediatelyStartGame();
  }
  #end

  function updateGraphics(percent:Float, elapsed:Float):Void
  {
    // Render logo (including transitions)
    if (completeTime > 0.0)
    {
      var elapsedFinished:Float = renderLogoFadeOut(elapsed);
      // print('Fading out logo... (' + elapsedFinished + 's)');
      if (elapsedFinished > Constants.PRELOADER_LOGO_FADE_TIME)
      {
        #if TOUCH_HERE_TO_PLAY
        // The logo has faded out, but we're not quite done yet.
        // In order to prevent autoplay issues, we need the user to click after the loading finishes.
        currentState = TouchHereToPlay;
        #else
        immediatelyStartGame();
        #end
      }
    }
    else
    {
      renderLogoFadeIn(elapsed);

      // Render progress bar
      var piecesToRender:Int = Std.int(percent * progressBarPiecesOfCakes.length);

      for (i => piece in progressBarPiecesOfCakes)
      {
        piece.alpha = i <= piecesToRender ? 0.9 : 0.1;
      }
    }

    // Cycle ellipsis count to show loading
    var ellipsisCount:Int = Std.int(elapsed / Constants.PRELOADER_ELLIPSIS_TIME) % 3 + 1;
    var ellipsis:String = '';
    for (i in 0...ellipsisCount)
      ellipsis += '.';

    var percentage:Int = Math.floor(percent * 100);
    // Render status text
    switch (currentState)
    {
      case Downloading:
        updateProgressLeftText('Downloading \n1/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      case Preloading:
        updateProgressLeftText('Preloading \n2/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      case Initializing:
        updateProgressLeftText('Initializing scripts \n3/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      case GraphicCaching:
        updateProgressLeftText('Caching graphics \n4/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      case AudioCaching:
        updateProgressLeftText('Caching audio \n5/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      case DataCaching:
        updateProgressLeftText('Caching data \n6/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      case SpritesheetParsing:
        updateProgressLeftText('Parsing spritesheets \n7/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      case StageParsing:
        updateProgressLeftText('Parsing stages \n8/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      case CharacterParsing:
        updateProgressLeftText('Parsing characters \n9/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      case SongParsing:
        updateProgressLeftText('Parsing songs \n10/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      case Complete:
        updateProgressLeftText('Finishing up \n${Constants.PRELOADER_TOTAL_STEPS}/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        // print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      #if TOUCH_HERE_TO_PLAY
      case TouchHereToPlay:
        updateProgressLeftText(null);
        // print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
      #end
      default:
        updateProgressLeftText('Loading \n0/${Constants.PRELOADER_TOTAL_STEPS} $ellipsis');
        print(currentState + ' (' + percentage + '%, ' + elapsed + 's)');
    }

    // Render percent text
    progressRightText.text = '$percentage%';

    super.update(percent);
  }

  function updateProgressLeftText(text:Null<String>):Void
  {
    if (progressLeftText != null)
    {
      if (text == null)
      {
        progressLeftText.alpha = 0.0;
      }
      else if (progressLeftText.text != text)
      {
        // We have to keep updating the text format, because the font can take a frame or two to load.
        progressLeftText.defaultTextFormat = new TextFormat(Paths.font("DS-DIGI.TTF"), 32, Constants.COLOR_PRELOADER_BAR, true);
        progressLeftText.defaultTextFormat.align = TextFormatAlign.LEFT;
        progressLeftText.text = text;

        dspText.defaultTextFormat = new TextFormat(Paths.font("Quantico-Regular.ttf"), 20, 0x000000, false);
        dspText.text = 'DSP'; // fukin dum....
        dspText.textColor = 0x000000;

        fnfText.defaultTextFormat = new TextFormat(Paths.font("Quantico-Regular.ttf"), 20, 0x000000, false);
        fnfText.text = 'FENA';
        fnfText.textColor = 0x000000;

        tempoText.defaultTextFormat = new TextFormat(Paths.font("Quantico-Regular.ttf"), 20, 0x000000, false);
        tempoText.text = 'TEMPO';
        tempoText.textColor = 0x000000;

        enhancedText.defaultTextFormat = new TextFormat(Paths.font("Inconsolata-Bold.ttf"), 16, Constants.COLOR_PRELOADER_BAR, false);
        enhancedText.text = 'ENHANCED';
        enhancedText.textColor = Constants.COLOR_PRELOADER_BAR;

        stereoText.defaultTextFormat = new TextFormat(Paths.font("Inconsolata-Bold.ttf"), 36, Constants.COLOR_PRELOADER_BAR, false);
        stereoText.text = 'NATURAL STEREO';
      }
    }
  }

  function immediatelyStartGame():Void
  {
    _loaded = true;
  }

  /**
   * Fade out the logo.
   * @param	elapsed Elapsed time since the preloader started.
   * @return	Elapsed time since the logo started fading out.
   */
  function renderLogoFadeOut(elapsed:Float):Float
  {
    // Fade-out takes Constants.PRELOADER_LOGO_FADE_TIME seconds.
    var elapsedFinished = elapsed - completeTime;

    logo.alpha = 1.0 - EaseUtil.easeInOutCirc(elapsedFinished / Constants.PRELOADER_LOGO_FADE_TIME);
    logo.scaleX = (1.0 - EaseUtil.easeInBack(elapsedFinished / Constants.PRELOADER_LOGO_FADE_TIME)) * ratio / 1.95;
    logo.scaleY = (1.0 - EaseUtil.easeInBack(elapsedFinished / Constants.PRELOADER_LOGO_FADE_TIME)) * ratio / 1.95;
    logo.x = (this._width - logo.width) / 2;
    logo.y = (this._height - logo.height) / 2 - 100;

    // Fade out progress bar too.
    // progressBar.alpha = logo.alpha;
    progressLeftText.alpha = logo.alpha;
    progressRightText.alpha = logo.alpha;
    box.alpha = logo.alpha;
    dspText.alpha = logo.alpha;
    fnfText.alpha = logo.alpha;
    tempoText.alpha = logo.alpha;
    enhancedText.alpha = logo.alpha;
    stereoText.alpha = logo.alpha;
    progressLines.alpha = logo.alpha;

    for (piece in progressBarPiecesOfCakes)
      piece.alpha = logo.alpha;

    return elapsedFinished;
  }

  function renderLogoFadeIn(elapsed:Float):Void
  {
    // Fade-in takes Constants.PRELOADER_LOGO_FADE_TIME seconds.
    logo.alpha = EaseUtil.easeInOutCirc(elapsed / Constants.PRELOADER_LOGO_FADE_TIME);
    logo.scaleX = EaseUtil.easeOutBack(elapsed / Constants.PRELOADER_LOGO_FADE_TIME) * ratio;
    logo.scaleY = EaseUtil.easeOutBack(elapsed / Constants.PRELOADER_LOGO_FADE_TIME) * ratio;
    logo.x = (this._width - logo.width) / 2;
    logo.y = (this._height - logo.height) / 2;
  }

  #if html5
  // These fields only exist on Web builds.

  /**
   * Format the text of the site lock screen.
   */
  override function adjustSiteLockTextFields(titleText:TextField, bodyText:TextField, hyperlinkText:TextField):Void
  {
    var titleFormat = titleText.defaultTextFormat;
    titleFormat.align = TextFormatAlign.CENTER;
    titleFormat.color = Constants.COLOR_PRELOADER_LOCK_FONT;
    titleText.setTextFormat(titleFormat);

    var bodyFormat = bodyText.defaultTextFormat;
    bodyFormat.align = TextFormatAlign.CENTER;
    bodyFormat.color = Constants.COLOR_PRELOADER_LOCK_FONT;
    bodyText.setTextFormat(bodyFormat);

    var hyperlinkFormat = hyperlinkText.defaultTextFormat;
    hyperlinkFormat.align = TextFormatAlign.CENTER;
    hyperlinkFormat.color = Constants.COLOR_PRELOADER_LOCK_LINK;
    hyperlinkText.setTextFormat(hyperlinkFormat);
  }
  #end

  override function destroy():Void
  {
    // Ensure the graphics are properly destroyed and GC'd.
    removeChild(logo);
    // removeChild(progressBar);
    logo = null;
    super.destroy();
  }

  override function onLoaded():Void
  {
    super.onLoaded();
    // We're not ACTUALLY finished.
    // This function gets called when the DownloadingAssets step is done.
    // We need to wait for the other steps, then the logo to fade out.
    _loaded = false;
    downloadingAssetsComplete = true;
  }
}

/**
 * All percent states
 */
enum TempoPreloaderState
{
  NotStarted;
  Downloading;
  Preloading;
  Initializing;
  GraphicCaching;
  AudioCaching;
  DataCaching;
  SpritesheetParsing;
  SongParsing;
  StageParsing;
  CharacterParsing;
  Complete;

  #if TOUCH_HERE_TO_PLAY
  TouchHereToPlay;
  #end
}
