local portraits = {}
local portraitNames = {}
local currentAnim = {'', ''}

function onCreate()
luaDebugMode = true
end

function getChar(c)
local n = -1
local string = string.lower(tostring(c))
	if string == 'gf' or string == 'girlfriend' or string == '2' then n = 2
	elseif string == 'dad' or string == 'opponent' or string == '1' then n = 1
	else n = 0 end
	return n
end

function onEvent(n,v1)
	if n == 'Change Character' then
		if getChar(v1) == 2 then return end
		makePortraits(getChar(v1))
	end
end

function onCreatePost()
	makePortraits(0) --player a.k.a boyfriend
	makePortraits(1) --opponent a.k.a dad
end

function makePortraits(i)
	local chr = i == 1 and 'dad' or 'boyfriend'
	local icon = getProperty(chr..'.healthIcon')
	local file = portraitExists(icon) and 'HBPortraits/'..icon or 'HBPortraits/face'
	if file == 'HBPortraits/face' and not portraitExists('face') then close(true) end

	local pName = 'Portrait'..i
	if luaSpriteExists(pName) then removeLuaSprite(pName, true) end
	makeAnimatedLuaSprite(pName, file, 0, 0)
	addAnimationByPrefix(pName, 'idle', 'idle', 24, true)
	addAnimationByPrefix(pName, 'lose', 'lose', 24, true)
	playAnim(pName, 'idle')
	setObjectCamera(pName, 'hud')
	scaleObject(pName, 0.7, 0.7)
	setProperty(pName..'.x', i == 1 and 0 or (screenWidth - getProperty(pName..'.width')))
	setProperty(pName..'.y', (screenHeight - getProperty(pName..'.height')))
	setProperty(pName..'.flipX', i == 0)
	addLuaSprite(pName)
	portraits[i] = pName

	local nName = 'PortraitName'..i
	if luaSpriteExists(nName) then removeLuaSprite(nName, true) end
	makeAnimatedLuaSprite(nName, file, 0, 0)
	addAnimationByPrefix(nName, 'name', 'name', 24, false)
	setObjectCamera(nName, 'hud')
	scaleObject(nName, 0.7, 0.7)
	local nameWidth, portraitMidX, y, h = getProperty(nName..'.width'), getMidpointX(pName), getProperty(pName..'.y'), getProperty(pName..'.height')
	setProperty(nName..'.x', portraitMidX - (nameWidth / 2) + (i == 1 and -25 or 25))
	setProperty(nName..'.y', y + h - 40)
	addLuaSprite(nName)
	portraitNames[i] = nName

	currentAnim[i] = 'idle'
end

function onUpdate()
	local healthPercent = getProperty('healthBar.percent')
	local anim1 = (healthPercent > 80) and 'lose' or 'idle' -- opponent
	local anim2 = (healthPercent < 20) and 'lose' or 'idle' -- player

	for i = 0, 1 do
		local anim = (i == 1) and anim1 or anim2
		local pName = portraits[i]

		if pName ~= nil and luaSpriteExists(pName) and currentAnim[i] ~= anim then
			playAnim(pName, anim, true)
			currentAnim[i] = anim
		end
	end
end

function onBeatHit()
	for i = 0, 1 do
		if portraitNames[i] ~= nil and luaSpriteExists(portraitNames[i]) then
			playAnim(portraitNames[i], 'name', true)
		end
	end

	local turnvalue = curBeat % 2 == 0 and -20 or 20
	setProperty('iconP2.angle', -turnvalue)
	setProperty('iconP1.angle', turnvalue)
	doTweenAngle('iconTween1', 'iconP1', 0, crochet / 1000, 'circOut')
	doTweenAngle('iconTween2', 'iconP2', 0, crochet / 1000, 'circOut')
end

function portraitExists(sprt)
	return checkFileExists('images/HBPortraits/'..sprt..'.png') and checkFileExists('images/HBPortraits/'..sprt..'.xml')
end
