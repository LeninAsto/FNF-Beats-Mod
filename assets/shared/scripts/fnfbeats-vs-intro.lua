local fnfBeatsVsStarted = false
local fnfBeatsVsDone = false
local fnfBeatsVsDebug = true

function fnfbeatsVsTrace(message, color)
	local text = '[FNFBEATS VS INTRO] '..tostring(message)
	if fnfBeatsVsDebug and debugPrint ~= nil then
		debugPrint(text, color or 'CYAN')
	end
end

function fnfbeatsPlaybackRate()
	local rate = getProperty('playbackRate')
	if rate == nil or rate <= 0 then
		fnfbeatsVsTrace('playbackRate invalid/nil, using 1')
		return 1
	end
	return rate
end

function onCreate()
	luaDebugMode = true
	fnfbeatsVsTrace('script loaded. song='..tostring(songName)..' mod='..tostring(currentModDirectory))
end

function onStartCountdown()
	fnfbeatsVsTrace('onStartCountdown called. started='..tostring(fnfBeatsVsStarted)..' done='..tostring(fnfBeatsVsDone))

	if fnfBeatsVsDone then
		fnfbeatsVsTrace('intro already done, continuing countdown', 'GREEN')
		return Function_Continue
	end

	if fnfBeatsVsStarted then
		fnfbeatsVsTrace('intro already running, stopping countdown')
		return Function_Stop
	end

	fnfBeatsVsStarted = true
	fnfbeatsVsTrace('starting timers')
	runTimer('fnfbeatsVsIntro', 0.55 / fnfbeatsPlaybackRate(), 4)
	return Function_Stop
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag ~= 'fnfbeatsVsIntro' then
		return
	end

	fnfbeatsVsTrace('timer completed. loops='..tostring(loops)..' loopsLeft='..tostring(loopsLeft))

	if loopsLeft <= 0 then
		fnfBeatsVsDone = true
		fnfbeatsVsTrace('intro finished, removing sprites and restarting countdown', 'GREEN')
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
		fnfbeatsVsTrace('no entry for step '..tostring(step), 'YELLOW')
		return
	end

	local side = entry[1]
	local source = entry[2]
	local image = source
	if source ~= 'vs' then
		image = getProperty(source..'.healthIcon')
	end

	fnfbeatsVsTrace('spawn step='..tostring(step)..' side='..tostring(side)..' source='..tostring(source)..' rawImage='..tostring(image))

	if image == nil or image == '' then
		fnfbeatsVsTrace('empty image for '..tostring(source)..', using staticguy', 'YELLOW')
		image = 'staticguy'
	end

	if source ~= 'vs' and not checkFileExists('images/VsPortraits/'..image..'.png') then
		fnfbeatsVsTrace('missing portrait images/VsPortraits/'..tostring(image)..'.png, using staticguy', 'YELLOW')
		image = 'staticguy'
	end

	local sound = image
	if image == 'staticguy' then
		sound = 'huh'
	end
	if source == 'vs' then
		sound = 'vs'
	end

	fnfbeatsVsTrace('resolved image='..tostring(image)..' sound=vsSounds/'..tostring(sound))
	playSound('vsSounds/'..sound, 1, 'fnfbeatsVsSound'..step)
	if setSoundPitch ~= nil then
		setSoundPitch('fnfbeatsVsSound'..step, fnfbeatsPlaybackRate())
	else
		fnfbeatsVsTrace('setSoundPitch unavailable')
	end

	for layer = 1, 2 do
		local tag = 'fnfbeatsVS_'..side..layer
		fnfbeatsVsTrace('creating sprite '..tag..' asset=VsPortraits/'..tostring(image))
		makeLuaSprite(tag, 'VsPortraits/'..image, 0, 0)
		addLuaSprite(tag, true)
		setObjectCamera(tag, 'other')
		screenCenter(tag)
		scaleObject(tag, 1.5, 2, false)
		setProperty(tag..'.flipX', step == 3 and image == 'staticguy')

		if layer == 1 then
			setProperty(tag..'.color', getColorFromHex(source == 'vs' and 'FFFFFF' or '000000'))
		end

		doTweenX(tag..'ScaleX', tag..'.scale', layer == 1 and 0.7 or 0.65, 0.5 / fnfbeatsPlaybackRate(), 'bounceOut')
		doTweenY(tag..'ScaleY', tag..'.scale', layer == 1 and 0.7 or 0.65, 0.5 / fnfbeatsPlaybackRate(), 'bounceOut')
		if step > 1 then
			local targetX = step == 3 and 0 or screenWidth - getProperty(tag..'.width')
			doTweenX(tag..'X', tag, targetX, 0.5 / fnfbeatsPlaybackRate(), 'expoOut')
		end
	end
end

function removeFnfBeatsVs()
	fnfbeatsVsTrace('removeFnfBeatsVs called')
	for _, side in ipairs({'Right', 'Left', 'Central'}) do
		for layer = 1, 2 do
			local tag = 'fnfbeatsVS_'..side..layer
			if luaSpriteExists(tag) then
				fnfbeatsVsTrace('fading '..tag)
				doTweenAlpha(tag..'Bye', tag, 0, 0.25 / fnfbeatsPlaybackRate(), 'linear')
			else
				fnfbeatsVsTrace('sprite not found during cleanup: '..tag)
			end
		end
	end
end

function onTweenCompleted(tag)
	if stringStartsWith(tag, 'fnfbeatsVS_') and stringEndsWith(tag, 'Bye') then
		local sprite = string.gsub(tag, 'Bye$', '')
		fnfbeatsVsTrace('removing sprite after tween '..sprite)
		removeLuaSprite(sprite, true)
	end
end
