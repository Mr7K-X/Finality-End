package tempo.preload;

import tempo.util.Constants;
import openfl.events.MouseEvent;
import tempo.preload.TempoPreloader as TP;

@:access(tempo.preload.TempoPreloader)
class TempoPreloaderUpdater
{
  public static function updateState(percent:Float, elapsed:Float):Float
  {
    switch (TP.instance.currentState)
    {
      case NotStarted:
        if (TP.instance.downloadingAssetsPercent > 0.0) TP.instance.currentState = Downloading;

        return percent;

      case Downloading:
        if (TP.instance.downloadingAssetsPercent >= 1.0
          || (elapsed > Constants.PRELOADER_MIN_STAGE_TIME
            && TP.instance.downloadingAssetsComplete)) TP.instance.currentState = Preloading;

        return percent;

      case Preloading:
        if (TP.instance.preloadingPlayAssetsPercent < 0.0)
        {
          TP.instance.preloadingPlayAssetsStartTime = elapsed;
          TP.instance.preloadingPlayAssetsPercent = 0.0;
          TP.instance.preloadingPlayAssetsPercent = 1.0;
          TP.instance.preloadingPlayAssetsComplete = true;
          return 0.0;
        }
        else if (Constants.PRELOADER_MIN_STAGE_TIME > 0)
        {
          var elapsedPreloadingPlayAssets:Float = elapsed - TP.instance.preloadingPlayAssetsStartTime;
          if (TP.instance.preloadingPlayAssetsComplete && elapsedPreloadingPlayAssets >= Constants.PRELOADER_MIN_STAGE_TIME)
          {
            TP.instance.currentState = Initializing;
            return 0.0;
          }
          else
          {
            if (TP.instance.preloadingPlayAssetsPercent < (elapsedPreloadingPlayAssets / Constants.PRELOADER_MIN_STAGE_TIME)) return
              TP.instance.preloadingPlayAssetsPercent;
            else
              return elapsedPreloadingPlayAssets / Constants.PRELOADER_MIN_STAGE_TIME;
          }
        }
        else
        {
          if (TP.instance.preloadingPlayAssetsComplete) TP.instance.currentState = Initializing;
        }

        return TP.instance.preloadingPlayAssetsPercent;

      case Initializing:
        if (TP.instance.initializingScriptsPercent < 0.0)
        {
          TP.instance.initializingScriptsPercent = 0.0;
          TP.instance.initializingScriptsPercent = 1.0;
          TP.instance.currentState = GraphicCaching;
          return 0.0;
        }

        return TP.instance.initializingScriptsPercent;

      case GraphicCaching:
        if (TP.instance.cachingGraphicsPercent < 0)
        {
          TP.instance.cachingGraphicsPercent = 0.0;
          TP.instance.cachingGraphicsStartTime = elapsed;
          TP.instance.cachingGraphicsPercent = 1.0;
          TP.instance.cachingGraphicsComplete = true;
          return 0.0;
        }
        else if (Constants.PRELOADER_MIN_STAGE_TIME > 0)
        {
          var elapsedCachingGraphics:Float = elapsed - TP.instance.cachingGraphicsStartTime;
          if (TP.instance.cachingGraphicsComplete && elapsedCachingGraphics >= Constants.PRELOADER_MIN_STAGE_TIME)
          {
            TP.instance.currentState = AudioCaching;
            return 0.0;
          }
          else
          {
            if (TP.instance.cachingGraphicsPercent < (elapsedCachingGraphics / Constants.PRELOADER_MIN_STAGE_TIME))
            {
              return TP.instance.cachingGraphicsPercent;
            }
            else
            {
              return elapsedCachingGraphics / Constants.PRELOADER_MIN_STAGE_TIME;
            }
          }
        }
        else
        {
          if (TP.instance.cachingGraphicsComplete)
          {
            TP.instance.currentState = AudioCaching;
            return 0.0;
          }
          else
          {
            return TP.instance.cachingGraphicsPercent;
          }
        }

      case AudioCaching:
        if (TP.instance.cachingAudioPercent < 0)
        {
          TP.instance.cachingAudioPercent = 0.0;
          TP.instance.cachingAudioStartTime = elapsed;

          var assetsToCache:Array<String> = [];
          TP.instance.cachingAudioPercent = 1.0;
          TP.instance.cachingAudioComplete = true;
          return 0.0;
        }
        else if (Constants.PRELOADER_MIN_STAGE_TIME > 0)
        {
          var elapsedCachingAudio:Float = elapsed - TP.instance.cachingAudioStartTime;
          if (TP.instance.cachingAudioComplete && elapsedCachingAudio >= Constants.PRELOADER_MIN_STAGE_TIME)
          {
            TP.instance.currentState = DataCaching;
            return 0.0;
          }
          else
          {
            if (TP.instance.cachingAudioPercent < (elapsedCachingAudio / Constants.PRELOADER_MIN_STAGE_TIME))
            {
              return TP.instance.cachingAudioPercent;
            }
            else
            {
              return elapsedCachingAudio / Constants.PRELOADER_MIN_STAGE_TIME;
            }
          }
        }
        else
        {
          if (TP.instance.cachingAudioComplete)
          {
            TP.instance.currentState = DataCaching;
            return 0.0;
          }
          else
          {
            return TP.instance.cachingAudioPercent;
          }
        }

      case DataCaching:
        if (TP.instance.cachingDataPercent < 0)
        {
          TP.instance.cachingDataPercent = 0.0;
          TP.instance.cachingDataStartTime = elapsed;

          var assetsToCache:Array<String> = [];
          var sparrowFramesToCache:Array<String> = [];

          TP.instance.cachingDataPercent = 1.0;
          TP.instance.cachingDataComplete = true;
          return 0.0;
        }
        else if (Constants.PRELOADER_MIN_STAGE_TIME > 0)
        {
          var elapsedCachingData:Float = elapsed - TP.instance.cachingDataStartTime;
          if (TP.instance.cachingDataComplete && elapsedCachingData >= Constants.PRELOADER_MIN_STAGE_TIME)
          {
            TP.instance.currentState = SpritesheetParsing;
            return 0.0;
          }
          else
          {
            if (TP.instance.cachingDataPercent < (elapsedCachingData / Constants.PRELOADER_MIN_STAGE_TIME)) return TP.instance.cachingDataPercent;
            else
              return elapsedCachingData / Constants.PRELOADER_MIN_STAGE_TIME;
          }
        }
        else
        {
          if (TP.instance.cachingDataComplete)
          {
            TP.instance.currentState = SpritesheetParsing;
            return 0.0;
          }
        }

        return TP.instance.cachingDataPercent;

      case SpritesheetParsing:
        if (TP.instance.parsingSpritesheetsPercent < 0)
        {
          TP.instance.parsingSpritesheetsPercent = 0.0;
          TP.instance.parsingSpritesheetsStartTime = elapsed;

          var sparrowFramesToCache = [];

          TP.instance.parsingSpritesheetsPercent = 1.0;
          TP.instance.parsingSpritesheetsComplete = true;
          return 0.0;
        }
        else if (Constants.PRELOADER_MIN_STAGE_TIME > 0)
        {
          var elapsedParsingSpritesheets:Float = elapsed - TP.instance.parsingSpritesheetsStartTime;
          if (TP.instance.parsingSpritesheetsComplete && elapsedParsingSpritesheets >= Constants.PRELOADER_MIN_STAGE_TIME)
          {
            TP.instance.currentState = StageParsing;
            return 0.0;
          }
          else
          {
            if (TP.instance.parsingSpritesheetsPercent < (elapsedParsingSpritesheets / Constants.PRELOADER_MIN_STAGE_TIME)) return
              TP.instance.parsingSpritesheetsPercent;
            else
              return elapsedParsingSpritesheets / Constants.PRELOADER_MIN_STAGE_TIME;
          }
        }
        else
        {
          if (TP.instance.parsingSpritesheetsComplete)
          {
            TP.instance.currentState = StageParsing;
            return 0.0;
          }
        }

        return TP.instance.parsingSpritesheetsPercent;

      case StageParsing:
        if (TP.instance.parsingStagesPercent < 0)
        {
          TP.instance.parsingStagesPercent = 0.0;
          TP.instance.parsingStagesStartTime = elapsed;
          TP.instance.parsingStagesPercent = 1.0;
          TP.instance.parsingStagesComplete = true;
          return 0.0;
        }
        else if (Constants.PRELOADER_MIN_STAGE_TIME > 0)
        {
          var elapsedParsingStages:Float = elapsed - TP.instance.parsingStagesStartTime;
          if (TP.instance.parsingStagesComplete && elapsedParsingStages >= Constants.PRELOADER_MIN_STAGE_TIME)
          {
            TP.instance.currentState = CharacterParsing;
            return 0.0;
          }
          else
          {
            if (TP.instance.parsingStagesPercent < (elapsedParsingStages / Constants.PRELOADER_MIN_STAGE_TIME)) return TP.instance.parsingStagesPercent;
            else
              return elapsedParsingStages / Constants.PRELOADER_MIN_STAGE_TIME;
          }
        }
        else
        {
          if (TP.instance.parsingStagesComplete)
          {
            TP.instance.currentState = CharacterParsing;
            return 0.0;
          }
        }

        return TP.instance.parsingStagesPercent;

      case CharacterParsing:
        if (TP.instance.parsingCharactersPercent < 0)
        {
          TP.instance.parsingCharactersPercent = 0.0;
          TP.instance.parsingCharactersStartTime = elapsed;
          TP.instance.parsingCharactersPercent = 1.0;
          TP.instance.parsingCharactersComplete = true;
          return 0.0;
        }
        else if (Constants.PRELOADER_MIN_STAGE_TIME > 0)
        {
          var elapsedParsingCharacters:Float = elapsed - TP.instance.parsingCharactersStartTime;
          if (TP.instance.parsingCharactersComplete && elapsedParsingCharacters >= Constants.PRELOADER_MIN_STAGE_TIME)
          {
            TP.instance.currentState = SongParsing;
            return 0.0;
          }
          else
          {
            if (TP.instance.parsingCharactersPercent < (elapsedParsingCharacters / Constants.PRELOADER_MIN_STAGE_TIME)) return
              TP.instance.parsingCharactersPercent;
            else
              return elapsedParsingCharacters / Constants.PRELOADER_MIN_STAGE_TIME;
          }
        }
        else
        {
          if (TP.instance.parsingStagesComplete)
          {
            TP.instance.currentState = SongParsing;
            return 0.0;
          }
        }

        return TP.instance.parsingCharactersPercent;

      case SongParsing:
        if (TP.instance.parsingSongsPercent < 0)
        {
          TP.instance.parsingSongsPercent = 0.0;
          TP.instance.parsingSongsStartTime = elapsed;
          TP.instance.parsingSongsPercent = 1.0;
          TP.instance.parsingSongsComplete = true;

          return 0.0;
        }
        else if (Constants.PRELOADER_MIN_STAGE_TIME > 0)
        {
          var elapsedParsingSongs:Float = elapsed - TP.instance.parsingSongsStartTime;
          if (TP.instance.parsingSongsComplete && elapsedParsingSongs >= Constants.PRELOADER_MIN_STAGE_TIME)
          {
            TP.instance.currentState = Complete;
            return 0.0;
          }
          else
          {
            if (TP.instance.parsingSongsPercent < (elapsedParsingSongs / Constants.PRELOADER_MIN_STAGE_TIME))
            {
              return TP.instance.parsingSongsPercent;
            }
            else
            {
              return elapsedParsingSongs / Constants.PRELOADER_MIN_STAGE_TIME;
            }
          }
        }
        else
        {
          if (TP.instance.parsingSongsComplete)
          {
            TP.instance.currentState = Complete;
            return 0.0;
          }
          else
          {
            return TP.instance.parsingSongsPercent;
          }
        }
      case Complete:
        if (TP.instance.completeTime < 0)
        {
          TP.instance.completeTime = elapsed;
        }

        return 1.0;

      #if TOUCH_HERE_TO_PLAY
      case TouchHereToPlay:
        if (TP.instance.completeTime < 0)
        {
          TP.instance.completeTime = elapsed;
        }

        if (TP.instance.touchHereToPlay.alpha < 1.0)
        {
          TP.instance.touchHereSprite.buttonMode = true;
          TP.instance.touchHereToPlay.alpha = 1.0;

          TP.instance.addEventListener(MouseEvent.CLICK, TP.instance.onTouchHereToPlay);
          TP.instance.touchHereSprite.addEventListener(MouseEvent.MOUSE_OVER, TP.instance.overTouchHereToPlay);
          TP.instance.touchHereSprite.addEventListener(MouseEvent.MOUSE_DOWN, TP.instance.mouseDownTouchHereToPlay);
          TP.instance.touchHereSprite.addEventListener(MouseEvent.MOUSE_OUT, TP.instance.outTouchHereToPlay);
        }

        return 1.0;
      #end

      default:
        // Do nothing.
    }

    return 0.0;
  }
}
