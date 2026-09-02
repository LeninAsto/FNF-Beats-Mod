package states;

import beats.BeatsMenuConfig;
import backend.ClientPrefs;
import backend.MusicBeatState;
import backend.Paths;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

typedef ThingInfo = {
	var escala:Float;
	var nombre:String;
	var path:String;
	var baseX:Float;
	var baseW:Float;
}

class StateLlenoDeCosas extends MusicBeatState {
	var lasCosas:FlxTypedGroup<FlxSprite>;
	var infoDelasCosas:Array<ThingInfo> = [];
	var espacioEntreWeas:Float = 20;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var idActual:Int = 0;
	var totalDeCosas:Int = 0;
	var xCentral:Float;
	var nameText:Alphabet;
	var miraWe:FlxObject;

	override function create():Void {
		super.create();

		miraWe = new FlxObject(0, 0, 1, 1);
		miraWe.screenCenter();
		add(miraWe);

		xCentral = FlxG.width / 2;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('storymode/bgstory'));
		bg.color = FlxColor.fromRGB(FlxG.random.int(100, 255), FlxG.random.int(100, 255), FlxG.random.int(100, 255));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(Paths.image('storymode/grid' + FlxG.random.int(1, 4)));
		grid.velocity.set(FlxG.random.float(-40, 40), FlxG.random.float(-40, 40));
		grid.scrollFactor.set();
		grid.alpha = 0.25;
		add(grid);

		lasCosas = new FlxTypedGroup<FlxSprite>();
		add(lasCosas);

		loadThings();
		createHeader();

		if (totalDeCosas > 0)
			cambio(0);
		else
			showEmptyMessage();

		FlxG.camera.follow(miraWe, null, 0.1);
	}

	function loadThings():Void {
		var things:Array<String> = BeatsMenuConfig.galleryItems();

		for (i in 0...things.length)
			hazCosas(things[i], i);

		totalDeCosas = lasCosas.length;
		var xActual:Float = xCentral;
		for (thing in lasCosas.members) {
			if (thing == null)
				continue;
			thing.x = xActual;
			infoDelasCosas[thing.ID].baseX = xActual;
			xActual += thing.width + espacioEntreWeas;
		}
	}

	function createHeader():Void {
		nameText = new Alphabet(0, 0, 'cosas', true);
		nameText.isMenuItem = false;
		nameText.x = (FlxG.width - nameText.width) / 2;
		nameText.setScale(0.5, 0.5);
		nameText.scrollFactor.set();
		add(nameText);

		leftArrow = makeArrow(true);
		rightArrow = makeArrow(false);
		nameText.y = leftArrow.y + leftArrow.height / 2;
	}

	function makeArrow(left:Bool):FlxSprite {
		var arrow:FlxSprite = new FlxSprite(0, 0);
		arrow.scrollFactor.set();
		arrow.antialiasing = ClientPrefs.data.antialiasing;
		arrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		arrow.animation.addByPrefix('idle', left ? 'arrow left' : 'arrow right');
		arrow.animation.addByPrefix('press', left ? 'arrow push left' : 'arrow push right', 24, false);
		arrow.animation.play('idle');
		arrow.x = (FlxG.width - arrow.width) / 2;
		arrow.x += left ? -188 : 188;
		arrow.y = arrow.height / 2;
		arrow.animation.finishCallback = function(name:String) {
			if (name == 'press')
				arrow.animation.play('idle', true);
		}
		add(arrow);
		return arrow;
	}

	function showEmptyMessage():Void {
		var msg:FlxText = new FlxText(0, 0, FlxG.width, 'No hay cosas configuradas', 24);
		msg.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, 'center');
		msg.screenCenter();
		msg.scrollFactor.set();
		add(msg);
	}

	function hazCosas(name:String, id:Int):FlxSprite {
		var escalaPromedio:Float = 500;
		var path:String = BeatsMenuConfig.galleryFolder + '/' + name;
		var laCosa:FlxSprite = new FlxSprite().loadGraphic(Paths.image(path));
		var biggerSide:Float = Math.max(laCosa.width, laCosa.height);
		if (biggerSide <= 0)
			biggerSide = escalaPromedio;
		var escalaParaUsar:Float = escalaPromedio / biggerSide;
		laCosa.scale.set(escalaParaUsar, escalaParaUsar);
		laCosa.updateHitbox();
		laCosa.antialiasing = ClientPrefs.data.antialiasing;
		laCosa.scrollFactor.y = 0;
		laCosa.ID = id;
		infoDelasCosas[id] = {escala: escalaParaUsar, nombre: name, path: path, baseX: 0, baseW: laCosa.width};
		laCosa.y = (FlxG.height - laCosa.height) / 2;
		lasCosas.add(laCosa);
		return laCosa;
	}

	override function update(elapsed:Float):Void {
		if (totalDeCosas > 0) {
			if (controls.UI_LEFT_P)
				cambio(-1);
			if (controls.UI_RIGHT_P)
				cambio(1);

			leftArrow.x = nameText.x - leftArrow.width;
			rightArrow.x = nameText.x + nameText.width;
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (!switchToState('MainMenuState'))
				MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function cambio(change:Int):Void {
		if (change == -1)
			leftArrow.animation.play('press', true);
		else if (change == 1)
			rightArrow.animation.play('press', true);

		idActual += change;
		if (idActual > totalDeCosas - 1)
			idActual = 0;
		if (idActual < 0)
			idActual = totalDeCosas - 1;

		var estaCosa:FlxSprite = lasCosas.members[idActual];
		miraWe.x = estaCosa.x + estaCosa.width / 2;
		nameText.text = infoDelasCosas[idActual].nombre;
		nameText.x = (FlxG.width - nameText.width) / 2;

		for (i in 0...totalDeCosas) {
			var baseScale:Float = infoDelasCosas[i].escala;
			var cosita:FlxSprite = lasCosas.members[i];
			if (cosita == null)
				continue;
			var scale:Float = (i == idActual) ? baseScale : baseScale - 0.2;
			if (scale < 0.05)
				scale = 0.05;
			var alpha:Float = (i == idActual) ? 1.0 : 0.6;
			FlxTween.tween(cosita, {alpha: alpha}, 0.5, {ease: FlxEase.quartOut});
			FlxTween.num(cosita.scale.x, scale, 0.5, {ease: FlxEase.quartOut}, function(value:Float) {
				cosita.scale.set(value, value);
				cosita.updateHitbox();
			});
		}
	}
}
