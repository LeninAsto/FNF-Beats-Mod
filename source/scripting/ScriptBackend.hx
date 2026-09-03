package scripting;

#if HSCRIPT_ALLOWED
class ScriptBackend {
	public static var initialized(default, null):Bool = false;

	public static function setup():Void {
		if (initialized)
			return;

		initialized = true;
		scripting.hscript.HScript.setupConfig();

	}
}
#end
