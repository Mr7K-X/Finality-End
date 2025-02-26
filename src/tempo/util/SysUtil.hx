package tempo.util;

class SysUtil
{
  #if desktop
  @:keep static function __alsoft__init__():Void
  {
    FileUtil.createFolderIfNotExist("./plugins/");

    if (!sys.FileSystem.exists('./plugins/alsoft.' + #if windows "ini" #else "conf" #end))
    {
      #if windows
      sys.io.File.saveContent("./plugins/alsoft.ini", Constants.ALSOFT_DATA);
      #elseif mac
      sys.io.File.saveContent("./plugins/alsoft.conf", Constants.ALSOFT_DATA);
      #else
      sys.io.File.saveContent("./plugins/alsoft.conf", Constants.ALSOFT_DATA);
      #end
    }

    final o:String = #if hl Sys.getCwd() #else Sys.programPath() #end;

    var c:String = haxe.io.Path.directory(haxe.io.Path.withoutExtension(o));
    #if windows
    c += "/plugins/alsoft.ini";
    #elseif mac
    c += haxe.io.Path.directory(c) + "/Resources/plugins/alsoft.conf";
    #else
    c += "/plugins/alsoft.conf";
    #end

    Sys.putEnv("ALSOFT_CONF", c);
  }
  #end
}
