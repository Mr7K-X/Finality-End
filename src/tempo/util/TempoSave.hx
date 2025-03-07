package tempo.util;

import flixel.util.FlxDestroyUtil;
import openfl.net.SharedObjectFlushStatus;
import openfl.errors.Error;
import openfl.net.SharedObject;

/**
 * Rewrited `FlxSave` with cool changes.
 *
 * @author [Mrzk(X)](https://github.com/Mr7K-X)
 */
@:allow(tempo.util.TempoSharedObject)
class TempoSave implements IFlxDestroyable
{
	static var invalidChars = ~/[ ~%&\\;:"',<>?#]+/g;

	/**
	 * Checks for `~%&\;:"',<>?#` or space characters
	 */
	static function hasInvalidChars(str:String)
	{
		#if html5
		// most chars are fine on browsers
		return true;
		#else
		return invalidChars.match(str);
		#end
	}

	/**
	 * Converts invalid characters to "-", producing a valid string for a FlxSave's name and path
	 */
	@:allow(flixel.FlxG.initSave)
	static function validate(str:String)
	{
		#if html5
		// most chars are fine on browsers
		return str;
		#else
		return invalidChars.split(str).join("-");
		#end
	}

	/**
	 * Converts invalid characters to "-", and logs a warning in debug mode
	 */
	static function validateAndWarn(str, fieldId:String)
	{
		var newStr = validate(str);
		#if debug
		if (newStr != str)
			FlxG.log.warn('TempoSave $fieldId: "$str" contains invalid characters, using "$newStr" instead');
		#end
		return newStr;
	}

	/**
	 * Allows you to directly access the data container in the local shared object.
	 */
	public var data(default, null):Dynamic;

	/**
	 * The name of the local shared object.
	 */
	public var name(get, never):String;

	/**
	 * The path of the local shared object.
	 * @since 4.6.0
	 */
	public var path(get, never):String;

	/**
	 * The current status of the save.
	 * @since 5.0.0
	 */
	public var status(default, null):TempoSaveStatus = EMPTY;

	/**
	 * Wether the save was successfully bound.
	 * @since 5.0.0
	 */
	public var isBound(get, never):Bool;

	/**
	 * The local shared object itself.
	 */
	var _sharedObject:SharedObject;

	// new dynamic
	public function new() {}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_sharedObject = null;
		status = EMPTY;
		data = null;
	}

	/**
	 * Automatically creates or reconnects to locally saved data.
	 *
	 * @param   name  The name of the save (should be the same each time to access old data).
	 *                May not contain spaces or any of the following characters:
	 *                `~ % & \ ; : " ' , < > ? #`
	 * @param   path  The full or partial path to the file that created the shared object.
	 *                Mainly used to differentiate from other TempoSaves. If you do not specify
	 *                this parameter, the company name specified in your Project.xml is used.
	 * @return  Whether or not you successfully connected to the save data.
	 */
	public function bind(name:String, ?path:String):Bool
	{
		destroy();

		name = validateAndWarn(name, "name");
		if (path != null)
			path = validateAndWarn(path, "path");

		try
		{
			_sharedObject = TempoSharedObject.getLocal(name, path);
			status = BOUND(name, path);
		}
		catch (e:Error)
		{
			FlxG.log.error('Error:${e.message} name:"$name", path:"$path".');
			destroy();
			return false;
		}
		data = _sharedObject.data;
		return true;
	}

	/**
	 * Creates a new TempoSave and copies the data from old to new,
	 * flushes the new save (if changed) and then optionally erases the old save.
	 *
	 * @param   name         The name of the save.
	 * @param   path         The full or partial path to the file that created the save.
	 * @param   overwrite    Whether the data should overwrite, should the 2 saves share data fields. defaults to false.
	 * @param   eraseSave    Whether to erase the save after successfully migrating the data. defaults to true.
	 * @param   minFileSize  If you need X amount of space for your save, specify it here.
	 * @return  Whether or not you successfully found, merged and flushed data.
	 */
	public function mergeDataFrom(name:String, ?path:String, overwrite = false, eraseSave = true, minFileSize = 0):Bool
	{
		if (!checkStatus())
			return false;

		final oldSave = new TempoSave();
		// check old save location
		if (oldSave.bind(name, path))
		{
			final success = mergeData(oldSave.data, overwrite, minFileSize);

			if (eraseSave)
				oldSave.erase();
			oldSave.destroy();

			// save changes, if there are any
			return success;
		}

		oldSave.destroy();

		return false;
	}

