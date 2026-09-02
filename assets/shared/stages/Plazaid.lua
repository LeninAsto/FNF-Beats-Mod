local plazaidCarsDebug = false

function onCreate()
luaDebugMode = true
--background shit
	makeLuaSprite('Cielo', 'Plazaid/Cielo', -1503, -1059)
	addLuaSprite('Cielo', false)
	setScrollFactor('Cielo', 0.1, 0.1)

	makeLuaSprite('Montanias', 'Plazaid/Montanias', -1133, -418)
	addLuaSprite('Montanias', false)
	setScrollFactor('Montanias', 0.2, 0.2)

	makeLuaSprite('Edificios', 'Plazaid/Edificios', -847, -634)
	addLuaSprite('Edificios', false)
	setScrollFactor('Edificios', 0.4, 0.4)

	makeLuaSprite('Palmeras', 'Plazaid/Palmeras', 1225, -882)
	addLuaSprite('Palmeras', false)
	setScrollFactor('Palmeras', 0.4, 0.4)
	
	for i = 1,3 do
	local tag = i == 3 and 'camion' or 'carro'..i
	local y = i == 3 and -130 or -90
	makeAnimatedLuaSprite(tag, 'Plazaid/coches', -3000, y)
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

	makeAnimatedLuaSprite('aves', 'Plazaid/aves', 1455, -40)
	addAnimationByPrefix('aves', 'fly', 'aves', 24, true)
	addLuaSprite('aves', false)
	playAnim('aves', 'fly')
	doTweenX('avesX', 'aves', -40, 5, 'linear')
	doTweenY('avesY', 'aves', -1445, 5, 'linear')

	for i = 1,4 do --crear todos los randoms aqui
	local otherPos = i == 4 --para posicionar los de abajo
	makeAnimatedLuaSprite('R'..i, 'Plazaid/randoms', otherPos and 800 or -200, otherPos and 400 or -150)
	addAnimationByPrefix('R'..i, 'idle', 'random'..i, 12, false)
	setScrollFactor('R'..i, 1, 1)
	if not otherPos then addLuaSprite('R'..i, false) end --añadir solo los de arriba
	end

	makeLuaSprite('Muro', 'Plazaid/Muro', -1299, -120)
	addLuaSprite('Muro', false)
	setScrollFactor('Muro', 1, 1)

	makeLuaSprite('Fuente', 'Plazaid/Fuente', 1217, 107)
	addLuaSprite('Fuente', false)
	setScrollFactor('Fuente', 1, 1)

	makeLuaSprite('Suelo', 'Plazaid/Suelo', -1087, 658)
	addLuaSprite('Suelo', false)
	setScrollFactor('Suelo', 1, 1)

	addLuaSprite('R4', false) --añadir los randoms de abajo

	makeAnimatedLuaSprite('sis', 'Plazaid/M', -350, 300)
	addAnimationByPrefix('sis', 'idle', 'hermanaM', 12, false)
	setScrollFactor('sis', 1, 1)
	addLuaSprite('sis', false)

	makeAnimatedLuaSprite('Esa gente', 'Plazaid/kyq', -450, 270)
	addAnimationByIndices('Esa gente', 'danceRight', 'idle', '13,14,0,1,2,3,4,5,6,7', 24)
	addAnimationByIndices('Esa gente', 'danceLeft', 'idle', '8,9,10,11,12', 24)
	setScrollFactor('Esa gente', 1, 1)
	addLuaSprite('Esa gente', false)

	makeAnimatedLuaSprite('bloony', 'Plazaid/bloony', 1800, 250)
	addAnimationByIndices('bloony', 'idle', 'idle', '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14', 24)
	addAnimationByIndicesLoop('bloony', 'idle-loop', 'idle', '8,9,10,11', 24)
	setScrollFactor('bloony', 1, 1)
	addLuaSprite('bloony', false)

	makeAnimatedLuaSprite('momSL', 'Plazaid/momSL', -1200, 500)
	addAnimationByIndices('momSL', 'danceRight', 'idle', '6,7,8,9,10,11', 24)
	addAnimationByIndices('momSL', 'danceLeft', 'idle', '0,1,2,3,4,5', 20)
	setScrollFactor('momSL', 1, 1)
	addLuaSprite('momSL', true)

	makeAnimatedLuaSprite('lili', 'Plazaid/lili', 100, 700)
	addAnimationByIndices('lili', 'danceRight', 'idle', '0,1,2,3,4,5,6,7', 24)
	addAnimationByIndices('lili', 'danceLeft', 'idle', '8,9,10,11,12,13,14', 24)
	setScrollFactor('lili', 1, 1)
	addLuaSprite('lili', true)

	makeAnimatedLuaSprite('lala', 'Plazaid/lala', 1800, 500)
	addAnimationByIndices('lala', 'danceRight', 'idle', '6,7,8,9,10,11', 24)
	addAnimationByIndices('lala', 'danceLeft', 'idle', '0,1,2,3,4,5', 24)
	setScrollFactor('lala', 1, 1)
	addLuaSprite('lala', true)

	makeLuaSprite('luz', 'Plazaid/luz', -1300, -1000)
	addLuaSprite('luz', true)
	setScrollFactor('luz', 1, 1)
	setProperty('luz.alpha', 0.5)
	setBlendMode('luz', 'add')
