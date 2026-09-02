package states;

import backend.ClientPrefs;
import backend.Conductor;
import backend.Difficulty;
import backend.Highscore;
import backend.Language;
import backend.Mods;
import backend.MusicBeatState;
import backend.Paths;
import backend.Song;
import backend.StageData;
import backend.WeekData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.Character;
import objects.MenuItem;
import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;

class StoryMenuState extends MusicBeatState {
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var fondo:FlxSprite;
	var muro:FlxSprite;
	var scoreText:FlxText;
	var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;
	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpLocks:FlxTypedGroup<FlxSprite>;
	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var loadedWeeks:Array<WeekData> = [];
	var storyChar:Character = null;
	var storyCharPos:Array<Float> = [185, 150];
	var weekTargetXs:Array<Float> = [];

	static var lastDifficultyName:String = '';
	static var curWeek:Int = 0;

	var curDifficulty:Int = 1;
	var lerpScore:Int = 49324858;
	var intendedScore:Int = 0;
	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	override function create():Void {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();

		persistentUpdate = persistentDraw = true;
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);

		if (WeekData.weeksList.length < 1) {
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new ErrorState('NO WEEKS ADDED FOR STORY MODE', null, function() {
				if (!switchToState('MainMenuState'))
					MusicBeatState.switchState(new MainMenuState());
			}));
			return;
		}

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;

		fondo = new FlxSprite(-100, -34.5).loadGraphic(Paths.image('storymode/bgstory'));
		fondo.scrollFactor.set();
		fondo.setGraphicSize(FlxG.width);
		add(fondo);

		var grid:FlxBackdrop = new FlxBackdrop(Paths.image('storymode/grid' + FlxG.random.int(1, 4)));
		grid.velocity.set(40, 40);
		grid.alpha = 0.5;
		add(grid);

		muro = new FlxSprite().loadGraphic(Paths.image('storymode/muro'));
		muro.scrollFactor.set();
		muro.setGraphicSize(muro.width, FlxG.height);
		muro.y = (FlxG.height - muro.height) / 2;
		muro.x = FlxG.width - muro.width;
		add(muro);

		scoreText = new FlxText(10, FlxG.height * 0.7, 0, Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]), 36);
		scoreText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.RED);

		txtWeekTitle = new FlxText(10, 10, 0, '', 32);
		txtWeekTitle.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.BLACK);

		var uiTex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		storyChar = new Character(0, 0, 'bf', false);
		storyChar.dance();
		storyChar.color = FlxColor.BLACK;
		add(storyChar);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var num:Int = 0;
		var itemTargets:Array<Float> = [0, 0];
		weekTargetXs = [];
		for (i in 0...WeekData.weeksList.length) {
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			if (weekFile == null)
				continue;

			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if (!isLocked || !weekFile.hiddenUntilUnlocked) {
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);

				var weekThing:MenuItem = new MenuItem(0, 0, WeekData.weeksList[i]);
				weekThing.scale.set(0.4, 0.4);
				weekThing.ID = num;
				weekThing.y += (weekThing.height + 20) * weekThing.ID;
				weekThing.targetY = itemTargets[1];
				weekTargetXs.push(itemTargets[0]);
				itemTargets[0] = Math.max(weekThing.x, weekThing.x + weekThing.width / 2) + 10;
				itemTargets[1] += Math.max(weekThing.height, 110) + 10;
				weekThing.screenCenter();
				weekThing.x = FlxG.width * 1.15;
				grpWeekText.add(weekThing);

				if (isLocked) {
					var lock:FlxSprite = new FlxSprite(10 - weekThing.x);
					lock.antialiasing = ClientPrefs.data.antialiasing;
					lock.frames = uiTex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = weekThing.ID;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		if (loadedWeeks.length < 1) {
			if (!switchToState('MainMenuState'))
				MusicBeatState.switchState(new MainMenuState());
			return;
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(50, 50);
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		leftArrow.frames = uiTex;
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.addByPrefix('press', 'arrow push left');
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		Difficulty.resetList();
		if (lastDifficultyName == '')
			lastDifficultyName = Difficulty.getDefault();
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		rightArrow.frames = uiTex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', 'arrow push right', 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07 + 100, 425).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.data.antialiasing;
		tracksSprite.x -= tracksSprite.width / 2;
		add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, '', 32);
		txtTracklist.alignment = 'center';
		txtTracklist.font = Paths.font('vcr.ttf');
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		changeWeek();
		changeDifficulty();
	}

	override function closeSubState():Void {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function beatHit():Void {
		super.beatHit();
		if (storyChar != null && curBeat % storyChar.danceEveryNumBeats == 0)
			storyChar.dance();
	}

	override function update(elapsed:Float):Void {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (intendedScore != lerpScore) {
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
			if (Math.abs(intendedScore - lerpScore) < 10)
				lerpScore = intendedScore;
			scoreText.text = Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]);
		}

		if (!movedBack && !selectedWeek) {
			var changeDiff:Bool = false;
			if (controls.UI_UP_P) {
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeDiff = true;
			}

			if (controls.UI_DOWN_P) {
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeDiff = true;
			}

			if (FlxG.mouse.wheel != 0) {
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press');
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);
			else if (changeDiff)
				changeDifficulty();

			if (FlxG.keys.justPressed.CONTROL) {
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			} else if (controls.RESET) {
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
			} else if (controls.ACCEPT) {
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			if (!switchToState('MainMenuState'))
				MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		var selectedItem:MenuItem = grpWeekText.members[curWeek];
		if (selectedItem == null)
			return;

		var offY:Float = selectedItem.targetY;
		for (i in 0...grpWeekText.members.length) {
			var item:MenuItem = grpWeekText.members[i];
			if (item == null)
				continue;
			var dist:Int = Std.int(Math.abs(i - curWeek));
			var targetX:Float = item.targetY;
			if (dist == 0 && i < weekTargetXs.length)
				targetX = weekTargetXs[i];

			item.y = FlxMath.lerp(item.targetY - offY + 240, item.y, Math.exp(-elapsed * 10.2));
			item.x = FlxMath.lerp(targetX + FlxG.width - item.width * 1.5, item.x, Math.exp(-elapsed * 10.2));
		}

		for (lock in grpLocks.members) {
			if (lock == null || lock.ID < 0 || lock.ID >= grpWeekText.members.length)
				continue;

			var weekItem:MenuItem = grpWeekText.members[lock.ID];
			if (weekItem != null) {
				lock.x = weekItem.x + weekItem.width + 10;
				lock.y = weekItem.y + weekItem.height / 2 - lock.height / 2;
			}
		}
	}

	function selectWeek():Void {
		var currentWeek:WeekData = loadedWeeks[curWeek];
		if (weekIsLocked(currentWeek.fileName)) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		var songArray:Array<String> = [];
		var leWeek:Array<Dynamic> = currentWeek.songs;
		for (i in 0...leWeek.length)
			songArray.push(leWeek[i][0]);

		try {
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic:String = Difficulty.getFilePath(curDifficulty);
			if (diffic == null)
				diffic = '';

			PlayState.storyDifficulty = curDifficulty;
			Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
		} catch (e:Dynamic) {
			trace('ERROR! $e');
			selectedWeek = false;
			return;
		}

		if (!stopspamming) {
			FlxG.sound.play(Paths.sound('confirmMenu'));
			grpWeekText.members[curWeek].isFlashing = true;

			storyChar.color = FlxColor.WHITE;
			storyChar.skipDance = true;
			var finish = function(_:String) {
				selectedWeek = false;
				stopspamming = false;
				storyChar.skipDance = false;
				storyChar.color = FlxColor.BLACK;
			};

			if (storyChar.hasAnimation('dance')) {
				storyChar.playAnim('dance');
				storyChar.animation.curAnim.looped = false;
				storyChar.animation.finishCallback = finish;
			} else if (storyChar.animationsArray.length > 0) {
				var anim:String = storyChar.animationsArray[FlxG.random.int(0, storyChar.animationsArray.length - 1)].anim;
				storyChar.playAnim(anim);
				storyChar.animation.curAnim.looped = false;
				storyChar.animation.finishCallback = finish;
			}
			stopspamming = true;
		}

		var directory:String = StageData.forceNextDirectory;
		LoadingState.loadNextDirectory();
		StageData.forceNextDirectory = directory;
		LoadingState.prepareToSong();
		new FlxTimer().start(1, function(_:FlxTimer) {
			FlxG.sound.music.stop();
			LoadingState.loadAndSwitchState(new PlayState(), true);
			FreeplayState.destroyFreeplayVocals();
		});
	}

	function changeDifficulty(change:Int = 0):Void {
		curDifficulty += change;
		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length - 1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = Difficulty.getString(curDifficulty, false);
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		if (sprDifficulty.graphic != newImage) {
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - sprDifficulty.height + 50;
			FlxTween.cancelTweensOf(sprDifficulty);
			FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 30, alpha: 1}, 0.07);
		}
		lastDifficultyName = diff;
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
	}

	function changeWeek(change:Int = 0):Void {
		curWeek += change;
		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = Language.getPhrase('storyname_${leWeek.fileName}', leWeek.storyName);
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - txtWeekTitle.width - 10;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (i in 0...grpWeekText.members.length) {
			var item:MenuItem = grpWeekText.members[i];
			if (item != null)
				item.alpha = (i == curWeek && unlocked) ? 1 : 0.6;
		}

		PlayState.storyWeek = curWeek;
		Difficulty.loadFromWeek();
		difficultySelectors.visible = unlocked;

		if (Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		if (newPos > -1)
			curDifficulty = newPos;

		updateText();
	}

	function offsetFixBasedOnScale():Void {
		for (anim in storyChar.animOffsets.keys()) {
			storyChar.animOffsets.get(anim)[0] *= storyChar.scale.x;
			storyChar.animOffsets.get(anim)[1] *= storyChar.scale.y;
			storyChar.playAnim(anim, true);
		}
		storyChar.dance();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return leWeek != null && !leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore));
	}

	function updateText():Void {
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		if (weekArray[0] == '') {
			storyChar.visible = false;
			storyChar.missingCharacter = false;
		} else {
			storyChar.visible = true;
			storyChar.changeCharacter(weekArray[0]);
			var modifScale:Float = storyChar.scale.x * 0.5;
			storyChar.scale.set(1, 1);
			storyChar.screenCenter();
			storyChar.x -= storyChar.width / 2;
			storyChar.scale.set(modifScale, modifScale);
			offsetFixBasedOnScale();
			storyChar.missingCharacter = false;
			storyChar.setPosition(storyCharPos[0], storyCharPos[1]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length)
			stringThing.push(leWeek.songs[i][0]);

		txtTracklist.text = '';
		for (song in stringThing)
			txtTracklist.text += song + '\n';
		txtTracklist.text = txtTracklist.text.toUpperCase();
		txtTracklist.x = (FlxG.width - txtTracklist.width) / 2;
		txtTracklist.x -= FlxG.width * 0.35;

		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
	}
}
