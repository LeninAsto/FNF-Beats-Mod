local selected = false
local useClassedPauseSubState = true
local playstate = 'states.PlayState'
local diffs = {'backend.Difficulty', 'list'} -- broooo its just list not defaultList
local coolPath = ''

function fnfbeatsPauseRate()
	local rate = getProperty('playbackRate')
	if rate == nil or rate <= 0 then
		return 1
	end
	return rate
end

function onCreate()
	luaDebugMode = true
	if string.find(version, '0.6') then --some version shit :bleh:
		playstate = 'PlayState'
		diffs = {'CoolUtil', 'difficulties'}
	end
	precacheImage('Pause Stuff')
end

function onCreatePost()
	if useClassedPauseSubState then
		return
	end
	setPropertyFromClass('Main', 'fpsVar.visible', true)
	setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
	coolPath = stringSplit(scriptName, 'mods/')[1]
	makeLuaSprite('pauseBulur')
	initLuaShader('blur')
	setSpriteShader('pauseBulur', 'blur')
	setShaderFloat('pauseBulur', 'amount', 5)
	runHaxeCode([[
		var camPause = new FlxCamera();
		camPause.bgColor = 0xF;
		if (FlxG.onMobile) {
			var controlsCam = FlxG.cameras.list[3];
			//--controlsCam.visible = true;
			FlxG.cameras.remove(game.camHUD, false);
			FlxG.cameras.remove(game.camOther, false);
			FlxG.cameras.remove(controlsCam, false);
			FlxG.cameras.add(game.camHUD, false);
			FlxG.cameras.add(game.camOther, false);
			FlxG.cameras.add(controlsCam, false);
			//--game = 0, hud = 1, other = 2, controls = 3, pause = 4
		} else {
			FlxG.cameras.remove(game.camHUD, false);
			FlxG.cameras.remove(game.camOther, false);
			FlxG.cameras.add(game.camHUD, false);
			FlxG.cameras.add(game.camOther, false);
		}
		FlxG.cameras.add(camPause, false);
		game.luaDebugGroup.cameras = [camPause];
		setVar("pauseBlur", new openfl.filters.ShaderFilter(game.getLuaObject('pauseBulur').shader));
		setVar('camPause', camPause);
	]])
end

local nocustompause = true
function onPause()
if useClassedPauseSubState then return Function_Continue end
--if nocustompause then return end
if getPropertyFromClass(playstate, 'chartingMode') then return end
	selected = false
	runHaxeCode([[
	function blurCam(cam) {
		if (cam._filters == null) cam._filters = [];
		cam._filters.push(getVar('pauseBlur'));
	}
	blurCam(game.camGame);
	blurCam(game.camHUD);
	blurCam(game.camOther);
	if (FlxG.onMobile) {
		var controlsCam = FlxG.cameras.list[3];
		blurCam(controlsCam);
	}
	]])
	openCustomSubstate('PauseScreen', true)
	return Function_Stop
end

