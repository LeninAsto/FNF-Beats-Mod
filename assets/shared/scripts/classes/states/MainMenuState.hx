package states;

import beats.BeatsMenuConfig;
import backend.ClientPrefs;
import backend.MusicBeatState;
import backend.Paths;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import options.OptionsState;
import states.FreeplayStateSelector;
import states.TitleState;

using StringTools;

class MainMenuState extends MusicBeatState {
	public static var curSelected:Int = 0;

	var allowMouse:Bool = true;
	var canInteract:Bool = false;
	var selectedSomethin:Bool = false;
	var timeNotMoving:Float = 0;

	var patHand:FlxSprite;
	var randomSprite:FlxSprite;
	var ogScale:Array<Float> = [1, 1];
	var chosen:String = '';
	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuOptions:Array<Dynamic>;
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create():Void {
		super.create();

		persistentUpdate = persistentDraw = true;
		menuOptions = BeatsMenuConfig.mainItems();

		var yScroll:Float = 0.25;
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image(BeatsMenuConfig.bg));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(yScroll, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image(BeatsMenuConfig.bgFlash));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(yScroll, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = BeatsMenuConfig.flashColor;
		add(magenta);

		var border:FlxSprite = new FlxSprite().loadGraphic(Paths.image(BeatsMenuConfig.border));
		border.antialiasing = ClientPrefs.data.antialiasing;
		border.scrollFactor.set();
		border.setGraphicSize(Std.int(FlxG.width));
		border.updateHitbox();
		border.screenCenter();
		add(border);

		createRandomArt();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...menuOptions.length) {
			var option:Dynamic = menuOptions[i];
			var item:FlxSprite = createMenuItem(option.name, option.x, option.y);
			if (!ClientPrefs.data.lowQuality) {
				FlxTween.tween(item, {x: option.x}, 1, {
					ease: FlxEase.backOut,
					startDelay: i / 2,
					onComplete: function(_:FlxTween) {
						if (i == menuOptions.length - 1) {
							canInteract = true;
							changeItem();
						}
					}
				});
			} else {
				item.x = option.x;
			}
		}

		if (ClientPrefs.data.lowQuality) {
			canInteract = true;
			changeItem();
		}

		var versionText:String = 'FNF BEATS V ' + BeatsMenuConfig.version + ' (Plus/Psych v1.3 | FNF ' + Application.current.meta.get('version') + ')';
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, versionText, 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	function createRandomArt():Void {
		var choices:Array<String> = BeatsMenuConfig.randomArt();
		if (choices.length < 1)
			return;

		chosen = choices[FlxG.random.int(0, choices.length - 1)];
		randomSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(BeatsMenuConfig.randomArtFolder + '/' + chosen));
		randomSprite.setGraphicSize(Std.int(randomSprite.width * 0.6));
		ogScale = [randomSprite.scale.x, randomSprite.scale.y];
		randomSprite.updateHitbox();
		randomSprite.screenCenter();
		var targetY:Float = randomSprite.y;
		randomSprite.y = FlxG.height;
		randomSprite.scrollFactor.set();
		add(randomSprite);

		if (!ClientPrefs.data.lowQuality)
			FlxTween.tween(randomSprite, {y: targetY}, 1, {ease: FlxEase.backOut, startDelay: 0.5});
		else
			randomSprite.y = targetY;

		if (chosen == 'gato') {
			Paths.sound('pat0');
			Paths.sound('pat1');
			patHand = new FlxSprite(0, 0).loadGraphic(Paths.image('patpat'), true, 112, 112);
			patHand.animation.add('wait', [0], 12, false);
			patHand.animation.add('pat', [0, 1, 2, 3, 4], 12, false);
			patHand.useFramePixels = true;
			patHand.scrollFactor.set();
			patHand.visible = false;
			add(patHand);
		}
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxSprite {
		var menuItem:FlxSprite = new FlxSprite(FlxG.width + x, y);
		menuItem.frames = Paths.getSparrowAtlas(BeatsMenuConfig.menuAtlasFolder + '/' + name);
		menuItem.animation.addByPrefix('idle', 'idle', 12, true);
		menuItem.animation.addByPrefix('basic', 'basic', 12, true);
		menuItem.animation.addByPrefix('selected', 'select', 12, true);
		menuItem.animation.play('idle');
		menuItem.updateHitbox();
		menuItem.antialiasing = ClientPrefs.data.antialiasing;
		menuItem.scrollFactor.set();
		menuItems.add(menuItem);
		return menuItem;
	}

	override function update(elapsed:Float):Void {
		updatePatHand();

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

		if (!selectedSomethin && canInteract) {
			if (controls.UI_UP_P)
				changeItem(-1);
			if (controls.UI_DOWN_P)
				changeItem(1);

			var acceptsMouse:Bool = updateMouseSelection(elapsed);

			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT || (FlxG.mouse.justPressed && acceptsMouse))
				acceptSelection();

		}

