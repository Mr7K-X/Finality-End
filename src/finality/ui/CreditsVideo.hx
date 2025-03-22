package finality.ui;

import psych.substates.StickerSubState;

class CreditsVideo extends MusicBeatState
{
  var fileName:String = 'spyye';

  var stickerSubState:StickerSubState;

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
    if (stickerSubState != null)
    {
      openSubState(stickerSubState);
      stickerSubState.degenStickers();
      // FlxG.sound.playMusic(Paths.music('freakyMenu'));
    }
    // bitch
    super.create();

    if (FileSystem.exists(Paths.video(fileName)))
    {
      // nothing for now
    }
    else
    {
      Sys.println('Hold on! File don\'t exists!');
      Sys.sleep(1.0);
      MusicBeatState.switchState(new FinalityMenu());
    }
  }
}
