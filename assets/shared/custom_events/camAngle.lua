local angleshit = 0;
local anglevar = 0;
local activate = false

function onCreate()
luaDebugMode = true
end

function onEvent(name, v1, v2)
	if name == 'camAngle' then
		if v1 == 'On' then
		activate = true
			--debugPrint('THIS SHIT IS ACTIATED YIIPIIIIEEEEE')
		else
		activate = false
			--debugPrint('THIS SHIT IS DESACTIVATED SO SAAAD')
		end
		if v2 ~= '' then
		angleshit = v2
		anglevar = v2
		else
		angleshit = 1
		anglevar = 1
		end
	end
end

function onBeatHit()
	if activate == true then
		if curBeat % 2 == 0 then
			angleshit = anglevar;
		else
			angleshit = -anglevar;
		end
		--debugPrint('BEAT HIT!')
		setProperty('camHUD.angle',angleshit*3)
		setProperty('camGame.angle',angleshit*3)
		doTweenAngle('turn', 'camHUD', angleshit, stepCrochet*0.002, 'circOut')
		doTweenX('tuin', 'camHUD', -angleshit*8, crochet*0.001, 'linear')
		doTweenAngle('tt', 'camGame', angleshit, stepCrochet*0.002, 'circOut')
		doTweenX('ttrn', 'camGame', -angleshit*8, crochet*0.001, 'linear')
	else
		setProperty('camHUD.angle',0)
		setProperty('camHUD.x',0)
		setProperty('camGame.angle',0)
		setProperty('camGame.x',0)
	end
		
end