local artist,charter = 'hmmm','hmmm?'
local ischartershowing = false
function createPauseOffscreen()
	local pstate = {'SONG.song', '', 'storyDifficulty', 'deathCounter'}
	local diffColers = {['EASY'] = '00FF00', ['NORMAL'] = 'FFFF00', ['HARD'] = 'FF0000'}
	local diffList = getPropertyFromClass(diffs[1], diffs[2])
	local modPack = (currentModDirectory == '' and '' or currentModDirectory..'/')
	if checkFileExists(coolPath..'mods/'..modPack..'data/'..songPath..'/creds.txt', true) then
		local credFile = getTextFromFile(currentModDirectory..'/data/'..songPath..'/creds.txt')
		artist= credFile:match("artist%s*=%s*([^\r\n]+)") or "hmmm"
		charter = credFile:match("charter%s*=%s*([^\r\n]+)") or "hmmm?"
	end
		
	for i,txt in ipairs({'song', 'creds', 'diff', 'deds'}) do
		local getter = getPropertyFromClass(playstate, pstate[i])
		local diffString = txt == 'diff' and string.upper(diffList[getter+1]) or ''
		
		local text, rgb, deli, col
		if txt == 'creds' then text = 'Artist: '..artist
		elseif txt == 'diff' then text, deli, col = 'Difficulty: &&'..diffString..'&&', '&&', diffColers[diffString]
		elseif txt == 'deds' then text, deli, col = 'Deaths: ##'..getter..'##', '##', (tonumber(getter) > 0 and "FF0000" or "FFFFFF")
		else text, deli, rgb = 'You were playing: ||'..getter..'||', '||', getProperty('dad.healthColorArray') end
		if rgb ~= nil then col = rgbToHex(rgb) end
		quickText(txt, (deli ~= nil and '' or text), 0, screenWidth, -40)
		if deli ~= nil then applyMarkup(txt, text, getColorFromHex(col), deli) end
		setFormat(txt, 'vcr.ttf', 22, 'FFFFFF', 'right', 2, '000000')
		setProperty(txt..'.x', screenWidth - getProperty(txt..'.width') + 1)
		setProperty(txt..'.y', -getProperty(txt..'.height'))
		setProperty(txt..'.alpha', 0)
	end
	
	for i, name in ipairs({'PauseBase', 'reanudar', 'reiniciar', 'salir', 'flecha'}) do
		quickSprite(true, name, 'Pause Stuff', 0, 0)
		if i > 1 and i < 5 then
			scaleObject(name, 0.25, 0.25, false)
		end
		addAnimationByPrefix(name, name, name, 24, false)
		setProperty(name..'.x', -getProperty(name..'._frame.frame.width'))
		if i > 1 and i < 5 then
			setProperty(name..'.y', (250 * i) - 500)
		end
	end
	
	quickText('chartEditor', 'Go to Chart Editor', 0, 50, 700)
	setFormat('chartEditor', 'vcr.ttf', 15, '000000', 'left', 1, 'FFFFFF')
	setProperty('chartEditor.x', -getProperty('chartEditor.width'))
	setProperty('flecha.y', screenHeight * 2)
	setProperty('flecha.color', '000000')
end

local curSelected = 1
local curOption = "none"

function onCustomSubstateCreate(name)
	if name == 'PauseScreen' then
		createPauseOffscreen()
		runHaxeCode('CustomSubstate.instance.add(game.luaDebugGroup);')
		pauseMusic(true)
		ischartershowing = false
		
		local y = 0
		for i,txt in ipairs({'song', 'creds', 'diff', 'deds'}) do
			doTweenAlpha(txt..'Al', txt, 1, 0.4*i, 'quartInOut')
			doTweenY(txt..'y', txt, y, 0.4*i, 'quartInOut')
			y = y + getProperty(txt..'.height') + 1.5
		end
		
		local exxes = {0, 10, 10, 10, 483, 50}
		for i, name in ipairs({'PauseBase', 'reanudar', 'reiniciar', 'salir', 'flecha', 'chartEditor'}) do
			doTweenX(name, name, exxes[i], 0.5, 'expoOut')
		end
		
		runTimer('changeCredDelay', 10)
		if buildTarget == 'android' then
			pauseButtons()
		end
		curSelected = 1
		curOption = "none"
	end
end

function closer()
	runHaxeCode([[
	CustomSubstate.instance.remove(game.luaDebugGroup);
	function unblurCam(cam) {
		if (cam._filters != null) cam._filters.pop(); 
	}
	unblurCam(game.camGame);
	unblurCam(game.camHUD);
	unblurCam(game.camOther);
	if (FlxG.onMobile) {
		var controlsCam = FlxG.cameras.list[3];
		unblurCam(controlsCam);
	}
	]])
	
	for _,obj in ipairs({'PauseBase', 'reanudar', 'reiniciar', 'salir', 'flecha'}) do
		doTweenX(obj, obj, -getProperty(obj..'._frame.frame.width'), 0.25, 'expoOut')
	end
	local rightStuff = {'song', 'creds', 'diff', 'deds'}
	if buildTarget == 'android' then table.insert(rightStuff, 'Up') table.insert(rightStuff, 'Down') table.insert(rightStuff, 'A') end
	for i,others in ipairs(rightStuff) do
		selected = false
		doTweenX(others, others, screenWidth, (i > 3 and 0.055 or 0.25)*i, 'expoOut')
	end
	doTweenX('chartEditor', 'chartEditor', -getProperty('chartEditor.width'), 0.25, 'expoOut')
