function onCreate()

	if curStage ~= 'skatepark' and curStage ~= 'BSFR_arena' then
		return
	end

	rainDrops = {}

	for i = 1, 120 do
		local tag = 'rainDrop'..i

		makeLuaSprite(tag, '', 0, 0)
		makeGraphic(tag, 3, math.random(35, 60), 'FFFFFF')

		setProperty(tag..'.alpha', 0.08)

		setObjectCamera(tag, 'camOther')
		setBlendMode(tag, 'add')

		setProperty(tag..'.angle', 35)

		setProperty(tag..'.x', math.random(-300, 1600))
		setProperty(tag..'.y', math.random(-800, 800))

		addLuaSprite(tag, true)

		table.insert(rainDrops, tag)
	end

	makeLuaSprite('rainDark', '', 0, 0)
	makeGraphic('rainDark', 1280, 720, '000000')
	setObjectCamera('rainDark', 'camOther')
	setProperty('rainDark.alpha', 0.08)
	addLuaSprite('rainDark', true)

end

function onUpdate(elapsed)

	if rainDrops == nil then return end

	for i = 1, #rainDrops do
		local tag = rainDrops[i]

		local x = getProperty(tag..'.x')
		local y = getProperty(tag..'.y')

		x = x + 500 * elapsed
		y = y + 900 * elapsed

		if y > 900 then
			y = -120
			x = math.random(-300, 1600)
		end

		setProperty(tag..'.x', x)
		setProperty(tag..'.y', y)
	end

end