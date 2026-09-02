local manchasContador = 0

function onCreate()
	makeLuaSprite('cielo', 'BSFR_arena/cielo', 0, 0)
	addLuaSprite('cielo', false)

	makeLuaSprite('edificios', 'BSFR_arena/edificios', 500, 500)
	addLuaSprite('edificios', false)

	makeAnimatedLuaSprite('entrada', 'BSFR_arena/entrada_poste', 20, 410)
	addAnimationByPrefix('entrada', 'idle', 'idle', 24, true)
	addLuaSprite('entrada', false)

	makeAnimatedLuaSprite('poste', 'BSFR_arena/entrada_poste', 20, 410)
	addAnimationByPrefix('poste', 'idle', 'idle', 24, true)
	addLuaSprite('poste', false)

	for i = 1, 4 do
		makeAnimatedLuaSprite('carro'..i, 'BSFR_arena/carros', 20, 410)
		addAnimationByPrefix('carro'..i, 'idle', 'idle', 24, true)
		addLuaSprite('carro'..i, false)
	end

	makeAnimatedLuaSprite('publico1', 'BSFR_arena/publico1', 700, 1400)
	addAnimationByPrefix('publico1', 'publico1', 'publico1', 24, true)
	addLuaSprite('publico1', false)

	makeAnimatedLuaSprite('jeffu', 'BSFR_arena/jeffu', 1500, 1150)
	addAnimationByPrefix('jeffu', 'idle', 'idle', 24, true)
	addLuaSprite('jeffu', false)

	makeLuaSprite('fondo', 'BSFR_arena/fondo', 20, 410)
	addLuaSprite('fondo', false)

	makeAnimatedLuaSprite('random2', 'BSFR_arena/random2', -100, 1500)
	addAnimationByPrefix('random2', 'idle', 'idle', 24, true)
	addLuaSprite('random2', false)

	makeAnimatedLuaSprite('random1', 'BSFR_arena/random1', 0, 1800)
	addAnimationByPrefix('random1', 'idle', 'idle', 24, true)
	addLuaSprite('random1', false)

	makeAnimatedLuaSprite('random3', 'BSFR_arena/random3', 200, 1700)
	addAnimationByPrefix('random3', 'idle', 'idle', 18, true)
	addLuaSprite('random3', false)

	makeAnimatedLuaSprite('JRB', 'BSFR_arena/JRB', 800, 1700)
	addAnimationByPrefix('JRB', 'idle', 'idle', 20, true)
	addLuaSprite('JRB', false)

	makeAnimatedLuaSprite('bofes1', 'BSFR_arena/bofes1', 1400, 1500)
	addAnimationByPrefix('bofes1', 'idle', 'idle', 18, true)
	addLuaSprite('bofes1', false)

	makeAnimatedLuaSprite('diego', 'BSFR_arena/diego', 500, 2100)
	addAnimationByPrefix('diego', 'idle', 'idle', 18, true)
	addLuaSprite('diego', false)

	makeAnimatedLuaSprite('gadi', 'BSFR_arena/gadi', 3000, 1800)
	addAnimationByPrefix('gadi', 'idle', 'idle', 24, true)
	addLuaSprite('gadi', false)

	makeLuaSprite('refri', 'BSFR_arena/refri', 2800, 2400)
	addLuaSprite('refri', false)

	makeLuaSprite('luces', 'BSFR_arena/luces', 1200, 450)
	setBlendMode('luces', 'add')
	addLuaSprite('luces', true)

	makeLuaSprite('aura', 'BSFR_arena/aura', 0, 200)
	setBlendMode('aura', 'add')
	addLuaSprite('aura', true)
	
	makeLuaSprite('niebla', 'BSFR_arena/niebla_lol', 450, 1000)
	setScrollFactor('niebla', 1.5, 0.5)
	scaleObject('niebla', 1.5, 1)
	addLuaSprite('niebla', true)

	precacheImage('BSFR_arena/manchas')
end

function onCreatePost()
	local sprites = {'entrada','poste','random2','random1','random3','JRB','bofes1'}
	for i = 1, 4 do
		table.insert(sprites, 'carro'..i)
	end

	for _, spr in ipairs(sprites) do
		objectPlayAnimation(spr, 'idle', true)
	end
end

function goodNoteHit(i,d,t,s)
	if s then return end
	hacerManchas(true)
end

function opponentNoteHit(i,d,t,s)
	if s then return end
	hacerManchas(false)
end

function hacerManchas(playerHit)
	manchasContador = manchasContador + 1

	local tag = 'mancha'..manchasContador
	makeAnimatedLuaSprite(tag, 'BSFR_arena/manchas', playerHit and 1333 or 2222, 464)
	addAnimationByPrefix(tag, 'idle', 'mancha_'..getRandomInt(1,4), 1, false)

	setGraphicSize(tag, getProperty(tag..'.width') * 0.4)
	addLuaSprite(tag, true)
	setObjectOrder(tag, getObjectOrder('niebla') - 1)

	objectPlayAnimation(tag, 'idle', false)

	local elapsed = getPropertyFromClass('flixel.FlxG', 'elapsed')
	local velocity = getRandomInt(20, 30) / (elapsed * 3)

	setProperty(tag..'.velocity.x', playerHit and velocity or -velocity)
	setProperty(tag..'.velocity.y', velocity)
	setProperty(tag..'.angularVelocity', getRandomInt(-15, 15) / (elapsed * 3))

	addHaxeLibrary('ColorSwap', version == '0.6.3' and '' or 'shaders')

	runHaxeCode([[
		var swap = new ColorSwap();
		game.getLuaObject("]]..tag..[[").shader = swap.shader;
		game.getLuaObject("]]..tag..[[").setVar("swap", swap);
	]])

	setProperty(tag..'.swap.hue', getRandomFloat(-100, 100)/360)

	runTimer(tag, 20)
end

function onTimerCompleted(tag)
	if string.sub(tag,1,6) == 'mancha' then
		doTweenAlpha(tag, tag, 0, 1)
	end
end

function onTweenCompleted(tag)
	if string.sub(tag,1,6) == 'mancha' then
		removeLuaSprite(tag, true)
	end
end