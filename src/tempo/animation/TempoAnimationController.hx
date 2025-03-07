package tempo.animation;

/**
 * Updated `FlxAnimationController`. `timeScale` improved
 */
class TempoAnimationController extends flixel.animation.FlxAnimationController
{
	/**
	 * Synced with `FlxG.animationTimeScale`.
	 */
	public var syncWithGlobalAnimTimeScale:Bool = true;

	/**
	 * Updating time scale, angle, animation and etc.
	 * @param MS or elapsed
	 */
	public override function update(MS:Float):Void
	{
		if (_curAnim != null)
			updatingTimeScale(MS);
		else if (_prerotated != null)
			updatingAngle();
	}

	/**
	 * Updating a time scale
	 * @param MS or elapsed
	 */
	function updatingTimeScale(MS:Float)
	{
		if (_curAnim == null)
			return;

		var newTimeScale = timeScale;
		if (syncWithGlobalAnimTimeScale)
			newTimeScale *= FlxG.animationTimeScale;

		_curAnim.update(MS * newTimeScale);
	}

	/**
	 * Updating a rotation
	 */
	function updatingAngle()
	{
		if (_prerotated == null)
			return;

		_prerotated.angle = _sprite.angle;
	}
}
