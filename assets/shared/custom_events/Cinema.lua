local on = false
function onCreate()
	for i=1,2 do
		makeLuaSprite('bar'..i, nil, 0, i == 1 and -100 or 720)
		makeGraphic('bar'..i, screenWidth, 100, '000000')
		setObjectCamera('bar'..i, 'other')
		addLuaSprite('bar'..i)
	end
end

function onUpdate(elapsed)
	setProperty('camZooming', not on)
end

function onChange(z, t)
	local gameZoom = tonumber(z) or 0.086
	local tweenTime = tonumber(t) or 5
	on = not on
	cancelTween("hudSquish"); cancelTween('bar1.y'); cancelTween('bar2.y'); cancelTween('gameZoomer')
	runHaxeCode('game.modchartTweens.set("hudSquish", FlxTween.tween(game.camHUD.flashSprite, {scaleY: '..(on and 0.84 or 1)..'}, '..tweenTime..', {ease: FlxEase.quartOut}));')
		for i=1,2 do
			local targetY = on and (i == 1 and -35 or 655) or (i == 1 and -100 or 720)
			doTweenY('bar'..i..'.y', 'bar'..i, targetY, tweenTime, 'quartOut')
		end
	doTweenZoom('gameZoomer', 'camGame', getProperty('defaultCamZoom') - (on and gameZoom or 0), tweenTime, 'quartOut')
end

function onEvent(n, v1, v2)
	if n == 'Cinema' then onChange(v1, v2) end
end