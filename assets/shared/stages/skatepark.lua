local dir = 'skatepark/'

function fnfbeatsStageRate()
	local rate = getProperty('playbackRate')
	if rate == nil or rate <= 0 then
		return 1
	end
	return rate
end

function onCreate()
	makeLuaSprite('cielo', dir..'cielo', -2300, -1600)
	addLuaSprite('cielo', false)
	setScrollFactor('cielo', 0.1, 0.1)

	makeLuaSprite('edificios', dir..'edificios', -2300, -1200)
	addLuaSprite('edificios', false)
	setScrollFactor('edificios', 0.45, 0.45)
	
	if not lowQuality then
		for e = 2,1,-1 do
		makeLuaSprite('estructura'..e, dir..'estructura'..e, -2300, -1200)
		addLuaSprite('estructura'..e, false)
		end
		
		makeLuaSprite('arboles', dir..'arboles', -2300, -1100)
		addLuaSprite('arboles', false)
	end
	
	makeLuaSprite('postes', dir..'posted', -2300, -1400)
	addLuaSprite('postes', false)
	
	if not lowQuality then
		for r = 1, 4 do
			local x = {-1350, -1250, -1340, -1020}
			makeAnimatedLuaSprite('r'..r, dir..'randoms', x[r], (r == 1 and -500 or -430))
			addAnimationByPrefix('r'..r, 'idle', 'r'..r, 24, r < 3)
			addLuaSprite('r'..r, false)
		end
	end
	
	makeLuaSprite('fondo', dir..'fondo', -2300, -500)
	addLuaSprite('fondo', false)
	
	if not lowQuality then
		for ck = 4, 1, -1 do
			makeAnimatedLuaSprite('chakal'..ck, dir..'chakales', (ck > 2 and 850 or -1400), (ck > 2 and -400 or 300))
			addAnimationByPrefix('chakal'..ck, 'idle', 'chakal'..ck, 24, false)
			addLuaSprite('chakal'..ck, ck < 3)
		end
	
		makeLuaSprite('aura', dir..'aura', -2300, -1000)
		setBlendMode('aura', 'add')
		setProperty('aura.alpha', 0.5)
		addLuaSprite('aura', true)
	end
	makeLuaSprite('skate', dir..'skate', -800, 440)
	addLuaSprite('skate', false)
	startTraffic()
end

function onCountdownTick(tick) peopleDance(tick) end
function onBeatHit() peopleDance(curBeat) end

function peopleDance(t)
	if lowQuality then return end 
	if t % 2 == 0 then
		for i = 1,4 do
			playAnim('chakal'..i, 'idle', true)
			if i > 2 then playAnim('r'..i, 'idle', true) end
		end
	end
end

--The commented code didn't turn out as expected, but it's good enough not to delete it
local traffic = {}
function startTraffic()
	local vehicleAmount = lowQuality and 10 or 20
	local d = 0
	--local zL, zR = 0, 0
	for v = 1, vehicleAmount do
		local ran = getRandomInt(1, 6)
		local cm = ((ran - 1) % 4) + 1
		local vehicle = ran < 5 and 'carro' or 'moto'
		local startLeft = getRandomBool(50)
		makeAnimatedLuaSprite(vehicle..v, dir..'vehiculos', (startLeft and (-3000 + d) or (3000 - d)), 0)
		addAnimationByPrefix(vehicle..v, 'idle', vehicle..cm, 24, true)
		--local w = getProperty(vehicle..v..'.frameWidth')
		--if startLeft then
			--setProperty(vehicle..v..'.x', -3000 - zL - w)
			--zL = zL + w + 100
		--else
			--setProperty(vehicle..v..'.x', 3000 + zR)
			--zR = zR + w + 100
		--end
		addLuaSprite(vehicle..v, false)
		setObjectOrder(vehicle..v, getObjectOrder(not lowQuality and 'estructura1' or 'fondo')-1)
		setProperty(vehicle..v..'.y', getProperty(vehicle..v..'.y') - getProperty(vehicle..v..'.frameHeight'))
		traffic[vehicle..v] = {s = false}--, dist = math.abs(getProperty(vehicle..v..'.x'))}
		restartVehicle(vehicle..v, not startLeft)
		d = d + 200
	end
end

function restartVehicle(v, f)
	local finalx = getProperty(v..'.x')
	setProperty(v..'.x', getProperty(v..'.x') + (finalx < 0 and 200 or -200))
	setProperty(v..'.flipX', f)
	traffic[v].s = false
	local vel = getRandomInt(1250, 1750) * fnfbeatsStageRate() --(traffic[v].dist * 2) / 6
	setProperty(v..'.velocity.x', f and -vel or vel)
	addHaxeLibrary('ColorSwap', version == '0.6.3' and '' or 'shaders')
	runHaxeCode([[
		var swap = new ColorSwap();
		swap.hue = FlxG.random.float(-100,100) / 360;
		game.getLuaObject("]]..v..[[").shader = swap.shader;
	]])
	--debugPrint(curStep,'_',v)
end

function onUpdate()
	for v,d in pairs(traffic) do
		local x = math.abs(getProperty(v..'.x'))
		if x >= 3000 then--p.dist then
			restartVehicle(v, not getProperty(v..'.flipX'))
		end
		if x <= 1600 and not d.s then
			traffic[v].s = true
			trafficSound(v)
		end
	end
end

function trafficSound(v)
	local longer = getRandomBool(40)
	local moto = stringStartsWith(v, 'moto')
	local folder = moto and 'motorcycle' or (longer and 'slowcar' or 'fastcar')
	local sound = ''
	if moto then
	    sound = 'MotorcycleFlyBy' .. getRandomInt(1, 4)
	else
	    sound = longer and  'CarPassing' .. getRandomInt(1, 20) or 'CarPassBy' .. getRandomInt(1, 13)
	end
	if stringStartsWith(getProperty(v..'.animation.frameName'), 'carro3') then
		folder, sound = 'bus', 'BusPassing'..getRandomInt(1,4)
		runTimer(v..'busfade', 5)
	end
	local path = 'traffic/' .. folder .. '/' .. sound
	playSound(path, 0.05, v)
	if version < '0.7.2h' then runHaxeCode('game.modchartSounds.get("'.. tostring(v)..'").pitch = game.playbackRate;') else setSoundPitch(v, fnfbeatsStageRate()) end --funfact: The set/getSoundPitch didn't exists until 0.7.2h
end

function onTimerCompleted(t)
	if stringEndsWith(t, 'busfade') then
		local gsubber = t:gsub('busfade', '')
		soundFadeOut(gsubber, 0.5 / fnfbeatsStageRate())
	end
end

function onPause()
	for v,d in pairs(traffic) do
		pauseSound(v)
	end
end

function onResume()
	for v,d in pairs(traffic) do
		resumeSound(v)
	end
end
