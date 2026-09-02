function onCreate()

	makeLuaSprite('cielo', 'skatepark/cielo', -2300, -1600)
	addLuaSprite('cielo', false)

	makeLuaSprite('edificios', 'skatepark/edificios', -2300, -1200)
	addLuaSprite('edificios', false)

	makeLuaSprite('estructura2', 'skatepark/estructura2', -2300, -1200)
	addLuaSprite('estructura2', false)

	makeLuaSprite('estructura1', 'skatepark/estructura1', -2300, -1200)
	addLuaSprite('estructura1', false)

	makeLuaSprite('arboles', 'skatepark/arboles', -2300, -1100)
	addLuaSprite('arboles', false)

	makeLuaSprite('postes', 'skatepark/postes', -2300, -1400)
	addLuaSprite('postes', false)

	makeAnimatedLuaSprite('r1', 'skatepark/r1', -1350, -500)
	addAnimationByPrefix('r1', 'idle', 'r1', 24, true)
	objectPlayAnimation('r1', 'idle', true)
	addLuaSprite('r1', false)

	makeAnimatedLuaSprite('randoms', 'skatepark/randoms', -1650, -430)
	addAnimationByPrefix('randoms', 'idle', 'randoms', 24, true)
	objectPlayAnimation('randoms', 'idle', true)
	addLuaSprite('randoms', false)

	makeLuaSprite('fondo', 'skatepark/fondo', -2300, -500)
	addLuaSprite('fondo', false)

	makeAnimatedLuaSprite('chakales2', 'skatepark/chakales2', 850, -400)
	addAnimationByPrefix('chakales2', 'idle', 'chakales2', 24, true)
	objectPlayAnimation('chakales2', 'idle', true)
	addLuaSprite('chakales2', false)

	makeAnimatedLuaSprite('chakales1', 'skatepark/chakales1', -1400, 300)
	addAnimationByPrefix('chakales1', 'idle', 'chakales1', 24, true)
	objectPlayAnimation('chakales1', 'idle', true)
	addLuaSprite('chakales1', true)

	makeLuaSprite('aura', 'skatepark/aura', -2300, -1000)
	setBlendMode('aura', 'add')
	setProperty('aura.alpha', 0.5)
	addLuaSprite('aura', true)

	precacheImage('skatepark/cars')

	cars = {}
	carTimer = 0

	carGroundY = getProperty('randoms.y') + 450
	carYOffset = 0

	carTypes = {
		'carro1','carro2','carro3','carro4','moto1','moto2'
	}
end

function getCarName(id)
	return carTypes[id + 1]
end

function spawnCar()

	local id = math.random(0, 5)
	local tag = 'car_' .. getRandomInt(0, 999999)

	makeAnimatedLuaSprite(tag, 'skatepark/cars', 0, 0)
	addAnimationByPrefix(tag, 'idle', getCarName(id), 24, true)
	objectPlayAnimation(tag, 'idle', true)

	addLuaSprite(tag, false)

	setObjectOrder(tag, getObjectOrder('estructura1') - 1)

	setProperty(tag .. '.y', carGroundY - getProperty(tag .. '.frameHeight') + carYOffset)

	local speed = 12 + math.random() * 6

	if math.random(0, 1) == 1 then
		setProperty(tag .. '.flipX', true)
		setProperty(tag .. '.x', 2000)
		speed = -speed
	else
		setProperty(tag .. '.flipX', false)
		setProperty(tag .. '.x', -3000)
	end

	table.insert(cars, {tag = tag, speed = speed})
end

function onUpdate(elapsed)

	carTimer = carTimer + elapsed

	if carTimer > 1.2 then
		spawnCar()
		carTimer = 0
	end

	for i = #cars, 1, -1 do
		local c = cars[i]

		local x = getProperty(c.tag .. '.x')
		setProperty(c.tag .. '.x', x + c.speed)

		if x < -3500 or x > 3500 then
			removeLuaSprite(c.tag, true)
			table.remove(cars, i)
		end
	end
end