function onCreate()
	--background shit
	makeLuaSprite('Cielo', 'Mercaditonial/Cielo', -1150, -1428)
	addLuaSprite('Cielo', false)
	setScrollFactor('Cielo', 0.1, 0.1)

	makeLuaSprite('Iglesia', 'Mercaditonial/Iglesia', -673, -1479)
	addLuaSprite('Iglesia', false)
	setScrollFactor('Iglesia', 0.3, 0.3)

	makeLuaSprite('CarpasLejanas', 'Mercaditonial/CarpasLejanas', 18, 230)
	addLuaSprite('CarpasLejanas', false)
	setScrollFactor('CarpasLejanas', 0.7, 0.7)

	makeLuaSprite('OtroArbol', 'Mercaditonial/OtroArbol', 1059, -338)
	addLuaSprite('OtroArbol', false)
	setScrollFactor('OtroArbol', 0.75, 0.75)

	makeLuaSprite('CarpaeTacos', 'Mercaditonial/CarpaeTacos', -1050, 85)
	addLuaSprite('CarpaeTacos', false)
	setScrollFactor('CarpaeTacos', 0.8, 0.8)

	for _, p in ipairs({'amarillos','azules','rojos','verdes'}) do
	makeAnimatedLuaSprite(p, 'Mercaditonial/publico', -200, 570)
	addAnimationByPrefix(p, 'idle', p, 24, false)
	setScrollFactor(p, 0.75, 1)
	addLuaSprite(p, false)
	end

	makeLuaSprite('Luces', 'Mercaditonial/Luces', -1028, -1077)
	addLuaSprite('Luces', false)
	setScrollFactor('Luces', 0.85, 0.85)

	makeLuaSprite('Arbol', 'Mercaditonial/Arbol', 1314, -927)
	addLuaSprite('Arbol', false)
	setScrollFactor('Arbol', 0.9, 0.9)

	makeLuaSprite('Tiendita', 'Mercaditonial/Tiendita', 687, -286)
	addLuaSprite('Tiendita', false)
	setScrollFactor('Tiendita', 0.95, 0.95)

	makeAnimatedLuaSprite('weyes', 'Mercaditonial/weyes', -400, 400)
	addAnimationByPrefix('weyes', 'idle', 'idle', 24, false)
	addLuaSprite('weyes', false)

	for _, w in pairs({'Gato','Vato'}) do
	makeAnimatedLuaSprite(w, 'Mercaditonial/ElgatoyelVato', 1400, 457)
	if w == 'Gato' then
	addAnimationByIndices(w, 'danceLeft', w, '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16', 60)
	addAnimationByIndices(w, 'danceRight', w, '17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33', 60)
	else addAnimationByPrefix(w, 'idle', w, 24, false) end
	addLuaSprite(w, false)
	end

	makeLuaSprite('Calle', 'Mercaditonial/Calle', -1330, 540)
	addLuaSprite('Calle', false)

	makeAnimatedLuaSprite('padre', 'Mercaditonial/padre', 900, 220)
	addAnimationByPrefix('padre', 'idle', 'idle', 24, false)
	addLuaSprite('padre', false)

	for c = 1,2 do
	local rightChar = c == 1
	makeAnimatedLuaSprite(c..'char', 'Mercaditonial/chars', rightChar and -1100 or 1500, rightChar and 550 or 700)
	addAnimationByPrefix(c..'char', 'idle', c..'char', 24, false)
	setScrollFactor(c..'char', 0.75, 1)
	addLuaSprite(c..'char', true)
	end
	
	makeLuaSprite('Luz', 'Mercaditonial/Luz', -1783, -850)
	addLuaSprite('Luz', true)
	setProperty('Luz.alpha', 0.5)
	setBlendMode('Luz', 'add')
end

function onCountdownTick(tick)
peopleDance(tick)
end

function onBeatHit()
peopleDance(curBeat)
end

function peopleDance(t)
local danceDir = (t % 2 == 0 and 'Left' or 'Right')
playAnim('Gato', 'dance'..danceDir)
for _,colors in pairs({'amarillos','azules','rojos','verdes'}) do playAnim(colors, 'idle', true) end
if t % 2 == 0 then else
for _, ppl in pairs({'Vato','padre','1char','2char','weyes'}) do playAnim(ppl, 'idle', true) end
end
end