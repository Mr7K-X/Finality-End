package tempo.net;

import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import openfl.net.FileFilter;
import openfl.net.FileReference;

@:access(openfl.net.FileReference)
class TempoFileReference extends FileReference
{
  public function browseFix(type:FileDialogType = OPEN, ?defaultName:String, ?title:Null<String> = null, ?typeFilter:Null<Array<FileFilter>> = null):Bool
  {
    __data = null;
    __path = null;

    #if desktop
    var filter = null;

    if (typeFilter != null)
    {
      var filters = [];

      for (i in 0...typeFilter.length)
        filters.push(StringTools.replace(StringTools.replace(typeFilter[i].extension, "*.", ""), ";", ","));

      filter = filters.join(";");
    }

    var fileDialog = new FileDialog();
    fileDialog.onCancel.add(openFileDialog_onCancel);
    fileDialog.onSelect.add(openFileDialog_onSelect);
    fileDialog.browse(type, filter, defaultName, title);
    return true;
    #end

    return false;
  }

  @:private var _trackSavedPath:String;

  override function saveFileDialog_onSelect(path:String):Void
  {
    _trackSavedPath = path;
    super.saveFileDialog_onSelect(path);
  }
}
