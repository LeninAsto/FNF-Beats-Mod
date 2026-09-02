function onBeatHit()
local color = curBeat % 2 == 0 and 'E76517' or '3C75AC'
setTimeBarColors(color, '000000')
end