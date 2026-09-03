local dir = 'Plazaid/'
local plazaidCarsDebug = false

function fnfbeatsStageRate()
	local rate = getProperty('playbackRate')
	if rate == nil or rate <= 0 then
		return 1
	end
	return rate
end

function onCreate()
luaDebugMode = true
--background shit
	makeLuaSprite('Cielo', dir..'Cielo', -1503, -1059)
	addLuaSprite('Cielo', false)
	setScrollFactor('Cielo', 0.1, 0.1)

	makeLuaSprite('Montanias', dir..'Montanias', -1133, -418)
	addLuaSprite('Montanias', false)
	setScrollFactor('Montanias', 0.4, 0.4)

	if not lowQuality then
		makeLuaSprite('Edificios', dir..'Edificios', -847, -634)
		addLuaSprite('Edificios', false)
		setScrollFactor('Edificios', 0.65, 0.65)
	
		makeLuaSprite('Palmeras', dir..'Palmeras', 1225, -882)
		addLuaSprite('Palmeras', false)
		setScrollFactor('Palmeras', 0.8, 0.8)
	end

	for i = 1,3 do
		local tag = i == 3 and 'camion' or 'carro'..i
		local y = i == 3 and -130 or -90
		makeAnimatedLuaSprite(tag, dir..'coches', -3000, y)
		addAnimationByPrefix(tag, 'idle', tag, 24, true)
		setScrollFactor(tag, 0.85, 0.85)
		setProperty(tag..'.flipX', true)
		addLuaSprite(tag, false)
	end
	
	addHaxeLibrary('ColorSwap', version == '0.6.3' and '' or 'shaders')
	runHaxeCode([[
		var swap = new ColorSwap();
		swap.hue = 0/360;
		swap.saturation = 0/100;
		swap.brightness = 0/100;
		setVar('swap', swap);
		game.getLuaObject("camion").shader = swap.shader;
		//game.getLuaObject("carro1").shader = swap.shader;
		//game.getLuaObject("carro2").shader = swap.shader;
	]])
	initLuaShader('blur')
	for a = 1,2 do
		local x = getRandomInt(-150, 1300)
		makeAnimatedLuaSprite('ave'..a, dir..'aves', x, 320)
		addAnimationByPrefix('ave'..a, 'fly', 'ave'..a, 24, true)
		addLuaSprite('ave'..a, false)
		playAnim('ave'..a, 'fly')
		setSpriteShader('ave'..a, 'blur')
		setShaderFloatArray('ave'..a, 'blurRadius', {0, 0})
	end
	if not lowQuality then
		for i = 1,4 do
		local otherPos = i == 4
		makeAnimatedLuaSprite('R'..i, dir..'randoms', otherPos and 800 or -200, otherPos and 400 or -150)
		addAnimationByPrefix('R'..i, 'idle', 'random'..i, 12, false)
		setScrollFactor('R'..i, 1, 1)
		if not otherPos then addLuaSprite('R'..i, false) end
		end
	end
	
	makeLuaSprite('Muro', dir..'Muro', -1299, -120)
	addLuaSprite('Muro', false)
	setScrollFactor('Muro', 1, 1)

	makeLuaSprite('Fuente', dir..'Fuente', 1217, 107)
	addLuaSprite('Fuente', false)
	setScrollFactor('Fuente', 1, 1)

	makeLuaSprite('Suelo', dir..'Suelo', -1087, 658)
	addLuaSprite('Suelo', false)
	setScrollFactor('Suelo', 1, 1)
	
	if not lowQuality then
		addLuaSprite('R4', false)
	
		makeAnimatedLuaSprite('sis', dir..'M', -350, 300)
		addAnimationByPrefix('sis', 'idle', 'hermanaM', 12, false)
		setScrollFactor('sis', 1, 1)
		addLuaSprite('sis', false)
	
		makeAnimatedLuaSprite('GenteWeona', dir..'kyq', -450, 270)
		addAnimationByIndices('GenteWeona', 'danceRight', 'idle', '13,14,0,1,2,3,4,5,6,7', 24)
		addAnimationByIndices('GenteWeona', 'danceLeft', 'idle', '8,9,10,11,12', 24)
		setScrollFactor('GenteWeona', 1, 1)
		addLuaSprite('GenteWeona', false)
	
		makeAnimatedLuaSprite('bloony', dir..'bloony', 1800, 250)
		addAnimationByIndices('bloony', 'idle', 'idle', '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14', 24)
		addAnimationByIndicesLoop('bloony', 'idle-loop', 'idle', '8,9,10,11', 24)
		setScrollFactor('bloony', 1, 1)
		addLuaSprite('bloony', false)
	
		makeAnimatedLuaSprite('momSL', dir..'momSL', -1200, 500)
		addAnimationByIndices('momSL', 'danceRight', 'idle', '6,7,8,9,10,11', 24)
		addAnimationByIndices('momSL', 'danceLeft', 'idle', '0,1,2,3,4,5', 20)
		setScrollFactor('momSL', 1, 1)
		addLuaSprite('momSL', true)
	
		makeAnimatedLuaSprite('lili', dir..'lili', 100, 700)
		addAnimationByIndices('lili', 'danceRight', 'idle', '0,1,2,3,4,5,6,7', 24)
		addAnimationByIndices('lili', 'danceLeft', 'idle', '8,9,10,11,12,13,14', 24)
		setScrollFactor('lili', 1, 1)
		addLuaSprite('lili', true)
	
		makeAnimatedLuaSprite('lala', dir..'lala', 1800, 500)
		addAnimationByIndices('lala', 'danceRight', 'idle', '6,7,8,9,10,11', 24)
		addAnimationByIndices('lala', 'danceLeft', 'idle', '0,1,2,3,4,5', 24)
		setScrollFactor('lala', 1, 1)
		addLuaSprite('lala', true)
	
		makeLuaSprite('luz', dir..'luz', -1300, -1000)
		addLuaSprite('luz', true)
		setScrollFactor('luz', 1, 1)
		setProperty('luz.alpha', 0.5)
		setBlendMode('luz', 'add')
	end
