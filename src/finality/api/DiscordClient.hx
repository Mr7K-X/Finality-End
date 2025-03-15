package finality.api;

import psych.backend.ClientPrefs;
import cpp.RawConstPointer;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import sys.thread.Thread;
import Sys.println as print;
import Sys.sleep;

class DiscordClient
{
  private inline static final DEFAULT_ID:String = "1270730583278096475";

  public static var clientID(default, set):String = DEFAULT_ID;
  public static var instance(get, never):DiscordClient;

  @:unreflective private static var __thread:Thread;

  static var initialized:Bool = false;
  static var _instance:Null<DiscordClient> = null;

  private var handlers:DiscordEventHandlers;

  private function new()
  {
    print('Discord Client: Initializing event handlers...');

    handlers = DiscordEventHandlers.create();
    handlers.ready = cpp.Function.fromStaticFunction(ready);
    handlers.disconnected = cpp.Function.fromStaticFunction(disconnected);
    handlers.errored = cpp.Function.fromStaticFunction(errored);
  }

  public function initialize():Void
  {
    print("Discord Client: Initializing connection...");

    Discord.Initialize(clientID, cpp.RawPointer.addressOf(handlers), 1, null);

    if (__thread == null)
    {
      __thread = Thread.create(() -> {
        while (true)
        {
          if (initialized)
          {
            #if DISCORD_DISABLE_IO_THREAD
            Discord.updateConnection();
            #end
            Discord.runCallbacks();
          }

          sleep(2);
        }
      });
    }

    initialized = true;
  }

  public function shutdown():Void
  {
    print('Discord Client: Shutting down...');
    initialized = false;

    Discord.shutdown();
  }

  public function changePresence(?params:Null<DiscordPresenceParams> = null):Void
  {
    if (!initialized || !ClientPrefs.data.discordRPC) return;

    if (params == null) params =
      {
        details: "In the Menus"
      };

    print('Discord Rich Presence Changed: ${params.details + (cast(' / ' + params?.state, String) ?? '') + (cast(' / ' + params?.largeImageKey, String) ?? '') + (cast(' / ' + params?.largeImageText, String) ?? '') + (cast(' / ' + params?.smallImageKey, String) ?? '') + (cast(' / ' + params?.smallImageText, String) ?? '')}');

    Discord.updatePresence(buildPresence(params));
  }

  private function buildPresence(params:DiscordPresenceParams):DiscordRichPresence
  {
    var presence:DiscordRichPresence = DiscordRichPresence.create();
    presence.type = DiscordActivityType_Playing;

    presence.details = cast(params.details, Null<String>);
    presence.state = cast(params.state, Null<String>);
    presence.largeImageText = cast(params.largeImageText, Null<String>) ?? Constants.VERSION;
    presence.largeImageKey = cast(params.largeImageKey, Null<String>) ?? "icon";
    presence.smallImageText = cast(params.smallImageText, Null<String>);
    presence.smallImageKey = cast(params.smallImageKey, Null<String>);

    final button1:DiscordButton = DiscordButton.create();
    button1.label = "Game Page";
    button1.url = "https://gamebanana.com/mods/538437";
    presence.buttons[0] = button1;

    final button2:DiscordButton = DiscordButton.create();
    button2.label = "Discord server";
    button2.url = "https://discord.gg/HvgydnkC8C";
    presence.buttons[1] = button2;

    return presence;
  }

  static function ready(request:cpp.RawConstPointer<DiscordUser>):Void
  {
    print('Discord Client: Connected!');

    final username:String = request[0].username;
    final globalname:String = request[0].username;
    final discriminator:Int = Std.parseInt(request[0].discriminator);

    if (discriminator != 0) print('Discord Client: User - $username#$discriminator (${globalname})');
    else
      print('Discord Client: User - @$username (${globalname})');

    DiscordClient.instance.changePresence();
  }

  static function disconnected(code:Int, msg:cpp.ConstCharStar):Void
    print('Discord Client: Disconnected! ($code:$msg)');

  static function errored(code:Int, msg:cpp.ConstCharStar):Void
    print('Discord Client: Error! ($code:$msg)');

  public static function prepare():Void
  {
    if (!initialized && psych.backend.ClientPrefs.data.discordRPC) DiscordClient.instance.initialize();

    lime.app.Application.current.window.onClose.add(() -> {
      if (initialized) DiscordClient.instance.shutdown();
    });
  }

  public static function check():Void
  {
    if (initialized && !psych.backend.ClientPrefs.data.discordRPC) DiscordClient.instance.shutdown();
    else
      prepare();
  }

  public static function resetClientID()
    clientID = DEFAULT_ID;

  static function set_clientID(value:String):String
  {
    var change:Bool = (clientID != value);
    clientID = value;

    if (change && initialized)
    {
      DiscordClient.instance.shutdown();
      DiscordClient.instance.initialize();
    }

    return value;
  }

  static function get_instance():DiscordClient
  {
    if (DiscordClient._instance == null) _instance = new DiscordClient();
    if (DiscordClient._instance == null) throw "Could not initialize singleton DiscordClient!";
    return DiscordClient._instance;
  }
}