end

local items = {'reanudar', 'reiniciar', 'salir', 'chart'}
local stuffer = {y = {50, 340, 560, 670}, col = {'ffe367', 'ff6361', '61ff80', '000000'}}
local newY = stuffer.y[4]+100
local newColor = stuffer.col[1]

function onCustomSubstateUpdate(n)
	if n ~= 'PauseScreen' then return end
	if getMouseX('other') < 0 then restartSong() end
	if selected then return end
	local upPressed = (buildTarget == 'android' and mouseOverlap('Up') and mouseClicked('left')) or keyJustPressed('up')
	local downPressed = (buildTarget == 'android' and mouseOverlap('Down') and mouseClicked('left')) or keyJustPressed('down')
	local aPressed = (buildTarget == 'android' and mouseOverlap('A') and mouseClicked('left')) or keyJustPressed('accept')
	setInputs(upPressed, downPressed, aPressed)
	if upPressed then animateFlecha(-1)
	elseif downPressed then animateFlecha(1)
	elseif aPressed then
		closer();
		selected = true
		runTimer(curOption, 0.35, 1)
		soundFadeOut('pauseMusic', 1) --Args: tag(if nil then music), duration, to(def:0)
	end
	
	if curOption ~= items[curSelected] then
		curOption = items[curSelected]
		newY = stuffer.y[curSelected]
		doTweenY('flechaY', 'flecha', newY, 1, 'expoOut')
		newColor = stuffer.col[curSelected]
		doTweenColor('flechaCol', 'flecha', newColor, 1, 'expoOut')
		for thing = 1,#items do
			local scal = items[thing] == curOption and 1 or 0.8
			if luaSpriteExists(items[thing]) then -- the chart text doesn get scaled ):
				doTweenX('optionScaleX'..thing, items[thing]..'.scale', scal, 1, 'expoOut')
				doTweenY('optionScaleY'..thing, items[thing]..'.scale', scal, 1, 'expoOut')
			end
		end
	end
	
	runHaxeCode([[
		for (debugers in game.luaDebugGroup) {
				debugers.x = 0;
			}
	]])
end

-- === Helpers ===
function animateFlecha(ch)
	playAnim('flecha', 'flecha', true, ch == -1)
	--setProperty('flecha.animation.curAnim.reversed', reversed or false)
	playSound('scrollMenu', 0.2)
	curSelected = curSelected + ch
	if curSelected < 1 then curSelected = #items
	elseif curSelected > #items then curSelected = 1 end
end

function setInputs(up, down, a)
	inputPress('Up', up)
	inputPress('Down', down)
	inputPress('A', a)
end

local theWhyys = {}
function onTimerCompleted(t)
	if t == items[1] then--reanudar
		closeCustomSubstate('PauseScreen', true)
	elseif t == items[2] then--reiniciar
		restartSong();
	elseif t == items[3] then--salir
		exitSong();
		setPropertyFromClass(playstate, 'seenCutscene', false)
	elseif t == items[4] then--chart
		runHaxeCode("game.openChartEditor();")
	end
	if t == 'changeCredDelay' then
		doTweenAlpha('fadeCred', 'creds', 0, 1, 'quadOut')
		theWhyys[1] = getProperty('creds.y')
		theWhyys[2] = getProperty('diff.y')
		theWhyys[3] = getProperty('deds.y')
		doTweenY('diffsUpps', 'diff', theWhyys[1], 1, 'backOut')
		doTweenY('dedsUpps', 'deds', theWhyys[2], 1.4, 'backOut')
	end
	if t == 'changeCredSecondDelay' then
		doTweenAlpha('unfadeCred', 'creds', 1, 1, 'quadOut')
		doTweenY('diffsDowwns', 'diff', theWhyys[2], 1, 'backOut')
		doTweenY('dedsDowwns', 'deds', theWhyys[3], 0.6, 'backOut')
		runTimer('changeCredDelay', 15)
	end
end

