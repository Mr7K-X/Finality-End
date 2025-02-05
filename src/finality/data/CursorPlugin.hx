package finality.data;

import lime.graphics.Image;
import openfl.display.BitmapData;

//coded by mrzkX
class CursorPlugin
{
    public static final CURSORS_DATA:Array<CursorData> = [
        {mode: 0, texture: 'cursor', scale: 0.03, addX: 0, addY: 0}
    ];

    inline public static function init():Void
    {
        visible(false);

        cursorMode = ARROW;
    }

    public static var cursorMode(default, set):CursorMode = ARROW; 
    static function set_cursorMode(v:CursorMode):CursorMode
    {
        cursorMode = v;
        checkTexture(v);

        return cursorMode;
    }

    public static function visible(value:Bool):Void
    {
        FlxG.mouse.visible = value;
    }

    private static function checkTexture(mode:CursorMode):Void
    {
        for(i in 0...CURSORS_DATA.length)
        {
            if(CURSORS_DATA[i].mode == mode)
            {
                trace('Cursor Plugin: Selected ${CURSORS_DATA[i].texture} texture!');
                FlxG.mouse.load(BitmapData.fromImage(Image.fromFile(Paths.getPath('images/${CURSORS_DATA[i].texture}.png', IMAGE, null, true))), CURSORS_DATA[i].scale, CURSORS_DATA[i].addX, CURSORS_DATA[i].addY);
            }
        }
    }
}

typedef CursorData = {
    var mode:Int;
    var texture:String;
    var scale:Float;
    var addX:Int;
    var addY:Int;
}

enum abstract CursorMode(Int) from Int to Int
{
    var ARROW = 0;
    //var HOLD = 1;
    //var BUTTON = 2;
    //var TIMER = 3;
    //var CROSS = 4;
}