package horizon.backend;

import lime.app.Application;

class OSUtil
{
	#if windows
	public static function setDPIAware():Void
	{
		#if cpp
		if (!Windows.setDPIAware())
			Log.warn('Failed to set DPI Awareness');
		#else
		Log.warn('setDPIAware is not supported on this platform');
		#end
	}

	public static function toggleWindowDarkMode():Void
	{
		#if cpp
		if (!Windows.toggleWindowDarkMode(Application.current.window.title))
			Log.warn('Failed to toggle Dark Mode');
		#else
		Log.warn('setWindowDarkMode is not supported on this platform');
		#end
	}
	#end

	public static function getStorageDirectory():String
	{
		var path:String = '';
		#if android
		path = AndroidVersion.SDK_INT > AndroidVersionCode.R ? AndroidContext.getObbDir() : AndroidContext.getExternalFilesDir();
		path = haxe.io.Path.addTrailingSlash(path);
		#elseif ios
		path = lime.system.System.documentsDirectory;
		#elseif sys
		path = Sys.getCwd();
		#end

		return path;
	}

    #if android
	public static function requestPermsFromUser():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO']);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
		{
			if (AndroidVersion.SDK_INT >= AndroidVersionCode.S)
				AndroidSettings.requestSetting('REQUEST_MANAGE_MEDIA');
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}

		if ((AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU
			&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES'))
			|| (AndroidVersion.SDK_INT < AndroidVersionCode.TIRAMISU
				&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')))
			FlxG.stage.window.alert('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress OK to see what happens',
				'Notice!');

		try
		{
			if (!FileSystem.exists(OSUtil.getStorageDirectory()))
				FileSystem.createDirectory(OSUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			FlxG.stage.window.alert('Please create directory to\n' + OSUtil.getStorageDirectory() + '\nPress OK to close the game', 'Error!');
		    Sys.exit(1);
		}
	}
	#end
}

// Based on CDEV Engine's Windows.hx
#if cpp
#if windows
@:cppInclude('windows.h')
@:cppInclude('dwmapi.h')
@:buildXml('
<target id="haxe">
  <lib name="dwmapi.lib" />
</target>
')
#end
#end
@:publicFields
private class Windows
{
	@:functionCode('return SetProcessDPIAware();')
	static function setDPIAware():Bool
		return false;

	@:functionCode('
		int darkMode = 0;
		HWND window = FindWindowA(NULL, windowTitle.c_str());
		if (window == NULL)
			window = FindWindowExA(GetActiveWindow(), NULL, NULL, windowTitle.c_str());
		if (window != NULL)
		{
			if (DwmGetWindowAttribute(window, 19, &darkMode, sizeof(darkMode)) != S_OK)
				DwmGetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));

			darkMode ^= 1;
			
			if (DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode)) != S_OK)
				return DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode)) == S_OK;
			else return TRUE;
		}else return FALSE;
	')
	static function toggleWindowDarkMode(windowTitle:String):Bool
		return false;
}
