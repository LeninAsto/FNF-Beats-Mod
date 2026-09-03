package substates;

import backend.AssetLoader;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Difficulty;
import backend.Mods;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.filters.BlurFilter;
import options.OptionsState;
import states.FreeplayStateSelector;
import states.PlayState;
import states.StoryMenuState;

using StringTools;

class PauseSubState extends MusicBeatSubstate {
	var bg:FlxSprite;
	var base:FlxSprite;
	var arrow:FlxSprite;
	var buttons:FlxTypedGroup<FlxSprite>;
	var infoTexts:FlxTypedGroup<FlxText>;
	var chartText:FlxText;
	var pauseMusic:FlxSound;
	var items:Array<String> = ['reanudar', 'reiniciar', 'salir', 'chart'];
	var itemSprites:Array<FlxSprite> = [];
	var itemY:Array<Float> = [50, 340, 560, 670];
	var itemColor:Array<Int> = [0xffffe367, 0xffff6361, 0xff61ff80, 0xff000000];
	var itemBaseScale:Float = 0.68;
	var itemSelectedScale:Float = 0.82;
	var curSelected:Int = 0;
	var selected:Bool = false;

	override function create():Void {
		super.create();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		applyBlur();

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.scrollFactor.set();
		bg.alpha = 0;
		add(bg);
		FlxTween.tween(bg, {alpha: 0.35}, 0.25, {ease: FlxEase.quartOut});

		buttons = new FlxTypedGroup<FlxSprite>();
		add(buttons);
		infoTexts = new FlxTypedGroup<FlxText>();
		add(infoTexts);

		createPauseArt();
		createInfoText();
		playPauseMusic();
		changeSelection(0);
	}

	function createPauseArt():Void {
		base = animatedPauseSprite('PauseBase', 0, 0);
		base.x = -base.frameWidth;
		buttons.add(base);
		FlxTween.tween(base, {x: 0}, 0.5, {ease: FlxEase.expoOut});

		for (i in 0...3) {
			var sprite = animatedPauseSprite(items[i], 10, itemY[i]);
			sprite.scale.set(itemBaseScale, itemBaseScale);
			sprite.updateHitbox();
			sprite.x = -sprite.frameWidth;
			itemSprites.push(sprite);
			buttons.add(sprite);
			FlxTween.tween(sprite, {x: 10}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.03 * i});
		}

		arrow = animatedPauseSprite('flecha', 483, FlxG.height + 120);
		arrow.color = FlxColor.BLACK;
		buttons.add(arrow);
		FlxTween.tween(arrow, {x: 483, y: itemY[0]}, 0.55, {ease: FlxEase.expoOut});

