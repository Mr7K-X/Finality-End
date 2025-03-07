package building; // i know

#if sys
import sys.io.File;
import sys.FileSystem;
#end

/**
 * A script which executes before the game is built.
 */
class Prebuild
{
  static final timeFile:String = '.time';
  static final buildPrint:String = "BUILDING...";

  static function main():Void
  {
    saveBuildTime();

    var symbol:String = '';

    for (l in 0...buildPrint.length)
      symbol += '=';

    #if sys
    Sys.println('\n$symbol\n$buildPrint\n$symbol\n');
    #end
  }

  static function saveBuildTime():Void
  {
    #if sys
    var fo:sys.io.FileOutput = File.write(timeFile);
    var now:Float = Sys.time();
    fo.writeDouble(now);
    fo.close();
    #end
  }
}