	/**
	 * Copies the given data over to this save and flushes (if changed).
	 *
	 * @param   sourceData   The data to merge
	 * @param   overwrite    Whether the data should overwrite, should the 2 saves share data fields. defaults to false.
	 * @param   minFileSize  If you need X amount of space for your save, specify it here.
	 * @return  Whether or not you successfully saved the data.
	 */
	public function mergeData(sourceData:Dynamic, overwrite = false, minFileSize = 0)
	{
		var hasAnyField = false;
		for (field in Reflect.fields(sourceData))
		{
			hasAnyField = true;
			// Don't overwrite any existing data in the new save
			if (overwrite || !Reflect.hasField(data, field))
				Reflect.setField(data, field, Reflect.field(sourceData, field));
		}

		// save changes, if there are any
		if (hasAnyField)
			return flush(minFileSize);

		return true;
	}

	/**
	 * A way to safely call flush() and destroy() on your save file.
	 * Will correctly handle storage size popups and all that good stuff.
	 * If you don't want to save your changes first, just call destroy() instead.
	 *
	 * @param   minFileSize  If you need X amount of space for your save, specify it here.
	 * @return  The result of result of the flush() call (see below for more details).
	 */
	public function close(minFileSize:Int = 0):Bool
	{
		var success = flush(minFileSize);
		destroy();
		return success;
	}

	/**
	 * Writes the local shared object to disk immediately. Leaves the object open in memory.
	 *
	 * @param   minFileSize  If you need X amount of space for your save, specify it here.
	 * @return  Whether or not the data was written immediately. False could be an error OR a storage request popup.
	 */
	public function flush(minFileSize:Int = 0):Bool
	{
		if (!checkStatus())
			return false;

		try
			if (_sharedObject.flush(minFileSize) != FLUSHED)
				status = ERROR("TempoSave is requesting extra storage space.")
		catch (e:Error)
			status = ERROR("There was an problem flushing the save data.");

		checkStatus();

		return isBound;
	}

	/**
	 * Erases everything stored in the local shared object.
	 * Data is immediately erased and the object is saved that way,
	 * so use with caution!
	 *
	 * @return	Returns false if the save object is not bound yet.
	 */
	public function erase():Bool
	{
		if (!checkStatus())
			return false;
		_sharedObject.clear();
		data = {};
		return true;
	}

	/**
	 * Handy utility function for checking and warning if the shared object is bound yet or not.
	 *
	 * @return	Whether the shared object was bound yet.
	 */
	function checkStatus():Bool
	{
		switch (status)
		{
			case EMPTY:
				FlxG.log.warn("You must call TempoSave.bind() before you can read or write data.");
			case ERROR(msg):
				FlxG.log.error(msg);
			default:
				return true;
		}
		return false;
	}

	function get_name()
	{
		return switch (status)
		{
			// can't use the pattern var `name` or it will break in 4.0.5
			case BOUND(n, _): n;
			default: null;
		}
	}

	function get_path()
	{
		return switch (status)
		{
			// can't use the pattern var `path` or it will break in 4.0.5
			case BOUND(_, p): p;
			default: null;
		}
	}

	inline function get_isBound()
	{
		return status.match(BOUND(_, _));
	}

	/**
	 * Scans the data for any properties.
	 * @since 5.0.0
	 */
	public function isEmpty()
	{
		return data == null || Reflect.fields(data).length == 0;
	}
}

@:access(openfl.net.SharedObject)
@:access(tempo.util.TempoSave)
private class TempoSharedObject extends SharedObject
{
	static var all:Map<String, TempoSharedObject>;

	static function init()
	{
		if (all == null)
		{
			all = new Map();

			var app = openfl.Lib.current.stage.application;
			if (app != null)
				app.onExit.add(onExit);
		}
	}

	static function onExit(_)
	{
		for (sharedObject in all)
			sharedObject.flush();
	}

	/**
	 * Returns the company name listed in the Project.hxp
	 */
	static function getDefaultLocalPath()
	{
		var meta = openfl.Lib.current.stage.application.meta;
		var path = meta["company"];
		if (path == null || path == "")
			path = "MrzkTeam";
		else
			path = TempoSave.validate(path);

		return path;
	}