end

local coches = {
	['camion'] = {paso = true, puedePasar = false, vel = {20,30}, hue = true, prob = 100, yPos = {-330, -30}},
	['carro1'] = {paso = true, puedePasar = false, vel = {22,170}, hue = false, prob = 75, yPos = {-90, -10}},
	['carro2'] = {paso = true, puedePasar = false, vel = {22,170}, hue = false, prob = 50, yPos = {-90, -10}},
}

function arrancarCoche(coche)
	local c = coches[coche]
	if plazaidCarsDebug then debugPrint('THE ' .. coche:upper() .. ' HAS BEEN STARTED!!') end

	playSound('carPass' .. getRandomInt(0, 1), 0.7, 'hi')
	setProperty(coche .. '.flipX', not getProperty(coche .. '.flipX'))

	local speed = getRandomInt(c.vel[1], c.vel[2]) / (getPropertyFromClass('flixel.FlxG', 'elapsed') * 3)
	local flipped = getProperty(coche .. '.flipX')
	local startX = flipped and 2999 or -2999
	local newY = getRandomInt(c.yPos[1], c.yPos[2])
	local velX = flipped and -speed or speed
	local newOrder = getRandomInt(3,7,'3,7') --only 4,5,6

	setProperty(coche .. '.x', startX)
	setProperty(coche .. '.y', newY)
	setProperty(coche .. '.velocity.x', velX)
	setObjectOrder(coche, newOrder)
	if plazaidCarsDebug then debugPrint(coche..' order is now '..newOrder) end

	if c.hue then
		setProperty(coche .. '.swap.hue', getRandomFloat(-100, 100)/360)
	end

	c.paso = true
end

function onUpdate()
	if getAnim('bloony') == 'idle' and getAnim('bloony', 'finished') then
		playAnim('bloony', 'idle-loop', true)
	end

	for coche, c in pairs(coches) do
		if c.paso then
			local x = getProperty(coche .. '.x')
			if math.abs(x) >= 3000 then
				setProperty(coche .. '.velocity.x', 0)
				c.paso = false
				c.puedePasar = false
				if plazaidCarsDebug then debugPrint('STOP THE ' .. coche:upper() .. '!!') end

				local delay = getRandomFloat(1, 50)
				runTimer(coche .. 'Delay', delay)
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
end

function peopleDance(t)
local danceDir = (t % 2 == 0 and 'Left' or 'Right')
--debugPrint('dance'..danceDir)
playAnim('Esa gente', 'dance'..danceDir)
for i = 1,4 do playAnim('R'..i, 'idle', true) end
if t % 2 == 0 then else playAnim('bloony', 'idle', true) end
for _, ppl in pairs({'sis', 'momSL', 'lili', 'lala'}) do playAnim(ppl, 'dance'..danceDir) end
end

function getAnim(obj,prop)
	local prop = prop or 'name'
	return getProperty(obj .. '.animation.curAnim.' .. prop)	
end