		chartText = new FlxText(-260, 700, 0, 'Go to Chart Editor', 15);
		chartText.setFormat(Paths.font('vcr.ttf'), 15, FlxColor.BLACK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		chartText.scrollFactor.set();
		add(chartText);
		FlxTween.tween(chartText, {x: 50}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.12});
	}

	function animatedPauseSprite(anim:String, x:Float, y:Float):FlxSprite {
		var sprite = new FlxSprite(x, y);
		sprite.frames = Paths.getSparrowAtlas('Pause Stuff');
		sprite.animation.addByPrefix(anim, anim, 24, false);
		sprite.animation.play(anim);
		sprite.antialiasing = ClientPrefs.data.antialiasing;
		sprite.scrollFactor.set();
		return sprite;
	}

	function createInfoText():Void {
		var song:String = PlayState.SONG != null && PlayState.SONG.song != null ? PlayState.SONG.song : 'Unknown';
		var diff:String = Difficulty.getString().toUpperCase();
		var credits = getCredits();
		var lines:Array<String> = [
			'You were playing: ' + song,
			'Artist: ' + credits.artist,
			'Difficulty: ' + diff,
			'Deaths: ' + PlayState.deathCounter
		];

		var y:Float = -30;
		for (i in 0...lines.length) {
			var text = new FlxText(FlxG.width, y, 0, lines[i], 22);
			text.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.updateHitbox();
			text.x = FlxG.width;
			text.alpha = 0;
			infoTexts.add(text);
			FlxTween.tween(text, {alpha: 1, x: FlxG.width - text.width - 1, y: i * (text.height + 1.5)}, 0.35 + (0.1 * i), {ease: FlxEase.quartInOut});
		}
	}

	function getCredits():Dynamic {
		var result:Dynamic = {artist: 'hmmm', charter: 'hmmm?'};
		if (PlayState.SONG == null || PlayState.SONG.song == null)
			return result;

		var songPath = Paths.formatToSongPath(PlayState.SONG.song);
		var raw = AssetLoader.loadText(Paths.getSharedPath('data/' + songPath + '/creds.txt'));
		if (raw == null && Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			raw = AssetLoader.loadText(Paths.mods(Mods.currentModDirectory + '/data/' + songPath + '/creds.txt'));
		if (raw == null)
			return result;

		for (line in raw.split('\n')) {
			var trimmed = line.trim();
			if (trimmed.startsWith('artist='))
				result.artist = trimmed.substr('artist='.length).trim();
			else if (trimmed.startsWith('charter='))
				result.charter = trimmed.substr('charter='.length).trim();
		}
		return result;
	}

	function playPauseMusic():Void {
		var pauseSong = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if (pauseSong == null || pauseSong.length == 0 || pauseSong == 'none')
			pauseSong = 'breakfast';

		pauseMusic = new FlxSound();
		try {
			pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
			pauseMusic.volume = 0;
			pauseMusic.play(false, pauseMusic.length > 0 ? FlxG.random.int(0, Std.int(pauseMusic.length / 2)) : 0);
			FlxG.sound.list.add(pauseMusic);
			FlxTween.tween(pauseMusic, {volume: 0.05}, 1.2);
		} catch (e:Dynamic) {
			pauseMusic.destroy();
			pauseMusic = null;
		}
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (selected)
			return;

		if (controls.BACK) {
			choose('reanudar');
			return;
		}
		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);
		if (controls.ACCEPT)
			choose(items[curSelected]);
	}

	function changeSelection(change:Int):Void {
		curSelected = FlxMath.wrap(curSelected + change, 0, items.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);

		if (arrow != null) {
			arrow.animation.play('flecha', true, change < 0);
			FlxTween.cancelTweensOf(arrow);
			FlxTween.tween(arrow, {y: itemY[curSelected], color: itemColor[curSelected]}, 0.45, {ease: FlxEase.expoOut});
		}

		for (i in 0...itemSprites.length) {
			var scale = i == curSelected ? itemSelectedScale : itemBaseScale;
			tweenSpriteScale(itemSprites[i], scale);
		}
	}

	function tweenSpriteScale(sprite:FlxSprite, targetScale:Float):Void {
		if (sprite == null)
			return;

		FlxTween.cancelTweensOf(sprite.scale);
		FlxTween.num(sprite.scale.x, targetScale, 0.25, {ease: FlxEase.expoOut}, function(value:Float) {
			sprite.scale.set(value, value);
			sprite.updateHitbox();
		});
	}

	function choose(item:String):Void {
		selected = true;
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.5);
		closeVisuals();

		new FlxTimer().start(0.28, _ -> {
			switch (item) {
				case 'reanudar':
					close();
				case 'reiniciar':
					restartSong();
				case 'salir':
					exitSong();
				case 'chart':
					PlayState.instance.openChartEditor();
			}
		});
	}

	function closeVisuals():Void {
		clearBlur();
		if (pauseMusic != null)
			FlxTween.tween(pauseMusic, {volume: 0}, 0.25);

		for (sprite in buttons.members)
			if (sprite != null)
				FlxTween.tween(sprite, {x: -sprite.frameWidth}, 0.25, {ease: FlxEase.expoOut});
		for (text in infoTexts.members)
			if (text != null)
				FlxTween.tween(text, {x: FlxG.width, alpha: 0}, 0.25, {ease: FlxEase.expoOut});
		if (chartText != null)
			FlxTween.tween(chartText, {x: -chartText.width}, 0.25, {ease: FlxEase.expoOut});
	}

	function restartSong():Void {
		PlayState.instance.paused = true;
		if (FlxG.sound.music != null)
			FlxG.sound.music.volume = 0;
		if (PlayState.instance.vocals != null)
			PlayState.instance.vocals.volume = 0;
		MusicBeatState.resetState();
	}

	function exitSong():Void {
		PlayState.instance.paused = false;
		close();
		PlayState.instance.exitToFreeplayWithStickers();
	}

	function applyBlur():Void {
		if (PlayState.instance == null)
			return;
		PlayState.instance.camGame.setFilters([new BlurFilter()]);
		PlayState.instance.camHUD.setFilters([new BlurFilter()]);
		PlayState.instance.camOther.setFilters([new BlurFilter()]);
	}

	function clearBlur():Void {
		if (PlayState.instance == null)
			return;
		PlayState.instance.camGame.setFilters([]);
		PlayState.instance.camHUD.setFilters([]);
		PlayState.instance.camOther.setFilters([]);
	}

	override function close():Void {
		clearBlur();
		super.close();
	}

	override function destroy():Void {
		clearBlur();
		if (pauseMusic != null) {
			pauseMusic.destroy();
			pauseMusic = null;
		}
		super.destroy();
	}
}
