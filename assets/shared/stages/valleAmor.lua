local carIndex = 1
local carDirection = 1
local florContador = 0

function onCreate()

    makeLuaSprite('cielo', 'Valle_amor/cielo', -1400, -1500)
    setScrollFactor('cielo', 0.2, 0.2)
    addLuaSprite('cielo', false)

    makeLuaSprite('montañas', 'Valle_amor/montañas', -1400, -1000)
    setScrollFactor('montañas', 0.4, 0.4)
    addLuaSprite('montañas', false)

    makeLuaSprite('estatua', 'Valle_amor/estatua', -100, -1400)
    setScrollFactor('estatua', 0.6, 0.6)
    addLuaSprite('estatua', false)

    makeLuaSprite('postes', 'Valle_amor/postes', -1300, -1000)
    setScrollFactor('postes', 0.7, 0.7)
    addLuaSprite('postes', false)

    makeAnimatedLuaSprite('cars', 'Valle_amor/cars', -7000, -240)
    addAnimationByPrefix('cars', 'carro1', 'carro1', 24, true)
    addAnimationByPrefix('cars', 'carro2', 'carro2', 24, true)
    addAnimationByPrefix('cars', 'carro3', 'carro3', 24, true)
    addAnimationByPrefix('cars', 'carro4', 'carro4', 24, true)
    addAnimationByPrefix('cars', 'carro5', 'carro5', 24, true)
    setScrollFactor('cars', 0.75, 0.75)
    addLuaSprite('cars', false)

    makeLuaSprite('Fondo', 'Valle_amor/fondo', -2300, -1300)
    addLuaSprite('Fondo', false)

    makeAnimatedLuaSprite('public', 'Valle_amor/public', -300, -50)
    addAnimationByPrefix('public', 'public', 'idle', 18, true)
    addLuaSprite('public', false)

    makeAnimatedLuaSprite('ggt', 'Valle_amor/ggteam', -700, -25)
    addAnimationByPrefix('ggt', 'ggteam', 'idle', 24, true)
    addLuaSprite('ggt', false)

    makeAnimatedLuaSprite('compu', 'Valle_amor/compu', -100, 420)
    addAnimationByPrefix('compu', 'compu', 'compu', 18, true)
    addLuaSprite('compu', true)

    makeAnimatedLuaSprite('rs1', 'Valle_amor/rs1', -1400, 250)
    addAnimationByPrefix('rs1', 'r3', 'r3', 24, true)
    setScrollFactor('rs1', 0.9, 0.9)
    addLuaSprite('rs1', false)

    makeAnimatedLuaSprite('rs2', 'Valle_amor/rs1', 1400, 200)
    addAnimationByPrefix('rs2', 'r4', 'r4', 24, true)
    setScrollFactor('rs2', 0.9, 0.9)
    addLuaSprite('rs2', true)

    makeAnimatedLuaSprite('z1', 'Valle_amor/rs1', 1000, 0)
    addAnimationByPrefix('z1', 'z1', 'z1', 24, true)
    setScrollFactor('z1', 0.9, 0.9)
    addLuaSprite('z1', true)

    makeAnimatedLuaSprite('compu', 'Valle_amor/compu', -100, 420)
    addAnimationByPrefix('compu', 'compu', 'compu', 18, true)
    addLuaSprite('compu', true)

    makeAnimatedLuaSprite('r1', 'Valle_amor/r1', 1300, 415)
    addAnimationByPrefix('r1', 'r1', 'r1', 24, true)
    setScrollFactor('r1', 1.0, 1.0)
    addLuaSprite('r1', true)

    makeAnimatedLuaSprite('r2', 'Valle_amor/r2', 380, 475)
    addAnimationByPrefix('r2', 'r2', 'r2', 24, true)
    setScrollFactor('r2', 1.0, 1.0)
    addLuaSprite('r2', true)

    makeAnimatedLuaSprite('r5', 'Valle_amor/r5', -900, 475)
    addAnimationByPrefix('r5', 'r5', 'r5', 24, true)
    setScrollFactor('r5', 1.0, 1.0)
    addLuaSprite('r5', true)

    makeAnimatedLuaSprite('mom', 'Valle_amor/mom', -1500, 375)
    addAnimationByPrefix('mom', 'mom', 'mom', 24, true)
    setScrollFactor('mom', 1.0, 1.0)
    addLuaSprite('mom', true)

    makeLuaSprite('aura', 'Valle_amor/aura', -1800, -1000)
    setScrollFactor('aura', 0, 0)
    setBlendMode('aura', 'add')
    setProperty('aura.alpha', 0.5)
    addLuaSprite('aura', true)

    precacheImage('Valle_amor/flor')

    runTimer('spawnCar', 2)

end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if isSustainNote then return end
    hacerFlor()
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    if isSustainNote then return end
    hacerFlor()
end

function onTimerCompleted(tag, loops, loopsLeft)

    if tag == 'spawnCar' then

        local anim = 'carro'..carIndex
        objectPlayAnimation('cars', anim, true)

        if carDirection == 1 then
            setProperty('cars.x', -7000)
            setProperty('cars.flipX', true)
            doTweenX('carMove', 'cars', 5000, 12, 'linear')
        else
            setProperty('cars.x', 5000)
            setProperty('cars.flipX', false)
            doTweenX('carMove', 'cars', -7000, 12, 'linear')
        end

        carDirection = carDirection * -1

        carIndex = carIndex + 1
        if carIndex > 5 then carIndex = 1 end

        runTimer('spawnCar', 12)
    end

    if string.find(tag, 'flor') then
        doTweenAlpha(tag, tag, 0, 1)
    end
end

function hacerFlor()

    florContador = florContador + 1
    local tag = 'flor'..florContador

    makeAnimatedLuaSprite(tag, 'Valle_amor/flor', getRandomInt(-2000, 4000), -1200)
    addLuaSprite(tag, true)

    setObjectOrder(tag, getObjectOrder('aura') - 1)

    addAnimationByPrefix(tag, 'idle', 'flor'..getRandomInt(1,8), 24, true)
    objectPlayAnimation(tag, 'idle', true)

    setScrollFactor(tag, 1, 1)

    local scale = getRandomFloat(0.4, 0.9)
    scaleObject(tag, scale, scale)

    setProperty(tag..'.alpha', 0.75)

    setProperty(tag..'.velocity.x', getRandomInt(-200, 200))
    setProperty(tag..'.velocity.y', getRandomInt(200, 400))

    setProperty(tag..'.angularVelocity', getRandomInt(-180, 180))

    runTimer(tag, 6)

end

function onTweenCompleted(tag)
    if string.find(tag, 'flor') then
        removeLuaSprite(tag)
    end
end