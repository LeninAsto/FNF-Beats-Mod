function onCreate()
	-- background
	makeLuaSprite('Fondo', 'Estadio/Fondo', -1201, -817)
	setScrollFactor('Fondo', 0.1, 1)
	addLuaSprite('Fondo', false)
	
	makeAnimatedLuaSprite('pantalla', 'estadio/pantalla', -250, -462)
	addAnimationByPrefix('pantalla', 'idle', 'pantalla', 24, false)
	setScrollFactor('pantalla', 0.7, 1)
	objectPlayAnimation('pantalla', 'idle', true)
	addLuaSprite('pantalla', false)

	for l = 1,2 do
		local colors = {red = '1,2,3,4,5,6,7,8', blue = '9,10,11,12,13,14,15,16'}
		makeAnimatedLuaSprite('luz'..l, 'estadio/luz', l == 2 and 1300 or -960, -300)
		addAnimationByIndices('luz'..l, 'dLeft', 'luz', l == 2 and colors.blue or colors.red, 24)
		addAnimationByIndices('luz'..l, 'dRight', 'luz', l == 1 and colors.blue or colors.red, 24)
		setScrollFactor('luz'..l, 0.8, 1)
		setProperty('luz'..l..'.flipX', l == 2)
		addLuaSprite('luz'..l, true)
	end

	makeAnimatedLuaSprite('bocina1', 'estadio/bocinas', 0, 15)
	addAnimationByPrefix('bocina1', 'idle', 'bocina1', 24, true)
	objectPlayAnimation('bocina1', 'idle', true)
	setScrollFactor('bocina1', 0.75, 1)
	addLuaSprite('bocina1', false)

	makeAnimatedLuaSprite('bocina2', 'estadio/bocinas', 1150, 15)
	addAnimationByPrefix('bocina2', 'idle', 'bocina2', 24, true)
	objectPlayAnimation('bocina2', 'idle', true)
	setScrollFactor('bocina2', 0.75, 1)
	addLuaSprite('bocina2', false)

	makeLuaSprite('LucesTraseras', 'Estadio/LucesTraseras', -872, 359)
	setScrollFactor('LucesTraseras', 0.75, 1)
	addLuaSprite('LucesTraseras', false)

	for p = 1,2 do
		makeAnimatedLuaSprite('pixeles'..p, 'estadio/pixeles', p == 2 and 1543 or -693, -220)
		addAnimationByPrefix('pixeles'..p, 'idle', 'pixeles', 6, true)
		objectPlayAnimation('pixeles'..p, 'idle', true)
		setScrollFactor('pixeles'..p, 0.75, 1)
		setProperty('pixeles'..p..'.flipX', p == 2)
		addLuaSprite('pixeles'..p, false)
	end

	makeLuaSprite('Bombilla', 'Estadio/Bombilla', -489, -1390)
	setScrollFactor('Bombilla', 0.5, 1)
	addLuaSprite('Bombilla', false)

	makeLuaSprite('Tarima', 'Estadio/Tarima', -1253, 697)
	addLuaSprite('Tarima', false)

	makeAnimatedLuaSprite('g1', 'estadio/r1', 100, 45)
	addAnimationByPrefix('g1', 'idle', 'weyes', 24, true)
	objectPlayAnimation('g1', 'idle', true)
	setScrollFactor('g1', 0.75, 1)
	addLuaSprite('g1', false)

	makeAnimatedLuaSprite('gente', 'estadio/gente', -1400, 463)
	addAnimationByPrefix('gente', 'idle', 'gente', 24, true)
	objectPlayAnimation('gente', 'idle', true)
	setScrollFactor('gente', 0.75, 1)
	addLuaSprite('gente', true)

	makeLuaSprite('LuzCentral', 'Estadio/LuzCentral', -572, -964)
	setProperty('LuzCentral.alpha', 0.34)
	setBlendMode('LuzCentral', 'add')
	setScrollFactor('LuzCentral', 0.55, 1)
	addLuaSprite('LuzCentral', true)
end

function onBeatHit()
	for l = 1,2 do
		objectPlayAnimation('luz'..l, curBeat % 2 == 0 and 'dLeft' or 'dRight', true)
	end

	if curBeat % 2 ~= 0 then
		objectPlayAnimation('pantalla', 'idle', true)
	end
end