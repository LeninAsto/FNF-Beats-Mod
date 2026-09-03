local dir = 'Valle_amor/'

function fnfbeatsStageRate()
	local rate = getProperty('playbackRate')
	if rate == nil or rate <= 0 then
		return 1
	end
	return rate
end

function onCreate()
luaDebugMode = false
	makeLuaSprite('cielo', dir..'cielo', -1400, -1500)
	setScrollFactor('cielo', 0.2, 0.2)
	addLuaSprite('cielo', false)

	makeLuaSprite('montanias', dir..'montanias', -1000, -800)
	setScrollFactor('montanias', 0.4, 0.4)
	addLuaSprite('montanias', false)

	if not lowQuality then
		makeLuaSprite('estatua', dir..'estatua', -100, -1400)
		setScrollFactor('estatua', 0.6, 0.6)
		addLuaSprite('estatua', false)
	
		makeLuaSprite('postes', dir..'postes', -1300, -1000)
		setScrollFactor('postes', 0.7, 0.7)
		addLuaSprite('postes', false)
	
		for c = 1,2 do
			local car = 'car'..(c == 1 and 'fL' or 'fR')
			makeAnimatedLuaSprite(car, dir..'carros', 2460 * (c == 2 and 1 or -1), -486)
			for anim = 1,5 do addAnimationByPrefix(car, 'carro'..anim, 'carro'..anim, 24, true) end
			setScrollFactor(car, 0.75, 0.75)
			setProperty(car..'.flipX', c ==2)
			addLuaSprite(car, false)
			addHaxeLibrary('ColorSwap', version == '0.6.3' and '' or 'shaders')
			--actualizarVehiculo(car, c)
		end
	end
	
	makeLuaSprite('fondo', dir..'fondo', -2300, -1300)
	addLuaSprite('fondo', false)
	
	if not lowQuality then
		makeAnimatedLuaSprite('publico', dir..'public', -500, 50)
		addAnimationByPrefix('publico', 'idle', 'idle', 30, true)
		setScrollFactor('publico', 0.8, 0.8)
		addLuaSprite('publico', false)
		
		makeAnimatedLuaSprite('ggteam', dir..'ggteam', -800, 100)
		addAnimationByIndices('ggteam', 'danceLeft', 'idle', '0,1,2,3,4,5,6,7,8,9', 33)
		addAnimationByIndices('ggteam', 'danceRight', 'idle', '10,11,12,13,14,15,16,17,18,19', 33)
		addLuaSprite('ggteam', false)
		
		for r = 1, 6 do
			local pos = {{1300, 415}, {380, 475}, {-1400, 250}, {1400, 200}, {-900, 475}, {1000, 0}}
			local tag = r < 6 and 'r'..r or 'z1'
			makeAnimatedLuaSprite(tag, dir..'randoms', pos[r][1], pos[r][2])
			if r == 5 then
				addAnimationByIndices(tag, 'danceLeft', tag, '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14', 36)
				addAnimationByIndices(tag, 'danceRight', tag, '15,16,17,18,19,20,21,22,23,24,25,26,27,28,29', 36)
			else
				addAnimationByPrefix(tag, 'idle', tag, 24, true)
			end
			addLuaSprite(tag, (r == 1 or r == 2 or r == 5))
		end
		
		makeAnimatedLuaSprite('compu', dir..'compu', 50, 450)
		addAnimationByPrefix('compu', 'idle', 'compu', 24, false)
		addLuaSprite('compu', false)
		setObjectOrder('compu', getObjectOrder('dadGroup')-1)
	
		makeAnimatedLuaSprite('mom', dir..'mom', -1500, 375)
		addAnimationByIndices('mom', 'danceLeft', 'mom', '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14', 24)
		addAnimationByIndices('mom', 'danceRight', 'mom', '15,16,17,18,19,20,21,22,23,24,25,26,27,28,29', 24)
		addLuaSprite('mom', true)
	
		makeLuaSprite('aura', dir..'aura', -1800, -1000)
		setScrollFactor('aura', 0, 0)
		setBlendMode('aura', 'add')
		setProperty('aura.alpha', 0.5)
		addLuaSprite('aura', true)
	end
	precacheImage(dir..'botanica')
end

function onUpdate(elapsed)
	actualizarVehiculo('carfR', elapsed)
	actualizarVehiculo('carfL', elapsed)
end

local carrilY_inicio = -50
local carrilY_fin = 300
local x_recto_fin = -180
local x_total_fin = 2450
local x_inicio_carretera = -2450
local xSound = {-90, 1770}

local rango_curva = x_total_fin - x_recto_fin
local deltaY = carrilY_fin - carrilY_inicio
local carSpeeds = {} 

