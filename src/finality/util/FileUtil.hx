package finality.util;

import haxe.io.Path;
import haxe.io.Bytes;

class FileUtil
{
  /**
   * Creating direction if current direction not exists in game folder
   * @param path current direction path
   */
  public static function createFolderIfNotExist(path:String):Void
  {
    #if sys
    if (sys.FileSystem.exists(path)) return;
    sys.FileSystem.createDirectory(path);
    #else
    if (openfl.Assets.exists(path)) return;
    var dir:openfl.filesystem.File = new openfl.filesystem.File(path);
    dir.createDirectory();
    #end

    return;
  }

  /**
   * Write byte file contents directly to a given path.
   * Only works on desktop.
   *
   * @param path The path to the file.
   * @param data The bytes to write.
   * @param mode Whether to Force, Skip, or Ask to overwrite an existing file.
   */
  public static function writeBytesToPath(path:String, data:Bytes, mode:FileWriteMode = Skip):Void
  {
    #if sys
    createFolderIfNotExist(Path.directory(path));
    switch (mode)
    {
      case Force:
        sys.io.File.saveBytes(path, data);
      case Skip:
        if (!doesFileExist(path))
        {
          sys.io.File.saveBytes(path, data);
        }
        else
        {
          // Do nothing.
          // throw 'File already exists: $path';
        }
      case Ask:
        if (doesFileExist(path))
        {
          // TODO: We don't have the technology to use native popups yet.
          throw 'File already exists: $path';
        }
        else
        {
          sys.io.File.saveBytes(path, data);
        }
    }
    #else
    throw 'Direct file writing by path not supported on this platform.';
    #end
  }

  public static function doesFileExist(path:String):Bool
  {
    #if sys
    return sys.FileSystem.exists(path);
    #else
    return false;
    #end
  }
}

enum FileWriteMode
{
  /**
   * Forcibly overwrite the file if it already exists.
   */
  Force;

  /**
   * Ask the user if they want to overwrite the file if it already exists.
   */
  Ask;

  /**
   * Skip the file if it already exists.
   */
  Skip;
}
