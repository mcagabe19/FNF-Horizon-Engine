package horizon.backend;

import flixel.util.FlxSort;

class PlayerInput
{
	public static var safeMS:Float;
	static var idTracker:Int = 0;
	static var inputEnabled:Bool = false;

	public static function init():Void
	{
		safeMS = (Settings.safeFrames / 60) * 250;
		Countdown.countdownEnded.addOnce(() -> inputEnabled = true);

		for (i => bind in Constants.notebindNames)
		{
			Controls.onPress(Settings.keybinds[bind], onPress.bind(i));
			Controls.onRelease(Settings.keybinds[bind], PlayState.instance.playerStrum.strums[i].resetAnim);
		}
	}

	static function onPress(id:Int):Void
	{
		var strum = PlayState.instance.playerStrum.strums[id];
		if (inputEnabled)
		{
			for (note in PlayState.instance.playerStrum.notes.members)
			{
				if (note != null && note.exists && note.alive && note.data % Constants.notebindNames.length == id && note.hittable)
				{
					var diff = Math.abs(Conductor.time - note.time);
					if (diff <= Settings.hitWindows[3] + safeMS)
					{
						if (PlayState.instance.audios.exists('voices'))
							PlayState.instance.audios['voices'].volume = 1;
						else if (PlayState.instance.audios.exists('voices-player'))
							PlayState.instance.audios['voices-player'].volume = 1;
						note.hit();
						judge(diff, strum);
						return;
					}
				}
			}
		}
		strum.press();
		if (!Settings.ghostTapping)
			PlayState.instance.miss();
	}

	static function judge(diff:Float, strum:StrumNote):Void
	{
		PlayState.instance.combo++;
		// PBOT1 scoring
		var ratingName:String = switch (diff)
		{
			case(_ <= Settings.hitWindows[0] + safeMS) => true:
				PlayState.instance.spawnSplash(strum);
				'sick';
			case(_ <= Settings.hitWindows[1] + safeMS) => true:
				'good';
			case(_ <= Settings.hitWindows[2] + safeMS) => true:
				'bad';
			case(_ <= Settings.hitWindows[3] + safeMS) => true:
				'shit';
			default:
				'invalid';
		}

		PlayState.instance.score += Std.int(500 * (1.0 - (1.0 / (1.0 + Math.exp(-0.080 * (diff - 54.99))))) + 9);

		var rating = PlayState.instance.comboGroups[0].recycle(FlxSprite, () ->
		{
			var spr = Create.sprite(0, 0, Path.image('sick', PlayState.mods), [PlayState.instance.camHUD], .7);
			spr.moves = true;
			return spr;
		});
		rating.alpha = 1;
		rating.loadGraphic(Path.image(ratingName, PlayState.mods));
		rating.updateHitbox();
		rating.screenCenter();
		rating.zIndex = idTracker;
		rating.offset.x = 35 - Settings.comboOffsets[0];
		rating.offset.y = 25 - Settings.comboOffsets[1];
		rating.velocity.x = -FlxG.random.int(0, 10);
		rating.velocity.y = -FlxG.random.int(140, 175);
		rating.acceleration.y = 550;
		FlxTween.tween(rating, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> rating.kill(), startDelay: Conductor.beatLength * .001});

		var numArr = Std.string(PlayState.instance.combo).lpad('0', 3).split('');
		numArr.reverse();
		for (i => num in numArr)
		{
			var comboNum = PlayState.instance.comboGroups[1].recycle(FlxSprite, () ->
			{
				var spr = Create.atlas(0, 0, Path.atlas('num', PlayState.mods), [PlayState.instance.camHUD], .55);
				for (i in 0...10)
					spr.animation.addByNames('num$i', ['num$i']);
				spr.moves = true;
				return spr;
			});
			comboNum.alpha = 1;
			comboNum.animation.play('num$num');
			comboNum.updateHitbox();
			comboNum.screenCenter();
			comboNum.zIndex = idTracker;
			comboNum.offset.x = (comboNum.width + 5) * i + 50 - Settings.comboOffsets[0];
			comboNum.offset.y = -(comboNum.height + 25) - Settings.comboOffsets[1];
			comboNum.velocity.x = FlxG.random.float(-5, 5);
			comboNum.velocity.y = -FlxG.random.int(140, 160);
			comboNum.acceleration.y = FlxG.random.int(200, 300);
			FlxTween.tween(comboNum, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> comboNum.kill(), startDelay: Conductor.beatLength * .001});
		}

		if (PlayState.instance.combo >= 10)
		{
			var comboSpr = PlayState.instance.comboGroups[0].recycle(FlxSprite, () ->
			{
				var spr = Create.sprite(0, 0, Path.image('combo', PlayState.mods), [PlayState.instance.camHUD], .7);
				spr.moves = true;
				return spr;
			});
			comboSpr.alpha = 1;
			comboSpr.loadGraphic(Path.image('combo', PlayState.mods));
			comboSpr.updateHitbox();
			comboSpr.screenCenter();
			comboSpr.zIndex = idTracker;
			comboSpr.offset.x = -comboSpr.width * .35 - Settings.comboOffsets[0];
			comboSpr.offset.y = -comboSpr.height - Settings.comboOffsets[1];
			comboSpr.velocity.x = FlxG.random.int(1, 10);
			comboSpr.velocity.y = -FlxG.random.int(140, 160);
			comboSpr.acceleration.y = FlxG.random.int(200, 300);
			FlxTween.tween(comboSpr, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> comboSpr.kill(), startDelay: Conductor.beatLength * .001});
		}

		PlayState.instance.comboGroups[0].sort((Order, Obj1, Obj2) -> FlxSort.byValues(Order, Obj1.zIndex, Obj2.zIndex));
		PlayState.instance.comboGroups[1].sort((Order, Obj1, Obj2) -> FlxSort.byValues(Order, Obj1.zIndex, Obj2.zIndex));
		idTracker++;
		idTracker %= 1000000;
	}
}
