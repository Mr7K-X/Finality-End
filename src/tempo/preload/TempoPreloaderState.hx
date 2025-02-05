package tempo.preload;

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