end

local coches = {
	['camion'] = {paso = true, puedePasar = false, vel = {300, 500}, hue = true, prob = 100, yPos = {-330, -30}, offScreen = false},
	['carro1'] = {paso = true, puedePasar = false, vel = {800, 2500}, hue = false, prob = 75, yPos = {-90, -10}, offScreen = false}, --75
	['carro2'] = {paso = true, puedePasar = false, vel = {800, 2500}, hue = false, prob = 50, yPos = {-90, -10}, offScreen = false}, --50
}

function arrancarCoche(coche)
	local c = coches[coche]
	if plazaidCarsDebug then debugPrint('THE ' .. coche:upper() .. ' HAS BEEN STARTED!!') end
	setProperty(coche .. '.flipX', not getProperty(coche .. '.flipX'))
	c.offScreen = false
	local speed = getRandomInt(c.vel[1], c.vel[2])
	local flipped = getProperty(coche .. '.flipX')
	local startX = flipped and 2999 or -2999
	local newY = getRandomInt(c.yPos[1], c.yPos[2])
	local velX = flipped and -speed or speed
	local newOrder = getRandomInt(4,6)

	setProperty(coche .. '.x', startX)
	setProperty(coche .. '.y', newY)
	--debugPrint(velX, ' -> ', velX * getProperty('playbackRate'))
	setProperty(coche .. '.velocity.x', velX * fnfbeatsStageRate())
	setObjectOrder(coche, newOrder)
	if plazaidCarsDebug then debugPrint(coche..' order is now '..newOrder) end

	local file = 'slowcar/CarPassing'..getRandomInt(1, 20)
	if velX > 900 then file = 'fastcar/CarPassBy'..getRandomInt(1, 13) end
	if coche == 'camion' then file = 'bus/BusPassing'..getRandomInt(1, 4) end
	playSound('traffic/'.. file, 0, coche)
	soundFadeIn(coche, 0.5 / fnfbeatsStageRate(), 0, 0.05)
	if version < '0.7.2h' then runHaxeCode('game.modchartSounds.get("'.. tostring(coche)..'").pitch = game.playbackRate;') else setSoundPitch(coche, fnfbeatsStageRate()) end --funfact: The set/getSoundPitch didn't exists until 0.7.2h
	if c.hue then
		setProperty(coche .. '.swap.hue', getRandomFloat(-100, 100)/360)
	end

	c.paso = true
end

function onPause()
	for coche, c in pairs(coches) do
		pauseSound(coche)
	end
end

function onResume()
	for coche, c in pairs(coches) do
		resumeSound(coche)
	end
end

local startled_birbs = {false, false}
local birbgoesfront = false
local whotbirb = 0

