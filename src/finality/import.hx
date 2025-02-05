#if (!macro && !DISABLED_MACRO_SUPERLATIVE)
import finality.shaders.VCRShader;
// Discord API
#if DISCORD_ALLOWED
import tempo.api.DiscordClient;
#end
// Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end
#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end
// for no cringe~~ mrzk
import finality.Finality as Main;
import psych.backend.Paths;
import psych.backend.Controls;
import psych.backend.CoolUtil;
import psych.backend.MusicBeatState;
import psych.backend.MusicBeatSubstate;
import psych.backend.CustomFadeTransition;
import psych.backend.ClientPrefs;
import psych.backend.Conductor;
import psych.backend.BaseStage;
import psych.backend.Difficulty;
import psych.backend.Mods;
import psych.objects.Alphabet;
import psych.objects.BGSprite;
import psych.states.PlayState;
import psych.states.LoadingState;
import tempo.util.Constants;
#if flxanimate
import flxanimate.*;
#end
// Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

// Using commands, cool stuff btw    ~mrzk
using Lambda;
using Map;
using StringTools;
using thx.Arrays;
using tempo.util.tools.ArraySortTools;
using tempo.util.tools.ArrayTools;
using tempo.util.tools.Int64Tools;
using tempo.util.tools.IntTools;
using tempo.util.tools.IteratorTools;
using tempo.util.tools.MapTools;
using tempo.util.tools.StringTools;
#end
