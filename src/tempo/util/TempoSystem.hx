package tempo.util;

import cpp.Process;

class TempoSystem
{
  static var _os(default, null):String = null;

  public static function get_OS_info():String
  {
    if (_os != null) return _os;

    #if (linux && cpp)
    var _name = "";
    var _version = "";

    for (_l in runProcess("cat /etc/os-release").split("\n"))
    {
      if (_l.startsWith("PRETTY_NAME="))
      {
        final index = _l.indexOf('"');
        if (index != -1) _name = _l.substring(index + 1, _l.lastIndexOf('"'));
        else
        {
          final arr = _l.split("=");
          arr.shift();
          _name = arr.join("=");
        }
      }

      if (_l.startsWith("VERSION="))
      {
        final index = _l.indexOf('"');
        if (index != -1) _version = _l.substring(index + 1, _l.lastIndexOf('"'));
        else
        {
          final arr = _l.split("=");
          arr.shift();
          _version = arr.join("=");
        }
      }
    }
    if (_name.length > 0) _os = '${_name} ${_version}'.trim();
    #else
    final _l:String = lime.system.System.platformLabel;
    final _v:String = lime.system.System.platformVersion;
    final _n:Bool = (_l != null && _l.length > 0 && _v != null && _v.length > 0);

    if (_n) _os = '${_l.replace(_v, "").trim()} ${_v}';
    else
      trace('Could not get a OS info, because label is NULL!');
    #end

    return _os;
  }

  public static function runProcess(cmd:String):String
  {
    var r:String = 'Unknown';
    #if cpp
    try
    {
      final pr = new Process(cmd);
      if (pr.exitCode() == 0) r = pr.stdout.readAll().toString().trim();

      pr.close();
    }
    catch (e)
      trace('Invalid "$cmd" (${e.message})');
    #end
    return r;
  }

  public inline static function getUsername()
  {
    #if sys
    var envs = Sys.environment();
    if (envs.exists("USERNAME")) return envs["USERNAME"];
    if (envs.exists("USER")) return envs["USER"];
    #end
    return 'Could not finded a USERNAME, this platform not supported!';
  }
}
