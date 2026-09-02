function onCreate()

	makeLuaSprite('Fondo', 'metrodrax/fondo1', -1800, -1000)
	addLuaSprite('Fondo', false)

	makeLuaSprite('puesto', 'metrodrax/puesto1', -300, -250)
	addLuaSprite('puesto', false)

	for i = 1,2 do
		makeAnimatedLuaSprite('bocina'..i, 'metrodrax/Bocinas', i == 1 and -80 or 550, i == 1 and 110 or 80)
		addAnimationByPrefix('bocina'..i, 'idle', 'bocina'..i, 0, false)
		objectPlayAnimation('bocina'..i, 'idle', true)
		addLuaSprite('bocina'..i, false)

		makeLuaSprite('luz'..i, 'metrodrax/luz', i == 1 and -1600 or 600, -1000)
		addLuaSprite('luz'..i, false)

		makeLuaSprite('overlay'..i, 'metrodrax/light', i == 1 and -1860 or -1360, -530)
		addLuaSprite('overlay'..i, true)
		setProperty('overlay'..i..'.alpha', 0.5)
		scaleObject('overlay'..i, 1.5, 1.5)
		setBlendMode('overlay'..i, 'add')
	end

	setProperty('luz2.flipX', true)
	setProperty('overlay2.flipX', true)

	setObjectOrder('gfGroup', getObjectOrder('puesto'))

end

function onUpdate(elapsed)
	cameraShake('camGame', 0.0015, 0.05)
	cameraShake('camHUD', 0.0008, 0.05)
end

function onCountdownTick(t)
	if t % 2 == 0 then
		bocinasLight(1)
	else
		bocinasLight(2)
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then
		bocinasLight(1)
	else
		bocinasLight(2)
	end
end

function bocinasLight(i)
	setProperty('bocina'..i..'.animation.curAnim.curFrame',
		getRandomInt(
			0,
			getProperty('bocina'..i..'.animation.curAnim.numFrames') - 1
		)
	)
end