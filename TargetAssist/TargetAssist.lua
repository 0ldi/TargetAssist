local lastUpdate = 0
local locked = true
BINDING_HEADER_TARGETASSIST = "Target Assist";

function TA_OnUpdate()
	local time = GetTime()
	if time - lastUpdate > 0.2 and locked then
		lastUpdate = time;

		TA_ScanMarks(nil)
	end
end

function TA_ScanMarks(newTarget)
	local prefix = ""
	local num = 0
	local foundTarget = false
	local counter = 1

	if GetNumRaidMembers() > 0 then
		prefix = "RAID"
		num = GetNumRaidMembers()
	elseif GetNumPartyMembers() > 0 then
		prefix = "PARTY"
		num = GetNumPartyMembers()
	end

	if num > 0 then
		local marks = {}

		for i = 1,num,1 do
			local icon = GetRaidTargetIndex(prefix..i.."target")

			if icon ~= nil and UnitExists(prefix..i.."target") 
				and not UnitIsDead(prefix..i.."target")
				and not UnitIsFriend("player",prefix..i.."target") then

				marks[icon] = prefix..i.."target"
				if newTarget == icon then
					TargetUnit(marks[icon])
					foundTarget = true
				end
			end
		end

		counter = TA_UpdateIcon(counter,8,marks[8])
		counter = TA_UpdateIcon(counter,7,marks[7])
		counter = TA_UpdateIcon(counter,4,marks[4])
		counter = TA_UpdateIcon(counter,6,marks[6])
		counter = TA_UpdateIcon(counter,5,marks[5])
		counter = TA_UpdateIcon(counter,3,marks[3])
		counter = TA_UpdateIcon(counter,2,marks[2])
		counter = TA_UpdateIcon(counter,1,marks[1])
	end

	TA_ClearMarks(counter)

	return foundTarget
end

function TA_UpdateIcon(counter,index,target)
	if target ~= nil then
		local icon = getglobal("TAIcon"..counter)
		icon:Show()
		icon.target = target
		icon.index = index

		SetRaidTargetIconTexture(getglobal("TAIcon"..counter.."Texture"),index)

		if GetRaidTargetIndex("target") == index then
			icon:SetAlpha(ta_settings.selectedAlpha)
		else
			icon:SetAlpha(ta_settings.unselectedAlpha)
		end

		getglobal("TAIcon"..counter.."Status"):SetMinMaxValues(0, UnitHealthMax(target))
		getglobal("TAIcon"..counter.."Status"):SetValue(UnitHealth(target))

		return counter + 1
	else
		getglobal("TAIcon"..counter):Hide()
		return counter
	end
end

function TA_ClearMarks(counter)
	for i=counter,8,1 do
		if getglobal("TAIcon"..i):IsVisible() then
			getglobal("TAIcon"..i):Hide()
		end
	end
end

function TA_TargetIcon(newTarget)
	if not TA_ScanMarks(newTarget) then

		-- No marks found. Check nearest enemies.
		for i=0,20 do 
			if GetRaidTargetIndex("target") == nil or GetRaidTargetIndex("target") ~= newTarget then
				TargetNearestEnemy()
			else
				return
			end
		end

		ClearTarget()
	end
end

function TA_OnClick(frame)
	if frame.target ~= nil then
		TargetUnit(frame.target)
	end
end

function TA_TargetNextMark()
	local nextIcon = 1
	local currentIndex = GetRaidTargetIndex("target")

	if not getglobal("TAIcon1"):IsVisible() then
		TargetNearestEnemy()
		return
	end

	if currentIndex ~= nil and UnitExists("target") then
		for i=1,8,1 do
			local icon = getglobal("TAIcon"..i)
			if icon.index == currentIndex then
				nextIcon = i + 1
				break
			end
		end
	end

	if not getglobal("TAIcon"..nextIcon):IsVisible() then
		TargetNearestEnemy()
		return
	end

	TA_OnClick(getglobal("TAIcon"..nextIcon))
end

function TA_Lock()
	locked = not locked

	if not locked then
		for i=1,8,1 do
			local icon = getglobal("TAIcon"..i)
			icon:Show()
			SetRaidTargetIconTexture(getglobal("TAIcon"..i.."Texture"),(9-i))
			icon:SetAlpha(ta_settings.selectedAlpha)
			icon:RegisterForDrag("LeftButton")
			getglobal("TAIcon"..i.."Status"):SetValue(75)
		end
	else
		for i=1,8,1 do
			local icon = getglobal("TAIcon"..i)
			icon:RegisterForDrag(nil)
		end
	end

end

SlashCmdList["TA"] = function(_msg)
	TA_Lock()
end

SLASH_TA1 = "/ta";