function onTweenCompleted(t)
	if t == 'fadeCred' then
		ischartershowing = not ischartershowing
		if getRandomBool(15) then
		setTextString('creds', meow(getRandomInt(2,20)))
		else
			if charter:lower() == 'kylefaz87' and ischartershowing then
				applyMarkup('creds', 'Charter: >:3'..charter..'>:3', getColorFromHex(rgbToHex({245, 166, 35})), '>:3')
			else
				removeMarkup('creds')
				setTextString('creds', ischartershowing and ('Charter: '..charter) or ('Artist: '..artist))
			end
		end
		updateText('creds')
		setProperty('creds.x', screenWidth - getProperty('creds.width') + 1)
		runTimer('changeCredSecondDelay', 5)
	end
end

function createButton(name, x, y, idleFrame, pressedFrame, loop, order)
	makeLuaSprite(name, nil, x, y)
	loadGraphic(name, 'Buttons', 132, 132)
	addAnimation(name, 'idle', {idleFrame}, 1, loop)
	addAnimation(name, 'pressed', {pressedFrame}, 1, loop)
	setOnPauseCam(name)
	--addLuaSprite(name, true)
	setScrollFactor(name, 0, 0)
	setProperty(name..'.alpha', 0)
	doTweenAlpha(name..'Added', name, 1, 0.55, 'linear')
	updateHitbox(name)
	--setObjectOrder(name, order)
	runHaxeCode('CustomSubstate.instance.add(game.getLuaObject("'..name..'"));')
end

function pauseButtons()
	createButton('Up', screenWidth - 130, screenHeight - 260, 4, 5, false, 99)
	setProperty('Up.color', getColorFromHex('A0FFA0'))
	createButton('Down', screenWidth - 130, screenHeight - 130, 2, 3, true, 99)
	setProperty('Down.color', getColorFromHex('A0A0FF'))
	createButton('A', screenWidth - 260, screenHeight - 130, 8, 9, false, 99)
	setProperty('A.color', getColorFromHex('00FF0E'))
end

function inputPress(input, press)
if luaSpriteExists(input) then
playAnim(input, press and 'pressed' or 'idle', true)
end
end

function pauseMusic(freshlyOpened)
	local varCheck = string.find(version, '0.6')
	local music = getPropertyFromClass((varCheck and '' or 'backend.')..'ClientPrefs', (varCheck and '' or 'data.')..'pauseMusic')
	if music == nil or music == '' or music == 'None' then
		music = 'breakfast'
	end
	local path = '../music/'..music
	local coolerPaths = {coolPath..'assets/', coolPath..'assets/shared', coolPath..'mods/', coolPath..'mods/'..currentModDirectory..'/'}
	if checkFileExists(coolerPaths[4]..'music/'..music..'.ogg', true) then
		--debugPrint('found in '..coolerPaths[4]..'/music')
		path = '../music/'..music --mods/modName/music
	elseif checkFileExists(coolerPaths[3]..'music/'..music..'.ogg', true) then
		--debugPrint('found in music')
		path = '../../music/'..music --mods/music
	elseif checkFileExists(coolerPaths[1]..'music/'..music..'.ogg', true) then
		--debugPrint('found in assets/music')
		path = '../../../assets/music/'..music
	elseif checkFileExists(coolerPaths[2]..'music/'..music..'.ogg', true) then
		--debugPrint('found in assets/shared/music')
		path = '../../../assets/shared/music/'..music
	else
		--debugPrint('playing default music')
		path = '../../../assets/shared/music/breakfast'
	end
	
	playSound(path, freshlyOpened and 0 or 0.05, 'pauseMusic')
	if not freshlyOpened then return end
	soundFadeIn('pauseMusic', 5, 0, 0.05) --Args: tag(if nil then music), duration, from(def:0), to(def:1)
	local musicLength = getSoundLength('pauseMusic')
	if musicLength ~= nil and musicLength > 1500 then
		setSoundTime('pauseMusic', getRandomInt(0, musicLength - 1500))
	end
end

function onSoundFinished(t)
if t == 'pauseMusic' then
if selected == false then pauseMusic(false) end
end
end

