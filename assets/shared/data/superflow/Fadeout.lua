-- fade out
function onCreatePost()
	-- end of "create"
	
	makeLuaSprite('fade', 'Black', -1500, -700)
	   scaleObject('fade', 4, 4)
	addLuaSprite('fade', true)
end

function onSongStart()
	-- Inst and Vocals start playing, songPosition = 0
	doTweenAlpha('fadeout', 'fade', 0, 3, 'linear')
end

