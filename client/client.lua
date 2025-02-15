local sitting = false

if config.ox_target then
	local options =
	{
	    {
	        label = config.targetName, name = "cssit", icon = config.targetIcon, iconColor = "orange", distance = 1.5,
	        canInteract = function() if not sitting then return true else return false end end,
	        onSelect = function(data) 
	        	return sit(data.entity, data.coords)
	        end
	    },
	    {
	        label = config.targetNameStandUp, name = "csstandup", icon = config.targetIcon, iconColor = "orange", distance = 1.5,
	        canInteract = function() if sitting then return true else return false end end,
	        onSelect = function(data) return ExecuteCommand('cscripts:sit:stand_up') end
	    }
	}
	exports.ox_target:addModel(config.chairs, options)
end

function sit(entity,newCoords)
	local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = GetEntityCoords(entity)
    local name = GetEntityArchetypeName(entity)
    local heading = GetEntityHeading(entity) + 180.0
    if string.find(name, "bench") then
    	entityCoords = newCoords
    end
    if name == "prop_table_01_chr_b" then heading += 90 end
    localEntity = entity
    FreezeEntityPosition(localEntity,true)
    local direction = vector3(playerCoords.x - entityCoords.x, playerCoords.y - entityCoords.y, 0.0)
    local distance = #(playerCoords - entityCoords)
    local moveCoords = entityCoords + (playerCoords - entityCoords) * (1.0 / distance)
    if GetEntityArchetypeName(entity) == "apa_mp_h_yacht_barstool_01" then
    	playerCoords = vec3(playerCoords.x,playerCoords.y,playerCoords.z+0.25)
    	TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", entityCoords.x, entityCoords.y, playerCoords.z-0.5, heading, 0, true, true)
	else
    	TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", entityCoords.x, entityCoords.y, playerCoords.z-0.5, heading, 0, true, true)
    end
    if config.forceFPVonSit then
    	Wait(1000)
    	SetFollowPedCamViewMode(4)
    end
    sitting = true
end

RegisterKeyMapping('cscripts:sit:stand_up_x', 'Nevera - Stand Up X', 'keyboard', "X")
RegisterKeyMapping('cscripts:sit:stand_up_space', 'Nevera - Stand Up SPACE', 'keyboard', "SPACE")

RegisterCommand('cscripts:sit:stand_up_x', function() ExecuteCommand('cscripts:sit:stand_up') end)
RegisterCommand('cscripts:sit:stand_up_space', function() ExecuteCommand('cscripts:sit:stand_up') end)

RegisterCommand('cscripts:sit:stand_up', function()
	if sitting then
		sitting = false
		local playerPed = PlayerPedId()
		ClearPedTasks(playerPed)
		TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_IDLE", 0, true)
		FreezeEntityPosition(localEntity,false)
		if attachedEntity ~= nil then
			DetachEntity(PlayerPedId(), true, false)
			attachedEntity = nil
		end
		Wait(500)
		SetFollowPedCamViewMode(1)
	end
end)