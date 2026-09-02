function onCreate()
    setProperty('skipCountdown', true);
    setProperty('camHUD.alpha', 0);
    setProperty('scoreTxt.visible', false)
    setProperty('healthBarBG.visible', false);
    setProperty('healthBar.visible', false);
    setProperty('iconP1.visible', false);
    setProperty('iconP2.visible', false);
end

function onStepHit()
    if curStep == 48 then
        doTweenAlpha('appear', 'camHUD', 1, 0.01, 'linear');
    elseif curStep == 49 then
        doTweenAlpha('appear', 'camHUD', 0, 0.01, 'linear');
    elseif curStep == 50 then
        doTweenAlpha('appear', 'camHUD', 1, 0.01, 'linear');
    elseif curStep == 51 then
        doTweenAlpha('appear', 'camHUD', 0, 0.01, 'linear');
    elseif curStep == 52 then
        doTweenAlpha('appear', 'camHUD', 1, 0.01, 'linear');
    elseif curStep == 53 then
        doTweenAlpha('appear', 'camHUD', 0, 0.01, 'linear');
    elseif curStep == 54 then
        doTweenAlpha('appear', 'camHUD', 1, 0.01, 'linear');
    elseif curStep == 55 then
        doTweenAlpha('appear', 'camHUD', 0, 0.01, 'linear');
    elseif curStep == 56 then
        doTweenAlpha('appear', 'camHUD', 1, 0.01, 'linear');
    elseif curStep == 57 then
        doTweenAlpha('appear', 'camHUD', 0, 0.01, 'linear');
    elseif curStep == 58 then
        doTweenAlpha('appear', 'camHUD', 1, 0.01, 'linear');
    elseif curStep == 59 then
        doTweenAlpha('appear', 'camHUD', 0, 0.01, 'linear');
    elseif curStep == 60 then
        doTweenAlpha('appear', 'camHUD', 1, 0.01, 'linear');
    elseif curStep == 61 then
        doTweenAlpha('appear', 'camHUD', 0, 0.01, 'linear');
    elseif curStep == 62 then
        doTweenAlpha('appear', 'camHUD', 1, 0.01, 'linear');
    elseif curStep == 63 then
        doTweenAlpha('appear', 'camHUD', 0, 0.01, 'linear');
    elseif curStep == 64 then
        doTweenAlpha('appear', 'camHUD', 1, 0.01, 'linear');
        setProperty('scoreTxt.visible', true)
	setProperty('healthBarBG.visible', true);
	setProperty('healthBar.visible', true);
	setProperty('iconP1.visible', true);
	setProperty('iconP2.visible', true);
    end
end