function onUpdate()
	local emptyHway = true
	for coche, c in pairs(coches) do
		if c.puedePasar then
			emptyHway = false
			break
		end
	end

	for a = 1, 2 do
		if getProperty('ave'..a..'.y') <= -847 then
			setProperty('ave'..a..'.velocity.x', 0)
			setProperty('ave'..a..'.velocity.y', 0)
		end
		if a ~= whotbirb then
			if emptyHway and startled_birbs[a] then
				local ranX = getRandomInt(-150, 1300)
				setProperty('ave'..a..'.velocity.x', 0)
				setProperty('ave'..a..'.velocity.y', 0)
				doTweenX('changeplace'..a, 'ave'..a, ranX, 2.5 / fnfbeatsStageRate(), 'quadOut')
				doTweenY('landback'..a, 'ave'..a, 320, 2.5 / fnfbeatsStageRate(), 'quadIn')
				startled_birbs[a] = false
			end
		end
	end

	if getAnim('bloony') == 'idle' and getAnim('bloony', 'finished') then
		playAnim('bloony', 'idle-loop', true)
	end

	for coche, c in pairs(coches) do
		local vel = getProperty(coche .. '.velocity.x')
		local pos = getProperty(coche .. '.x')
		local wid = getProperty(coche .. '.width')
		local flip = getProperty(coche .. '.flipX')
		local carFront = pos + wid

		for a = 1, 2 do
			if a ~= whotbirb and not startled_birbs[a] then
				local birx = getProperty('ave'..a..'.x')
				local birw = getProperty('ave'..a..'.width')
				local birFron = birx + birw
				local near = false
				
				if not flip then
					near = (carFront >= birx - 50 and pos <= birFron)
				else
					near = (pos <= birFron + 50 and carFront >= birx)
				end
			
				if near then
						cancelTween('changeplace'..a)
						cancelTween('landback'..a)
						setProperty('ave'..a..'.velocity.y', getRandomInt(-900, -1000) * fnfbeatsStageRate())
						setProperty('ave'..a..'.velocity.x', getRandomInt(-400, 400)  * fnfbeatsStageRate())
					if getRandomBool(5) and whotbirb == 0 and not birbgoesfront then
						birbgoesfront = true
						whotbirb = a
						runTimer('birbgoesfront', 15)
					end
						startled_birbs[a] = true
				end
			end
		end

		if not c.offScreen then
			local offL = (vel < 0 and pos <= -810)
			local offD = (vel >= 0 and pos >= 2000)
			if offL or offD then
				c.offScreen = true
				soundFadeOut(coche, 1 / fnfbeatsStageRate(), 0)
			end
		end

		if c.paso then
			local x = getProperty(coche .. '.x')
			if math.abs(x) >= 3000 then
				setProperty(coche .. '.velocity.x', 0)
				c.paso = false
				c.puedePasar = false
				local delay = getRandomFloat(1, lowQuality and 50 or 10)
				runTimer(coche .. 'Delay', delay / fnfbeatsStageRate())
			end
		end
	end
end

function onCountdownTick(tick)
	peopleDance(tick)
end

function onBeatHit()
	peopleDance(curBeat)
	for coche, c in pairs(coches) do
		if getRandomBool(c.prob) and not c.paso and c.puedePasar then
			arrancarCoche(coche)
		end
	end
end

function onTimerCompleted(tag)
	for nombre, c in pairs(coches) do
		if tag == nombre .. 'Delay' then
			c.puedePasar = true
		end
	end
	
	if tag == 'birbgoesfront' then
		local corn = {
				x = {-500, (screenWidth + 500)},
				y = {-400, (screenHeight + 400)}
			}
		local birb = 'ave'..whotbirb
		
		setProperty(birb..'.velocity.x', 0)
		setProperty(birb..'.velocity.y', 0)
		
		setShaderFloatArray(birb, 'blurRadius', {4.0, 4.0}) 
		setObjectCamera(birb, 'other')
		local ran = getRandomInt(1,2)
		local oppran = ran == 1 and 2 or 1
		setProperty(birb..'.x', corn.x[ran])
		setProperty(birb..'.y', corn.y[oppran])
		scaleObject(birb, 4, 4)
		doTweenX(birb..'X', birb, corn.x[oppran], getRandomFloat(0.8, 1.2) / fnfbeatsStageRate(), 'sineInOut')
		doTweenY(birb..'Y', birb, corn.y[ran], getRandomFloat(0.8, 1.2) / fnfbeatsStageRate(), 'sineInOut')
	end
end

function onTweenCompleted(tag)
	if whotbirb ~= 0 and (tag == 'ave'..whotbirb..'X' or tag == 'ave'..whotbirb..'Y') then
		local birb = 'ave'..whotbirb
		cancelTween('ave'..whotbirb..'X')
		cancelTween('ave'..whotbirb..'Y')
		
		setShaderFloatArray(birb, 'blurRadius', {0, 0})
		setObjectCamera(birb, 'game')
		scaleObject(birb, 1, 1)
		setProperty(birb..'.y', -847)
		whotbirb = 0
	end
end

function peopleDance(t)
	if lowQuality then return end 
	local danceDir = (t % 2 == 0 and 'Left' or 'Right')
	--debugPrint('dance'..danceDir)
	playAnim('GenteWeona', 'dance'..danceDir)
	for i = 1,4 do playAnim('R'..i, 'idle', true) end
	if t % 2 ~= 0 then playAnim('bloony', 'idle', true) end
	for _, ppl in pairs({'sis', 'momSL', 'lili', 'lala'}) do playAnim(ppl, 'dance'..danceDir) end
end

function getAnim(obj,prop)
	local prop = prop or 'name'
	return getProperty(obj .. '.animation.curAnim.' .. prop)	
end
