local fnfBeatsVsStarted = false
local fnfBeatsVsDone = false
local fnfBeatsVsStepSeconds = 0.82
local fnfBeatsVsTweenSeconds = 0.55
local fnfBeatsVsFadeSeconds = 0.3

function fnfbeatsPlaybackRate()
	local rate = getProperty('playbackRate')
	if rate == nil or rate <= 0 then
		return 1
	end
	return rate
end

function onCreate()
	luaDebugMode = false
end

function onStartCountdown()
	if fnfBeatsVsDone then
		return Function_Continue
	end

	if fnfBeatsVsStarted then
		return Function_Stop
	end

	fnfBeatsVsStarted = true
	createFnfBeatsVsBackdrop()
	runTimer('fnfbeatsVsIntro', fnfBeatsVsStepSeconds, 4)
	return Function_Stop
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag ~= 'fnfbeatsVsIntro' then
		return
	end

	if loopsLeft <= 0 then
		fnfBeatsVsDone = true
		removeFnfBeatsVs()
		startCountdown()
		return
	end

	spawnFnfBeatsVs(loopsLeft)
end

function spawnFnfBeatsVs(step)
	local data = {
		[3] = {'Right', 'dad'},
		[2] = {'Left', 'boyfriend'},
		[1] = {'Central', 'vs'}
	}

	local entry = data[step]
	if entry == nil then
		return
	end

	local side = entry[1]
	local source = entry[2]
	local image = source
	if source ~= 'vs' then
		image = getProperty(source..'.healthIcon')
	end

	if image == nil or image == '' then
		image = 'staticguy'
	end

	if source ~= 'vs' and not checkFileExists('images/VsPortraits/'..image..'.png') then
		image = 'staticguy'
	end

	local sound = image
	if image == 'staticguy' then
		sound = 'huh'
	end
	if source == 'vs' then
		sound = 'vs'
	end

	playSound('vsSounds/'..sound, 1, 'fnfbeatsVsSound'..step)
	if setSoundPitch ~= nil then
		setSoundPitch('fnfbeatsVsSound'..step, fnfbeatsPlaybackRate())
	end

	for layer = 1, 2 do
		local tag = 'fnfbeatsVS_'..side..layer
		makeLuaSprite(tag, 'VsPortraits/'..image, 0, 0)
		addLuaSprite(tag, true)
		setObjectCamera(tag, 'other')
		screenCenter(tag)
		scaleObject(tag, 1.5, 2, false)
		setProperty(tag..'.flipX', step == 3 and image == 'staticguy')

		if layer == 1 then
			setProperty(tag..'.color', getColorFromHex(source == 'vs' and 'FFFFFF' or '000000'))
		end

		doTweenX(tag..'ScaleX', tag..'.scale', layer == 1 and 0.7 or 0.65, fnfBeatsVsTweenSeconds, 'bounceOut')
		doTweenY(tag..'ScaleY', tag..'.scale', layer == 1 and 0.7 or 0.65, fnfBeatsVsTweenSeconds, 'bounceOut')
		if step > 1 then
			local targetX = step == 3 and 0 or screenWidth - getProperty(tag..'.width')
			doTweenX(tag..'X', tag, targetX, fnfBeatsVsTweenSeconds, 'expoOut')
		end
	end
end

function createFnfBeatsVsBackdrop()
	local tag = 'fnfbeatsVS_Backdrop'
	if luaSpriteExists(tag) then
		removeLuaSprite(tag, true)
	end

	makeLuaSprite(tag, '', 0, 0)
	makeGraphic(tag, screenWidth, screenHeight, '000000')
	setObjectCamera(tag, 'other')
	setProperty(tag..'.alpha', 0)
	addLuaSprite(tag, true)
	doTweenAlpha(tag..'FadeIn', tag, 1, 0.18, 'linear')
end

function removeFnfBeatsVs()
	if luaSpriteExists('fnfbeatsVS_Backdrop') then
		doTweenAlpha('fnfbeatsVS_BackdropBye', 'fnfbeatsVS_Backdrop', 0, fnfBeatsVsFadeSeconds, 'linear')
	end

	for _, side in ipairs({'Right', 'Left', 'Central'}) do
		for layer = 1, 2 do
			local tag = 'fnfbeatsVS_'..side..layer
			if luaSpriteExists(tag) then
				doTweenAlpha(tag..'Bye', tag, 0, fnfBeatsVsFadeSeconds, 'linear')
			end
		end
	end
end

function onTweenCompleted(tag)
	if stringStartsWith(tag, 'fnfbeatsVS_') and stringEndsWith(tag, 'Bye') then
		local sprite = string.gsub(tag, 'Bye$', '')
		removeLuaSprite(sprite, true)
	end
end
