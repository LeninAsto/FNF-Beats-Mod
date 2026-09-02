local selected = false
local playstate = 'states.PlayState'
local diffs = {'backend.Difficulty', 'list'} -- broooo its just list not defaultList 

function onCreate()
luaDebugMode = true
if string.find(version, '0.6') then --some version shit :bleh:
playstate = 'PlayState'
diffs = {'CoolUtil', 'difficulties'}
end
precacheImage('Pause Stuff')
end

function onCreatePost()
	runHaxeCode([[
		var camPause = new FlxCamera();
		camPause.bgColor = 0xF;
		FlxG.cameras.remove(game.camHUD, false);
		FlxG.cameras.remove(game.camOther, false);
		FlxG.cameras.add(game.camHUD, false);
		FlxG.cameras.add(game.camOther, false);
		FlxG.cameras.add(camPause, false);
		setVar('camPause', camPause);
	]])
end

function onPause()
if getPropertyFromClass(playstate, 'chartingMode') then return end
	selected = false
	runHaxeCode([[
	game.camGame.setFilters([new openfl.filters.BlurFilter()]);
	game.camHUD.setFilters([new openfl.filters.BlurFilter()]);
	//game.camOther.setFilters([new openfl.filters.BlurFilter()]);
	]])
	openCustomSubstate('PauseScreen', true)
	return Function_Stop
end

function onResume()
	runHaxeCode([[
	game.camGame.setFilters([]);
	game.camHUD.setFilters([]);
	game.camOther.setFilters([]);
	]])
end

function onCustomSubstateCreate(name)
	if name == 'PauseScreen' then
		pauseMusic(true)
		for i, name in ipairs({'PauseBase', 'reanudar', 'reiniciar', 'salir', 'flecha'}) do
			quickSprite(true, name, 'Pause Stuff', 0, 0)
			addAnimationByPrefix(name, name, name, 24, false)
			setProperty(name..'.x', -getProperty(name..'._frame.frame.width'))
			if i > 1 and i < 5 then --no base ni flecha
				setProperty(name..'.y', 250 * i)
				setProperty(name..'.y', getProperty(name..'.y') - 500)
			end
			local exxes = {0, 10,10,10, 483}
			doTweenX(name, name, exxes[i], 0.5, 'expoOut')
		end
		setProperty('flecha.y', screenHeight*2)
		setProperty('flecha.color', '000000')
		local pstate = {'SONG.song', 'storyDifficulty', 'deathCounter'}
		local diffList = getPropertyFromClass(diffs[1], diffs[2])
		local y = 0
		for i,txt in pairs({'song', 'diff', 'deds'}) do
			local getter = getPropertyFromClass(playstate, pstate[i])--funny gimmic, if you change the propertys, it'll be shown here
			local diffString = i == 2 and string.upper(diffList[getter+1]) or ''
			quickText(txt, i == 2 and 'Difficulty: '..diffString or (i == 3 and 'Deaths: '..getter or 'You are Playing: '..getter), 0, screenWidth, -40)
			setFormat(txt, 'vcr.ttf', 40, 'FFFFFF', 'right', 2, '000000')
			setProperty(txt..'.x', screenWidth - getProperty(txt..'.width') + 1)
			setProperty(txt..'.y', - getProperty(txt..'.height'))
			setProperty(txt..'.alpha', 0)
			doTweenAlpha(txt..'Al', txt, 1, 0.4*i, 'quartInOut')
			doTweenY(txt..'y', txt, y, 0.4*i, 'quartInOut')
			y = y + getProperty(txt..'.height')+ 1.5
		end
	if buildTarget == 'android' then pauseButtons() end
	end
end

function closer()
	for _,obj in pairs({'PauseBase', 'reanudar', 'reiniciar', 'salir', 'flecha'}) do
		selected = false
		doTweenX(obj, obj, -getProperty(obj..'._frame.frame.width'), 0.25, 'expoOut')
	end
	for i,others in pairs({'song', 'diff', 'deds', 'Up', 'Down', 'A'}) do
		selected = false
		doTweenX(others, others, screenWidth, (i > 3 and 0.055 or 0.25)*i, 'expoOut')
	end
end

local items = {'reanudar', 'reiniciar', 'salir'}
local stuffer = {y = {50, 340, 560}, col = {'ffe367', 'ff6361', '61ff80'}}
local newY = stuffer.y[3]+100
local newColor = stuffer.col[1]
local curSelected = 1

function onCustomSubstateUpdate(n)
--debugPrint('                                                                                                  ', selected)
setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
if n ~= 'PauseScreen' then return end
if getMouseX('other') < 0 then restartSong() end
if selected then return end

local upPressed = (buildTarget == 'android' and mouseOverlap('Up') and mouseClicked('left')) or keyJustPressed('up')
local downPressed = (buildTarget == 'android' and mouseOverlap('Down') and mouseClicked('left')) or keyJustPressed('down')
local aPressed = (buildTarget == 'android' and mouseOverlap('A') and mouseClicked('left')) or keyJustPressed('accept')
setInputs(upPressed, downPressed, aPressed)

