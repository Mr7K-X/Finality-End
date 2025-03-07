package tempo.net;

import openfl.net.FileFilter;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import lime.ui.FileDialogType;
import flixel.FlxBasic;

@:access(tempo.net.TempoFileReference)
@:access(openfl.net.FileReference)
class TempoFileHandler implements IFlxDestroyable
{
  /**
   * File Reference for all events
   */
  var _fileRef:Null<TempoFileReference> = null;

  /**
   * Type for File Reference (`OPEN`, `OPEN_MULTIPLE`, `SAVE`, `OPEN_DIREcTORY`)
   */
  var _dialogType:FileDialogType = OPEN;

  /**
   * Adding new Handler
   */
  public function new():Void
  {
    _fileRef = new TempoFileReference();
    _fileRef.addEventListener(Event.CANCEL, onCancelEvent);
    _fileRef.addEventListener(IOErrorEvent.IO_ERROR, onErrorEvent);
  }

  /**
   * Current operation file data
   */
  public var data:Null<String> = null;

  /**
   * Current operation file path
   */
  public var path:Null<String> = null;

  /**
   * Current operation completed?
   */
  public var completed:Bool = true;

  /**
   * Completed callback
   */
  public var onComplete:Null<Void->Void> = null;

  /**
   * Cancelled callback
   */
  public var onCancel:Null<Void->Void> = null;

  /**
   * Errored callback
   */
  public var onError:Null<Void->Void> = null;

  @:private var _currentEvent:Null<Event->Void> = null;

  /**
   * Saving a current file data in folder's
   * @param name File Name
   * @param data File Data
   * @param onComplete Completed Callback
   * @param onCancel Cancelled Callback
   * @param onError Errored Callback (ex: Sys.exit(1) LMAMAOOo)
   */
  public function save(?name:String = '', ?data:String = '', ?onComplete:Void->Void, ?onCancel:Void->Void, ?onError:Void->Void):Void
  {
    if (!completed) throw new haxe.Exception("Previous operation, not completed!");

    this._dialogType = SAVE;
    _startUp(onComplete, onCancel, onError);

    removePreviousEvents();
    _currentEvent = onSaveComplete;

    _fileRef.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _currentEvent);
    _fileRef.save(data, name);
  }

  public function load(?defaultName:String = null, ?title:String = null, ?filter:Array<FileFilter> = null, ?onComplete:Void->Void, ?onCancel:Void->Void,
      ?onError:Void->Void):Void
  {
    if (!completed) throw new haxe.Exception("Previous operation, not completed!");

    this._dialogType = OPEN;
    _startUp(onComplete, onCancel, onError);
    if (filter == null) filter = [new FileFilter('JSON', 'json')];

    removePreviousEvents();

    _currentEvent = onLoadComplete;
    _fileRef.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _currentEvent);
    _fileRef.browseFix(this._dialogType, defaultName, title, filter);
  }

  public function loadDirectory(?title:String = null, ?onComplete:Void->Void, ?onCancel:Void->Void, ?onError:Void->Void):Void
  {
    if (!completed) throw new haxe.Exception('Previous operation, not completed!');

    this._dialogType = OPEN_DIRECTORY;
    _startUp(onComplete, onCancel, onError);

    removePreviousEvents();

    _currentEvent = onLoadDirComplete;
    _fileRef.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _currentEvent);
    _fileRef.browseFix(this._dialogType, null, title);
  }

  function onSaveComplete(_):Void
  {
    this.path = _fileRef._trackSavedPath;
    this.completed = true;

    Sys.println('File Handler: File saved! ($path)');

    removePreviousEvents();
    this.completed = true;
    if (onComplete != null) onComplete();
  }

  function onCancelEvent(_):Void
  {
    removePreviousEvents();
    this.completed = true;
    if (onCancel != null) onCancel();
  }

  function onLoadComplete(_):Void
  {
    this.path = _fileRef.__path;
    this.data = #if sys sys.io.File.getContent(this.path) #else openfl.Assets.getText(this.path) #end;
    this.completed = true;

    Sys.println('File Handler: File loaded! ($path)');

    removePreviousEvents();
    this.completed = true;
    if (onComplete != null) onComplete();
  }

  function onLoadDirComplete(_):Void
  {
    this.path = _fileRef.__path;
    this.completed = true;

    Sys.println('File Handler: File loaded! ($path)');

    removePreviousEvents();
    this.completed = true;
    if (onComplete != null) onComplete();
  }

  function onErrorEvent(_):Void
  {
    removePreviousEvents();
    this.completed = true;
    if (onError != null) onError();
  }

  /**
   * Starting stuff functions
   * @param onComplete Completed callback
   * @param onCancel Cancelled callback
   * @param onError Errored callback
   */
  @:private function _startUp(onComplete:Void->Void, onCancel:Void->Void, onError:Void->Void):Void
  {
    this.onComplete = onComplete;
    this.onCancel = onCancel;
    this.onError = onError;
    this.completed = false;
    this.data = null;
    this.path = null;
  }

  @:private function removePreviousEvents():Void
  {
    if (_currentEvent == null)
    {
      trace('Current operation event is NULL! returning...');
      return;
    }

    _fileRef.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _currentEvent);
    _currentEvent = null;
  }

  public function destroy()
  {
    removePreviousEvents();

    _fileRef = null;
    _currentEvent = null;

    onComplete = null;
    onCancel = null;
    onError = null;

    data = null;
    path = null;

    completed = true;
  }
}
