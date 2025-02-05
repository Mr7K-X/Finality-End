package finality.ui;

import hxcodec.flixel.FlxVideo;
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
      var video:FlxVideo = new FlxVideo();
      // Recent versions
      video.play(Paths.video(fileName));
      video.onEndReached.add(() -> {
        FlxG.sound.music.fadeIn(4, 0, 0.7);
        MusicBeatState.switchState(new MainMenuState());
      }, true);
    }
    else
    {
      Sys.println('Hold on! File don\'t exists!');
      Sys.sleep(1.0);
      MusicBeatState.switchState(new MusicBeatState());
    }
  }
}
