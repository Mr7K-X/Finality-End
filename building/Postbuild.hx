package building; // i know

#if sys
import sys.FileSystem;
import sys.io.File;
#end

/**
 * A script which executes after the game is built.
 */
class Postbuild
{
  static inline final BUILD_TIME_FILE:String = '.time';

  static function main():Void
  {
    printBuildTime();
  }

  static function printBuildTime():Void
  {
    #if sys
    var end:Float = Sys.time();
    if (FileSystem.exists(BUILD_TIME_FILE))
    {
      var fi:sys.io.FileInput = File.read(BUILD_TIME_FILE);
      var start:Float = fi.readDouble();
      fi.close();

      sys.FileSystem.deleteFile(BUILD_TIME_FILE);

      var buildTime:Float = roundToTwoDecimals(end - start);
      var symbol:String = '';

      final timeText:String = 'BUILD TOOK: ${buildTime} SECONDS';

      for (l in 0...timeText.length)
        symbol += '=';

      Sys.println('\n$symbol\n$timeText\n$symbol\n');
    }
    #end
  }

  static function roundToTwoDecimals(value:Float):Float
  {
    return Math.round(value * 100) / 100;
  }
}