if upPressed then
curSelected = curSelected - 1
animateFlecha(true)
elseif downPressed then
curSelected = curSelected + 1
animateFlecha(false)
elseif aPressed then
closer();
selected = true
runTimer(items[curSelected], 0.35, 1)
soundFadeOut('pauseMusic', 1) --Args: tag(if nil then music), duration, to(def:0)
end

if curSelected < 1 then 
curSelected = #items
elseif curSelected > #items then 
curSelected = 1 
end

newY = stuffer.y[curSelected]
newColor = stuffer.col[curSelected]
doTweenY('flechaY', 'flecha', newY, 1, 'expoOut')
doTweenColor('flechaCol', 'flecha', newColor, 1, 'expoOut')
end

-- === Helpers ===
function animateFlecha(reversed)
	playAnim('flecha', 'flecha', true, reversed)
	--setProperty('flecha.animation.curAnim.reversed', reversed or false)
	playSound('scrollMenu', 0.2)
end

function setInputs(up, down, a)
	inputPress('Up', up)
	inputPress('Down', down)
	inputPress('A', a)
end

function onTimerCompleted(t)
	if t == items[1] then--reanudar
		closeCustomSubstate('PauseScreen', true)
	elseif t == items[2] then--reiniciar
		restartSong();
	elseif t == items[3] then--salir
		exitSong();
	end
end

function createButton(name, x, y, idleFrame, pressedFrame, loop, order)
	makeLuaSprite(name, nil, x, y)
	loadGraphic(name, 'Buttons', 132, 132)
	addAnimation(name, 'idle', {idleFrame}, 1, loop)
	addAnimation(name, 'pressed', {pressedFrame}, 1, loop)
	--setOnPauseCam(name)
	--addLuaSprite(name, true)
	setProperty(name..'.alpha', 0)
	doTweenAlpha(name..'Added', name, 1, 0.55, 'linear')
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
playAnim(input, press and 'pressed' or 'idle')
end
end

function pauseMusic(freshlyOpened)
	local music = getPropertyFromClass((string.find(version, '0.6') and '' or 'backend.')..'ClientPrefs', 'pauseMusic')
	local path = '../music/'..music
	
	if checkFileExists(currentModDirectory..'/music/'..music..'.ogg') then
	    spacePrinter('found in '..currentModDirectory..'/music')
	    path = '../music/'..music
	elseif checkFileExists('music/'..music..'.ogg') then
	    spacePrinter('found in music')
	    path = '../../music/'..music
	elseif checkFileExists('../assets/music/'..music..'.ogg') then
	    spacePrinter('found in assets/music')
	    path = '../../../assets/music/'..music
	elseif checkFileExists('../assets/shared/music/'..music..'.ogg') then
	    spacePrinter('found in assets/shared/music')
	    path = '../../../assets/shared/music/'..music
	else
	    spacePrinter('playing default music')
	    path = '../../../assets/shared/music/breakfast'
	end
	
	playSound(path, freshlyOpened and 1 or 1, 'pauseMusic')
	if not freshlyOpened then return end
	--soundFadeIn('pauseMusic', 5, 0, 0.05) --Args: tag(if nil then music), duration, from(def:0), to(def:1)
	setSoundTime('pauseMusic', getRandomInt(0, (getSoundLength('pauseMusic') - 1500)))
end
function spacePrinter(b,c,d,e)
debugPrint('                                                                                                  ',b,c,de)
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
--setOnPauseCam(tag)
runHaxeCode('CustomSubstate.instance.add(game.getLuaObject("'..tag..'"));')
end

function quickText(tag, text, width, x, y)
	makeLuaText(tag, '', 0, x, y)
	runHaxeCode('game.getLuaObject("'..tag..'").cameras = null;')
	setTextString(tag, text)
	widtth = width or 0
	setTextWidth(tag, widtth)
	--addLuaText(tag, true)
	--setOnPauseCam(tag)
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

function mouseOverlap(obj, mouseCamera, offsetX, offsetY) --thanks to Rudyrue, and with some modifications and optimizations
	 mouseCamera = mouseCamera or 'camHUD'
	 offsetX = offsetX or 0
	 offsetY = offsetY or 0
	 overlapX = (getMouseX(mouseCamera) + offsetX) >= getProperty(obj .. '.x') and (getMouseX(mouseCamera) + offsetX) <= getProperty(obj .. '.x') + (getProperty(obj .. '.width') / (getProperty(obj .. '.flipX') and getProperty(obj .. '.scale.x') or 1))
	 overlapY = (getMouseY(mouseCamera) + offsetY) >= getProperty(obj .. '.y') and (getMouseY(mouseCamera) + offsetY) <= getProperty(obj .. '.y') + (getProperty(obj .. '.height') / (getProperty(obj .. '.flipY') and getProperty(obj .. '.scale.y') or 1))
	 return overlapX and overlapY
end

function setOnPauseCam(obj)
	local getter = "game.getLuaObject('"..obj.."')"
	if luaTextExists(obj) then getter = "game.modchartTexts.get('"..obj.."')" end
	debugPrint('                                                                                                  ', getter)
	runHaxeCode(getter..".camera = camPause;")
end

function getSoundLength(tag)
	return runHaxeCode('game.modchartSounds.get("'..tag..'").length;')
end