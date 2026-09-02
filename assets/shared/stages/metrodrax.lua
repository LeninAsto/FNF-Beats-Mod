function onCreate()

	makeLuaSprite('Fondo', 'metrodrax/fondo', -1800, -1000)
	addLuaSprite('Fondo', false)

	makeAnimatedLuaSprite('humo', 'metrodrax/humo', 270, -170)
	addAnimationByPrefix('humo', 'idle', 'humo', 20, true)
	objectPlayAnimation('humo', 'idle', true)
	addLuaSprite('humo', false)

	makeLuaSprite('puesto', 'metrodrax/puesto', -300, -250)
	addLuaSprite('puesto', false)

	makeAnimatedLuaSprite('monos', 'metrodrax/monos', -1750, -20)
	addAnimationByPrefix('monos', 'idle', 'idle', 24, false)
	objectPlayAnimation('monos', 'idle', true)
	addLuaSprite('monos', false)

	makeAnimatedLuaSprite('zaid', 'metrodrax/zaid', 1100, 150)
	addAnimationByPrefix('zaid', 'idle', 'idle', 24, false)
	objectPlayAnimation('zaid', 'idle', true)
	addLuaSprite('zaid', false)

	for i = 1,2 do

		makeAnimatedLuaSprite('bocina'..i, 'metrodrax/Bocinas', i == 1 and -80 or 550, i == 1 and 110 or 80)
		addAnimationByPrefix('bocina'..i, 'idle', 'bocina'..i, 0, false)
		objectPlayAnimation('bocina'..i, 'idle', true)
		addLuaSprite('bocina'..i, false)

		local tag = i == 1 and 'pelo' or 'noe'
		makeAnimatedLuaSprite(tag, 'metrodrax/noeconpelo', i == 1 and -1300 or 1000, 450)
		addAnimationByPrefix(tag, 'idle', tag, 24, false)
		objectPlayAnimation(tag, 'idle', true)
		addLuaSprite(tag, false)
		
		makeLuaSprite('luz'..i, 'metrodrax/luz', i == 1 and -1600 or 600, -1000)
		addLuaSprite('luz'..i, true)

		makeLuaSprite('aire'..i, 'metrodrax/aire'..i, -1800, -1000)
		addLuaSprite('aire'..i, true)

		makeLuaSprite('overlay'..i, 'metrodrax/light', i == 1 and -1860 or -1360, -530)
		addLuaSprite('overlay'..i, true)
		setProperty('overlay'..i..'.alpha', 0.5)
		scaleObject('overlay'..i, 1.5, 1.5)
		setBlendMode('overlay'..i, 'add')

	end

	setProperty('luz2.flipX', true)
	setProperty('overlay2.flipX', true)

	-- 🔥 MISMA CAPA ENTRE PELO Y NOE
	local layer = getObjectOrder('pelo')
	setObjectOrder('noe', layer)

	-- 🔥 PERO AMBOS DEBAJO DE LUCES
	setObjectOrder('pelo', getObjectOrder('luz1') - 1)
	setObjectOrder('noe', getObjectOrder('luz1') - 1)

	setObjectOrder('gfGroup', getObjectOrder('puesto'))

end

function onCountdownTick(t)
	if t % 2 == 0 then
		peopleDance()
		bocinasLight(1)
	else
		peopleDance()
		bocinasLight(2)
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then
		peopleDance()
		bocinasLight(1)
	else
		peopleDance()
		bocinasLight(2)
	end
end

function peopleDance()
	for _, objs in ipairs({'monos','zaid','pelo','noe'}) do
		objectPlayAnimation(objs, 'idle', true)
	end
end

function bocinasLight(i)
	setProperty('bocina'..i..'.animation.curAnim.curFrame',
		getRandomInt(
			0,
			getProperty('bocina'..i..'.animation.curAnim.numFrames')-1
		)
	)
end