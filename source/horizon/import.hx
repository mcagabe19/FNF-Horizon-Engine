#if !macro
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import horizon.backend.*;
import horizon.backend.Conductor;
import horizon.macros.*;
import horizon.modding.Chart;
import horizon.modding.Mod;
import horizon.modding.Mods;
import horizon.modding.Song;
import horizon.modding.Week;
import horizon.objects.*;
import horizon.objects.game.*;
import horizon.states.*;
import horizon.util.*;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

#if android
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.content.Context as AndroidContext;
import android.os.BatteryManager as AndroidBatteryManager;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.Environment as AndroidEnvironment;
import android.widget.Toast as AndroidToast;
#end

using Lambda;
#end
using StringTools;
