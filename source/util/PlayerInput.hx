package util;

import openfl.events.KeyboardEvent;

class PlayerInput
{
	static var keyTracker:Map<Int, Bool> = [];
	static var safeFrames:Float = 0;
	static var keyToData:Map<Int, Int> = [];

	public static function init():Void
	{
		for (i in 0...Settings.data.keybinds['notes'].length)
		{
			keyToData.set(Settings.data.keybinds['notes'][i], i % 4);
			keyTracker.set(Settings.data.keybinds['notes'][i], false);
		}
		safeFrames = (10 / FlxG.drawFramerate) * 1000;
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onRelease);
	}

	@:noCompletion public static function onPress(event:KeyboardEvent):Void
	{
		if (Settings.data.keybinds['notes'].contains(event.keyCode))
			if (!keyTracker[event.keyCode])
			{
				keyTracker.set(event.keyCode, true);
				for (note in PlayState.instance.playerStrum.notes[keyToData[event.keyCode]].members)
				{
					if (!note.alive)
						continue;
					if (Math.abs(Conductor.time - note.time) <= (120 + safeFrames))
					{
						note.kill();
						PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].confirm(false);
						PlayState.instance.combo += 1;
						judge(Math.abs(Conductor.time - note.time));
						return;
					}
				}
				PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].press(false);
				if (!Settings.data.ghostTapping)
					PlayState.instance.miss();
			}
	}

	@:noCompletion public static function onRelease(event:KeyboardEvent):Void
	{
		if (Settings.data.keybinds['notes'].contains(event.keyCode))
		{
			keyTracker.set(event.keyCode, false);
			@:privateAccess
			PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].confirmAlphaTarget = PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].pressedAlphaTarget = 0;
		}
	}

	static inline function judge(time:Float):Void
	{
		var name:String;
		if (time < (25 + safeFrames))
		{
			PlayState.instance.score += 350;
			name = 'sick';
		}
		else if (time < (60 + safeFrames))
		{
			PlayState.instance.score += 200;
			name = 'good';
		}
		else if (time < (90 + safeFrames))
		{
			PlayState.instance.score += 100;
			name = 'bad';
		}
		else
		{
			PlayState.instance.score += 50;
			name = 'shit';
		}

		var rating = PlayState.instance.comboGroup['rating'].recycle(FlxSprite, () -> Util.createGraphicSprite(0, 0, Path.image(name)));
		rating.alpha = 1;
		rating.loadGraphic(Path.image(name));
		rating.updateHitbox();
		rating.screenCenter();
		rating.velocity.set(0, 0);
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		FlxTween.tween(rating, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> rating.kill(), startDelay: Conductor.beatLength * .001});

		if (PlayState.instance.combo >= 10)
		{
			var comboSpr = PlayState.instance.comboGroup['comboSpr'].recycle(FlxSprite, () -> Util.createGraphicSprite(0, 0, Path.image('combo')));
			comboSpr.alpha = 1;
			comboSpr.screenCenter();
			comboSpr.x += comboSpr.width * .5;
			comboSpr.y += comboSpr.height + 25;
			comboSpr.velocity.set(0, 0);
			comboSpr.acceleration.y = FlxG.random.int(200, 300);
			comboSpr.velocity.y -= FlxG.random.int(140, 160);
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			FlxTween.tween(comboSpr, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> comboSpr.kill(), startDelay: Conductor.beatLength * .001});
		}
	}
}