		super.update(elapsed);
	}

	function updatePatHand():Void {
		if (patHand == null || randomSprite == null)
			return;

		patHand.x = FlxG.mouse.getScreenPosition(FlxG.camera).x - patHand.frameWidth / 2;
		patHand.y = FlxG.mouse.getScreenPosition(FlxG.camera).y - patHand.frameHeight / 2;
		if (FlxG.mouse.overlaps(randomSprite)) {
			patHand.visible = true;
			if (FlxG.mouse.justPressed) {
				randomSprite.scale.x = ogScale[0] + 0.15;
				randomSprite.scale.y = ogScale[1] - 0.15;
				FlxTween.tween(randomSprite.scale, {x: ogScale[0], y: ogScale[1]}, 0.25);
				patHand.animation.play('pat', true);
				FlxG.sound.play(Paths.soundRandom('pat', 0, 1), 1);
			}
		} else {
			patHand.visible = false;
		}
	}

	function updateMouseSelection(elapsed:Float):Bool {
		var acceptsMouse:Bool = allowMouse;
		if (acceptsMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) {
			acceptsMouse = false;
			FlxG.mouse.visible = patHand == null || !patHand.visible;
			timeNotMoving = 0;

			var dist:Float = -1;
			var distItem:Int = -1;
			for (i in 0...menuOptions.length) {
				var item:FlxSprite = menuItems.members[i];
				if (item != null && FlxG.mouse.overlaps(item)) {
					var distance:Float = Math.sqrt(Math.pow(item.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(item.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
					if (dist < 0 || distance < dist) {
						dist = distance;
						distItem = i;
						acceptsMouse = true;
					}
				}
			}

			if (distItem != -1 && distItem != curSelected) {
				curSelected = distItem;
				changeItem();
			}
		} else {
			timeNotMoving += elapsed;
			if (timeNotMoving > 2)
				FlxG.mouse.visible = false;
		}
		return acceptsMouse;
	}

	function acceptSelection():Void {
		FlxG.sound.play(Paths.sound('confirmMenu'));
		selectedSomethin = true;
		FlxG.mouse.visible = false;

		if (ClientPrefs.data.flashing)
			FlxFlicker.flicker(magenta, 1.1, 0.15, false);

		var item:FlxSprite = menuItems.members[curSelected];
		var option:Dynamic = menuOptions[curSelected];
		item.animation.play('selected');

		new FlxTimer().start(1, function(_:FlxTimer) {
			goToTarget(option.target, item);
		});

		var delay:Int = 0;
		for (other in menuItems) {
			if (other == item)
				continue;
			if (!ClientPrefs.data.lowQuality) {
				FlxTween.cancelTweensOf(other);
				FlxTween.tween(other, {y: FlxG.height}, 0.4, {startDelay: delay * 0.1, ease: FlxEase.backIn});
			}
			FlxTween.tween(other, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
			delay++;
		}

		if (randomSprite != null) {
			if (!ClientPrefs.data.lowQuality) {
				FlxTween.cancelTweensOf(randomSprite);
				FlxTween.tween(randomSprite, {alpha: 0, angle: 360}, 0.4, {ease: FlxEase.quadOut});
				FlxTween.tween(randomSprite.scale, {x: 0, y: 0}, 0.4, {ease: FlxEase.expoOut});
			} else {
				FlxTween.tween(randomSprite, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
			}
		}
	}

	function goToTarget(target:String, item:FlxSprite):Void {
		switch (target) {
			case 'story':
				if (!switchToState('StoryMenuState'))
					MusicBeatState.switchState(new StoryMenuState());
			case 'freeplay':
				MusicBeatState.switchState(FreeplayStateSelector.create());
			case 'gallery':
				if (!switchToState('StateLlenoDeCosas'))
					selectedSomethin = false;
			case 'achievements':
				if (!switchToState('AchievementsMenuState'))
					MusicBeatState.switchState(new states.AchievementsMenuState());
			case 'credits':
				MusicBeatState.switchState(new CreditsState());
			case 'options':
				MusicBeatState.switchState(new OptionsState());
				OptionsState.onPlayState = false;
			default:
				trace('Menu Item ${target} does not have an action');
				selectedSomethin = false;
				item.visible = true;
		}
	}

	function changeItem(change:Int = 0):Void {
		curSelected = FlxMath.wrap(curSelected + change, 0, menuOptions.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'));

		for (item in menuItems) {
			if (item != null)
				item.animation.play('idle');
		}

		var selectedItem:FlxSprite = menuItems.members[curSelected];
		selectedItem.animation.play('basic');
		camFollow.setPosition(selectedItem.getGraphicMidpoint().x, selectedItem.getGraphicMidpoint().y);
	}
}
