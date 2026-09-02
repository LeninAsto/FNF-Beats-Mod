function onCreate()
	-- background shit
	makeLuaSprite('subway', 'metro/subway-abandoned', -900, -670);
	setScrollFactor('subway', 0.9, 0.9);
	addLuaSprite('subway', false);

	makeLuaSprite('tren', 'metro/tren', -900, -180);
	setScrollFactor('tren', 0.9, 0.9);
	addLuaSprite('tren', false);

	makeLuaSprite('piso', 'metro/piso', -900, 480);
	setScrollFactor('piso', 1, 1);
	addLuaSprite('piso', false);

	for i = 1,2 do
		local lado = i == 2 and 'Der' or 'Izq'
		makeAnimatedLuaSprite('chars'..i, 'metro/chars', i == 2 and 1200 or -700, 190);
		addAnimationByPrefix('chars'..i, 'idle', 'chars'..i, 24, false);
		setScrollFactor ('chars'..i, 1, 1);
		addLuaSprite('chars'..i, false);
		makeAnimatedLuaSprite('boys'..i, 'metro/boys', -900, 545);
		addAnimationByPrefix('boys'..i, 'idle', 'cholos'..lado, 24, false);
		setScrollFactor ('boys'..i, 1, 1);
		addLuaSprite('boys'..i, false);
	end

	makeLuaSprite('luces', 'metro/iluminacion', -900, -400);
	setScrollFactor('luces', 0.9, 0.9);
	addLuaSprite('luces', true);
end

function onCountdownTick(t)
	if t % 2 == 0 then peopleDance() end
end

function onBeatHit()
	if curBeat % 2 == 0 then peopleDance() end
end

function peopleDance()
	for i = 1,2 do
	playAnim('chars'..i, 'idle')
	playAnim('boys'..i, 'idle')
	end
end