local angleB = 0
function actualizarVehiculo(tag, elapsed)
if lowQuality then return end
	local fR = stringEndsWith(tag, 'fR')
	local dir = fR and 1 or -1
	local carX = getProperty(tag..'.x')
	local carY = carrilY_inicio
	local anglers = {5, 5, 2.5, 0, 4.5}
	local curveMax = 10
	local angleXtra = 0

	if (fR and carX > x_total_fin) or (not fR and carX < x_inicio_carretera) then
		carX = fR and x_inicio_carretera or x_total_fin
		setProperty(tag..'.x', carX)
		local curCar = string.match(getProperty('carfR.animation.frameName'), "%d")
		local newCar = getRandomInt(0, 5, '0,'..tostring(curCar))
		playAnim(tag, 'carro'..newCar, true)
		angleB = anglers[newCar]
		setProperty(tag..'.origin.y', getProperty(tag..'.frameHeight'))
		setProperty(tag..'.origin.x', getProperty(tag..'.frameWidth') * 0.5)
		carSpeeds[tag] = {getRandomInt(400, 1600) * fnfbeatsStageRate(), 'carro'..newCar, false}
		setProperty(tag..'.velocity.x', carSpeeds[tag][1] * dir)
		runHaxeCode([[
			var swap = new ColorSwap();
			swap.hue = FlxG.random.float(-100,100) / 360;
			game.getLuaObject("]]..tag..[[").shader = swap.shader;
		]])
	end
	if (fR and carX >= xSound[1]) or (not fR and carX <= xSound[2]) then
		if not carSpeeds[tag][3] then
			carSound(carSpeeds[tag][2], carSpeeds[tag][1])
		end
	end

	if carX > x_recto_fin then
		local t = (carX - x_recto_fin) / rango_curva
		if t < 0 then t = 0 end
		if t > 1 then t = 1 end
		local smooth = t * t * (3 - 2 * t)
		carY = carrilY_inicio + deltaY * smooth
		angleXtra = (6 * t * (1 - t)) * curveMax
	end

	setProperty(tag..'.angle', (angleB * dir) + angleXtra)
	setProperty(tag..'.y', carY - getProperty(tag..'.frameHeight'))
end

function carSound(c, s)
	local longer = s > 900
	local bus = stringEndsWith(c, '5')
	local folder = bus and 'bus' or (longer and 'slowcar' or 'fastcar')
	local sound = ''
	if bus then
	    sound = 'BusPassing' .. getRandomInt(1,4)
	else
	    sound = longer and  'CarPassing' .. getRandomInt(1, 20) or 'CarPassBy' .. getRandomInt(1, 13)
	end
	local path = 'traffic/' .. folder .. '/' .. sound
	for cc = 1,5 do stopSound('carro'..cc) end
	playSound(path, 0.05, c)
	runTimer(c..'busisfade', 5)
	if version < '0.7.2h' then runHaxeCode('game.modchartSounds.get("'.. tostring(c)..'").pitch = game.playbackRate;') else setSoundPitch(c, fnfbeatsStageRate()) end --funfact: The set/getSoundPitch didn't exists until 0.7.2h
end

function onPause()
	for c = 1,5 do
		pauseSound('carro'..c)
	end
end

function onResume()
	for c = 1,5 do
		resumeSound('carro'..c)
	end
end

function goodNoteHit(i,d,t,s) if s then return end
	botanicalParticles()
end
function opponentNoteHit(i,d,t,s) if s then return end
	botanicalParticles()
end

function onCountdownTick(tick) dancer(tick) end
function onBeatHit() dancer(curBeat) end

function dancer(t)
if lowQuality then return end
	botanicalParticles('flor'); playAnim('compu', 'idle', true, t % 2 ~= 0);
	for _,s in ipairs({'r5','ggteam','mom'}) do
		playAnim(s, 'dance'..(t % 2 == 0 and 'Right' or 'Left'), true)
	end
end 

function onTimerCompleted(tag)
	if stringStartsWith(tag, 'botany') then
		doTweenAlpha(tag, tag, 0, 1, 'linear')
	end
	if stringEndsWith(tag, 'busisfade') then
		local gsubber = tag:gsub('busisfade', '')
		soundFadeOut(gsubber, 0.5 / fnfbeatsStageRate())
	end
end

local botanyC = 0
function botanicalParticles(b)
	botanyC = botanyC + 1
	if lowQuality and botanyC % 10 ~= 0 then return end
	local hf = b == nil and (getRandomBool(50) and 'hoja' or 'flor') or b
	local ran = hf == 'hoja' and 3 or 5
	local tag = 'botany'..botanyC
	makeAnimatedLuaSprite(tag, dir..'botanica', getRandomInt(-2000, 4000), -1200)
	addLuaSprite(tag, true)
	setObjectOrder(tag, getObjectOrder('boyfriendGroup')+1)
	addAnimationByPrefix(tag, 'idle', hf..getRandomInt(1, ran), 1, false)
	setScrollFactor(tag, 1, 1)
	local scale = getRandomFloat(0.4, 0.9)
	scaleObject(tag, scale, scale)
	setProperty(tag..'.alpha', 0.75)
	setProperty(tag..'.velocity.x', getRandomInt(-200, 200))
	setProperty(tag..'.velocity.y', getRandomInt(200, 400))
	setProperty(tag..'.angularVelocity', getRandomInt(-180, 180))
	doTweenX(tag..'sX', tag..'.scale', 0.1, 24, 'quadOut')
	doTweenY(tag..'sY', tag..'.scale', 0.1, 24, 'quadOut')
	runTimer(tag, 6)
end

function onTweenCompleted(tag)
	if stringStartsWith(tag, 'botany') then
		cancelTween(tag..'sX'); cancelTween(tag..'sY');
		removeLuaSprite(tag)
	end
end
