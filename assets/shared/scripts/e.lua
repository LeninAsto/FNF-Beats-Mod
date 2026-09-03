function onUpdate()
--setProperty("defaultCamZoom", 0.3); setProperty("camGame.zoom", 0.3)
--setProperty('camHUD.visible', false)
setProperty('cpuControlled', true)
end

-- Modchart?
--[[
function onInitModchart()
  addModifier("drunk")

  set("drunk", 0, 1)
end
]]