	public static function getLocal(name:String, ?localPath:String):SharedObject
	{
		#if (flash || android || ios)
		return SharedObject.getLocal(name, localPath);
		#else
		if (name == null || name == "")
			throw new Error('Error: Invalid name:"$name".');

		if (localPath == null)
			localPath = "";

		var id = localPath + "/" + name;

		init();

		if (!all.exists(id))
		{
			var encodedData = null;

			try
			{
				if (~/(?:^|\/)\.\.\//.match(localPath))
					throw new Error("../ not allowed in localPath");

				encodedData = getData(name, localPath);
			}
			catch (e:Dynamic) {}

			if (localPath == "")
				localPath = getDefaultLocalPath();

			final sharedObject = new TempoSharedObject();
			sharedObject.data = {};
			sharedObject.__localPath = localPath;
			sharedObject.__name = name;

			if (encodedData != null && encodedData != "")
			{
				try
				{
					final unserializer = new haxe.Unserializer(encodedData);
					final resolver = {resolveEnum: Type.resolveEnum, resolveClass: SharedObject.__resolveClass};
					unserializer.setResolver(cast resolver);
					sharedObject.data = unserializer.unserialize();
				}
				catch (e:Dynamic) {}
			}

			all.set(id, sharedObject);
		}

		return all.get(id);
		#end
	}

	static function getData(name:String, ?localPath:String)
	{
		#if (js && html5)
		final storage = js.Browser.getLocalStorage();
		if (storage == null)
			return null;

		var get:String->String = (path:String) -> return (storage.getItem('$path:$name'));

		// do not check for legacy saves when path is provided
		if (localPath != "")
			return get(localPath);

		var encodedData:String;
		// check default localPath
		encodedData = get(getDefaultLocalPath());
		if (encodedData != null)
			return encodedData;

		// check pre-5.0.0 default local path
		encodedData = get(js.Browser.window.location.pathname);
		if (encodedData != null)
			return encodedData;

		// check pre-4.6.0 default local path
		return get(js.Browser.window.location.href);
		#else
		var path = getPath(localPath, name);
		if (sys.FileSystem.exists(path))
			return sys.io.File.getContent(path);

		// No save found, check the legacy save path
		path = getLegacyPath(localPath, name);
		if (sys.FileSystem.exists(path))
			return sys.io.File.getContent(path);

		return null;
		#end
	}

	public static function exists(name:String, ?localPath:String)
	{
		#if (js && html5)
		final storage = js.Browser.getLocalStorage();

		if (storage == null)
			return false;

		inline function has(path:String)
		{
			return storage.getItem(path + ":" + name) != null;
		}

		return has(localPath)
			|| has(getDefaultLocalPath())
			|| has(js.Browser.window.location.pathname)
			|| has(js.Browser.window.location.href);
		#elseif (flash || android || ios)
		return true;
		#else
		return newExists(localPath, name) || legacyExists(localPath, name);
		#end
	}

	// should include every sys target
	#if (!js && !html5)
	static function getPath(localPath:String, name:String):String
	{
		// Avoid ever putting .save files directly in Documents
		if (localPath == "")
			localPath = getDefaultLocalPath();

		final directory = '${lime.system.System.userDirectory}/AppData/Local';
		final path = haxe.io.Path.normalize('$directory/$localPath') + "/";

		name = StringTools.replace(name, "//", "/");
		name = StringTools.replace(name, "//", "/");

		if (StringTools.startsWith(name, "/"))
		{
			name = name.substr(1);
		}

		if (StringTools.endsWith(name, "/"))
		{
			name = name.substring(0, name.length - 1);
		}

		if (name.indexOf("/") > -1)
		{
			var split = name.split("/");
			name = "";

			for (i in 0...(split.length - 1))
			{
				name += "#" + split[i] + "/";
			}

			name += split[split.length - 1];
		}

		return path + name + ".save";
	}

	/**
	 * Whether the save exists, checks the NEW location
	 */
	static inline function newExists(name:String, ?localPath:String)
	{
		return sys.FileSystem.exists(getPath(localPath, name));
	}

	static inline function getLegacyPath(localPath:String, name:String)
	{
		return SharedObject.__getPath(localPath, name);
	}

	/**
	 * Whether the save exists, checks the LEGACY location
	 */
	static inline function legacyExists(name:String, ?localPath:String)
	{
		return sys.FileSystem.exists(getLegacyPath(localPath, name));
	}

	override function flush(minDiskSpace:Int = 0)
	{
		if (Reflect.fields(data).length == 0)
		{
			return SharedObjectFlushStatus.FLUSHED;
		}

		var encodedData = haxe.Serializer.run(data);

		try
		{
			var path = getPath(__localPath, __name);
			var directory = haxe.io.Path.directory(path);

			if (!sys.FileSystem.exists(directory))
				SharedObject.__mkdir(directory);

			var output = sys.io.File.write(path, false);
			output.writeString(encodedData);
			output.close();
		}
		catch (e:Dynamic)
		{
			return SharedObjectFlushStatus.PENDING;
		}

		return SharedObjectFlushStatus.FLUSHED;
	}

	override function clear()
	{
		data = {};

		try
		{
			var path = getPath(__localPath, __name);

			if (sys.FileSystem.exists(path))
				sys.FileSystem.deleteFile(path);
		}
		catch (e:Dynamic) {}
	}
	#end
}

enum TempoSaveStatus
{
	/**
	 * The initial state, call bind() in order to use.
	 */
	EMPTY;

	/**
	 * The save is set up correctly.
	 */
	BOUND(name:String, ?path:String);

	/**
	 * There was an issue.
	 */
	ERROR(msg:String);
}
