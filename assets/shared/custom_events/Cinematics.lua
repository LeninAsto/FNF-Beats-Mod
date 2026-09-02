function onCreate()
	for i=1,2 do	
	local tag = i == 1 and 'upBar' or 'downBar'
		makeLuaSprite(tag, nil, 0, i==1 and -120 or 720)
		makeGraphic(tag, screenWidth, 120, '000000')
		setObjectCamera(tag, 'other')
		addLuaSprite(tag)
	end
end

local on = false
function Cinematics()
	on = not on
	doTweenY('Cinematics1', 'upBar', on and 0 or -120, 1, 'expoOut')
	doTweenY('Cinematics2', 'downBar', on and 600 or 720, 1, 'expoOut')
	doTweenY('Cinematics3', 'camHUD', on and ( downscroll and -90 or 70) or 0, 1, 'expoOut')
	for i = 0,7 do
	--noteTweenY(i, i, downscroll and (on and 480 or 570) or (on and 120 or 50), 1, 'expoOut')
	end
end

function onEvent(name,value1,value2)
	if name == 'Cinematics' then Cinematics() end
end