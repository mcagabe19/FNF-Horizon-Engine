package horizon.objects;

import lime.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import sys.io.Process;
#if android
import android.os.Build;
#end

// Based on PsychEngine's FPSCounter.hx
class EngineInfo extends TextField
{
	public var curFPS:Int;
	public var curMemory:Float;

	@:noCompletion var deltaTimeout:Float = 0.0;
	@:noCompletion var times:Array<Float>;

	static var libText:String = '\n\nHorizon Engine Build ${Constants.horizonVer}\n';

	public function new()
	{
		super();

		// https://askubuntu.com/a/988612
		// if the mac/ios stuff doesn't work blame lily
		var cpuProc = new Process(#if windows 'wmic cpu get name' #elseif (linux || android) 'lscpu | grep \'Model name\' | cut -f 2 -d \":\" | awk \'{$1=$1}1\'' #elseif (mac || ios) 'sysctl -a | grep brand_string | awk -F ": " \'{print $2}\'' #end);

		// (lily spawns for adrod code)
		var cpu:String = #if android (AndroidVersion.SDK_INT >= AndroidVersionCode.S) ? Build.SOC_MODEL : Build.HARDWARE #else 'N/A' #end;

		if (cpuProc.exitCode() == 0)
		{
			var arr = cpuProc.stdout.readAll().toString().trim().split('\n');
			cpu = arr[arr.length - 1];
		}

		// Credit to CoreCat for the CPU, GPU, and OS data
		libText += 'OS:  ${System.platformLabel} ${System.platformVersion}\n';
		libText += 'CPU: $cpu\n';

		libText += 'GPU: ${@:privateAccess Std.string(FlxG.stage.context3D.gl.getParameter(FlxG.stage.context3D.gl.RENDERER)).split('/')[0].trim()}\n\n';

		libText += 'Haxe:          ${LibraryMacro.getLibVersion('haxe')}\n';
		libText += 'Flixel:        ${LibraryMacro.getLibVersion('flixel')}\n';
		libText += 'Flixel Addons: ${LibraryMacro.getLibVersion('flixel-addons')}\n';
		libText += 'OpenFL:        ${LibraryMacro.getLibVersion('openfl')}\n';
		libText += 'Lime:          ${LibraryMacro.getLibVersion('lime')}\n';
		libText += 'HaxeUI-Core:   ${LibraryMacro.getLibVersion('haxeui-core')}\n';
		libText += 'HaxeUI-Flixel: ${LibraryMacro.getLibVersion('haxeui-flixel')}\n';

		x = #if mobile FlxG.game.x + #end 5;
		y = #if mobile FlxG.game.y + #end 5;

		curFPS = FlxG.updateFramerate;
		selectable = mouseEnabled = false;
		defaultTextFormat = new TextFormat(Path.font('JetBrainsMonoNL-SemiBold'), 14, 0xFFFFFF);
		text = 'FPS: ';

		autoSize = LEFT;
		multiline = true;
		alpha = .75;

		times = [];
	}

	override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		if (deltaTimeout < 100)
		{
			deltaTimeout += deltaTime;
			return;
		}

		updateText();
		deltaTimeout = 0;
	}

	public dynamic function updateText():Void
	{
		curFPS = times.length < FlxG.drawFramerate ? times.length : FlxG.drawFramerate;
		curMemory = #if cpp cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE) #elseif hl hl.Gc.stats().currentMemory #else System.totalMemory #end;

		text = 'FPS: ${curFPS}\nMemory: ${Util.formatBytes(cast(curMemory, UInt))} ${Constants.debugDisplay ? libText : ''}';
	}

	#if mobile
	public inline function setScale(?scale:Float){
		if(scale == null)
			scale = Math.min(FlxG.stage.window.width / FlxG.width, FlxG.stage.window.height / FlxG.height);
		scaleX = scaleY = #if android (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
	}
	#end
}