function quickSprite(animated, tag, file, x, y, front)
front = front or false
if animated then makeAnimatedLuaSprite(tag, file, x, y) else makeLuaSprite(tag, file, x, y) end
--addLuaSprite(tag, front)
setOnPauseCam(tag)
runHaxeCode('CustomSubstate.instance.add(game.getLuaObject("'..tag..'"));')
end

function quickText(tag, text, width, x, y)
	makeLuaText(tag, '', 0, x, y)
	runHaxeCode('game.getLuaObject("'..tag..'").cameras = null;')
	setTextString(tag, text)
	setTextWidth(tag, width)
	--addLuaText(tag, true)
	setOnPauseCam(tag)
	updateText(tag)
	runHaxeCode('CustomSubstate.instance.add(game.getLuaObject("'..tag..'"));')
end

function setFormat(text, font, size, color, alignment, borderSize, borderColor)
if borderSize == false or borderSize == nil then
borderSize = 0
end
setTextFont(text, font)
setTextSize(text, size)
setTextColor(text, color)
setTextAlignment(text, alignment)
if borderSize > 0 then
setTextBorder(text, borderSize, borderColor)
else
setTextBorder(text, 0, 0, '000000')
end
end

function mouseOverlap(obj)
	return runHaxeCode([[
		var spr = game.getLuaObject("]]..obj..[[");
		if (spr == null) return false;
		var mouse = FlxG.mouse.getScreenPosition(getVar('camPause'));
		var overlapX = mouse.x >= spr.x && mouse.x <= spr.x + (spr.width / (spr.flipX ? spr.scale.x : 1));
		var overlapY = mouse.y >= spr.y && mouse.y <= spr.y + (spr.height / (spr.flipY ? spr.scale.y : 1));
		return overlapX && overlapY;
	]])
end

function setOnPauseCam(obj)
	runHaxeCode([[
		game.getLuaObject(']]..obj..[[').camera = getVar('camPause');
	]])
end

function getSoundLength(tag)
	local get1 = runHaxeCode('return game.variables.get("sound_'..tag..'").length;')
	if get1 == 'return game.variables.get("sound_'..tag..'").length;' then
		local get2 = runHaxeCode('game.modchartSounds.get("'..tag..'").length;')
		if get2 == 'game.modchartSounds.get("'..tag..'").length;' then
			debugPrint('nah dude')
			return 1500
		else return get2 end
	else return get1 end
end

function updateText(text)
	runHaxeCode([[
		game.getLuaObject(']]..text..[[').drawFrame(true);
	]])
end

function meow(max)
	local count = getRandomInt(1, max)
	local meows = {}
	local posibleMeow = {
	'meow', 'm e o w',
	'mmrp?', 'mreow',
	':3', 'miau', '>:3'}
	for i = 1, count do
		meows[i] = posibleMeow[getRandomInt(1, #posibleMeow)]
	end
	return 'Meow: ' .. table.concat(meows, ' ')
end


function applyMarkup(tag, text, color, delimiter)		
	addHaxeLibrary("FlxTextFormatMarkerPair", "flixel.text")
	addHaxeLibrary("FlxTextFormat", "flixel.text")
	runHaxeCode([[
		var format = new FlxTextFormatMarkerPair(new FlxTextFormat(]]..color..[[), ']]..delimiter..[[');
		game.modchartTexts.get(']]..tag..[[').applyMarkup(']]..text..[[', [format]);
	]])
end

function removeMarkup(tag)
	runHaxeCode([[
		game.modchartTexts.get(']]..tag..[[').clearFormats();
	]])
end

function capitalize(str)
	local words = stringSplit(str,"-")
	local capitalized_words = {}
	for i, word in ipairs(words) do
		capitalized_words[i] = word:sub(1, 1):upper() .. word:sub(2)
	end
	return table.concat(capitalized_words, " ")
end

function rgbToHex(rgb) -- https://www.codegrepper.com/code-examples/lua/rgb+to+hex+lua
rgbT = rgb or {0,0,0}
	return string.format('%02x%02x%02x', math.floor(rgbT[1]), math.floor(rgbT[2]), math.floor(rgbT[3]))
end
