package objects.game;

import flixel.util.FlxSignal;

@:publicFields
class Countdown extends FlxBasic
{
	static var countdownNameArr = ['ready', 'set', 'go'];
	static var countdownSoundArr = ['Three', 'Two', 'One', 'Go'];

	static var countdownEnded:FlxSignal = new FlxSignal();

	function new()
	{
		super();
		Conductor.beatSignal.add(countdown);
		@:privateAccess Conductor.time = Conductor.beatTracker = -Conductor.beatLength * 3;
		Conductor.curBeat = -4;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		Conductor.time += elapsed * 1000;
	}

	function countdown():Void
	{
		if (Conductor.curBeat < 1)
		{
			if (Conductor.curBeat > -3)
			{
				var countdownItem = Create.sprite(0, 0, Path.image(countdownNameArr[Conductor.curBeat + 2]));
				countdownItem.screenCenter();
				PlayState.instance.add(countdownItem);
				FlxTween.tween(countdownItem.scale, {x: 1.4, y: 1.4}, Conductor.beatLength * .001,
					{type: ONESHOT, ease: FlxEase.expoOut, onComplete: tween -> countdownItem.destroy()});
				FlxTween.tween(countdownItem, {alpha: 0}, Conductor.beatLength * .001, {type: ONESHOT, ease: FlxEase.expoOut});
			}

			FlxG.sound.play(Path.audio(countdownSoundArr[Conductor.curBeat + 3]));
		}

		if (Conductor.curBeat > 0)
		{
			@:privateAccess Conductor.time = Conductor.beatTracker = Conductor.curBeat = 0;
			Conductor.beatSignal.remove(countdown);
			countdownEnded.dispatch();

			for (val in PlayState.instance.audios)
				val.play(true);

			Conductor.song = PlayState.instance.audios['Inst'];
			Conductor.song.onComplete = () -> if (PlayState.songs.length > 0)
			{
				var song = PlayState.songs.shift();
				if (PlayState.songs.length == 0)
				{
					Conductor.reset();
					Conductor.bpm = @:privateAccess TitleState.titleData.bpm;
					Conductor.song = FlxG.sound.music;
					FlxG.sound.music.resume();
					FlxG.sound.music.fadeIn(.75);
					// TODO replace with StoryMenuState and FreeplayState
					MusicState.switchState(new MainMenuState());
				}
				else
					MusicState.switchState(new PlayState(), true, true);
			}

			destroy();
		}
	}
}
