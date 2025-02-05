package psych.backend;

import psych.backend.ClientPrefs;

class Rating
{
  public var name:String = '';
  public var image:String = '';
  public var hitWindow:Null<Int> = 0; // ms
  public var ratingMod:Float = 1;
  public var score:Int = 350;
  public var noteSplash:Bool = true;
  public var hits:Int = 0;
  public var health:Float = 1;

  public function new(name:String)
  {
    this.name = name;
    this.image = name;
    this.hitWindow = 0;

    var window:String = name + 'Window';
    try
    {
      this.hitWindow = Reflect.field(ClientPrefs.data, window);
    }
    catch (e)
      FlxG.log.error(e);
  }

  public static function loadDefault():Array<Rating>
  {
    var rating:Rating = new Rating('sick');
    rating.health = (Constants.HEALTH_SICK_BONUS * (ClientPrefs.data.ghostTapping ? FlxG.random.float(0.8, 0.92) : 1));

    var ratingsData:Array<Rating> = [rating]; // highest rating goes first

    var rating:Rating = new Rating('good');
    rating.ratingMod = 0.67;
    rating.health = (Constants.HEALTH_GOOD_BONUS * (ClientPrefs.data.ghostTapping ? FlxG.random.float(0.8, 0.92) : 1));
    rating.score = 200;
    rating.noteSplash = false;
    ratingsData.push(rating);

    var rating:Rating = new Rating('bad');
    rating.ratingMod = 0.34;
    rating.health = (Constants.HEALTH_BAD_BONUS + (ClientPrefs.data.ghostTapping ? FlxG.random.float(-0.06, -0.02) : 0));
    rating.score = 100;
    rating.noteSplash = false;
    ratingsData.push(rating);

    var rating:Rating = new Rating('shit');
    rating.ratingMod = 0;
    rating.health = (Constants.HEALTH_SHIT_BONUS * (ClientPrefs.data.ghostTapping ? FlxG.random.float(1.25, 1.75) : 1));
    rating.score = 50;
    rating.noteSplash = false;
    ratingsData.push(rating);
    return ratingsData;
  }
}
