local oneortwo = 1
function onStartCountdown()
oneortwo = oneortwo + 1
if oneortwo ~= 2 then return end --lmfaooo stickers shit calls onStartCountdown three times brooooo WTFF
--i planned to put this on the events ... but i forgor the stickers stuff was disabled
if flashingLights then
makeLuaSprite('white', nil, 0, 0)
makeGraphic('white', 1,1,'FFFFFF')
scaleObject('white', screenWidth, screenHeight)
addLuaSprite('white')
setObjectCamera('white', 'other')
end
setProperty("defaultCamZoom", 3); setProperty("camGame.zoom", 3)
setProperty("cameraSpeed", 0.015)
setProperty("camFollow.y", 350); setProperty("camFollowPos.y", 350)
setProperty("camFollow.x", 2026); setProperty("camFollowPos.x", 2026)
setProperty('isCameraOnForcedPos', true)
end

function onSongStart()
runHaxeCode("FlxTween.tween(game, {cameraSpeed: 0.055}, 20, {ease: FlxEase.sineInOut});")
if not flashingLights then return end
removeLuaSprite('white') --The cameraFlash does the rest
end