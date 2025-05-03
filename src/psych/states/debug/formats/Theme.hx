package psych.states.debug.formats;

enum abstract ChartingTheme(String) from String to String
{
  var LIGHT = 'light';
  var DARK = 'dark';
  var DEFAULT = 'default';
  var VSLICE = "vslice";
  var CUSTOM = 'custom';
}

enum abstract CharacterTheme(String) from String to String
{
  var LIGHT = 'light';
  var DARK = 'dark';
  var DEFAULT = 'default';
  var TEMPO = 'tempo';
}
