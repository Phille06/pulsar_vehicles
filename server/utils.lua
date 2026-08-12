local _trailerModels = {
    [`trailers`] = true,
    [`trailers2`] = true,
    [`trailers3`] = true,
    [`trailers4`] = true,
    [`trailers5`] = true,
    [`docktrailer`] = true,
    [`tvtrailer`] = true,
    [`boattrailer`] = true,
    [`trailersmall`] = true,
    [`tr2`] = true,
    [`tr3`] = true,
    [`tr4`] = true,
    [`tanker`] = true,
    [`tanker2`] = true,
    [`trflat`] = true,
    [`trailerlogs`] = true,
    [`trailerlarge`] = true,
    [`armytanker`] = true,
    [`armytrailer`] = true,
    [`proptrailer`] = true,
    [`freighttrailer`] = true,
    [`20fttrailer`] = true,
}

local _trailerModels = {
    [`trailers`] = true,
    [`trailers2`] = true,
    [`trailers3`] = true,
    [`tvtrailer`] = true,
    [`trailers4`] = true,
    [`boattrailer`] = true,
    [`trailersmall`] = true,
    [`tr2`] = true,
    [`tr4`] = true,
    [`tanker`] = true,
    [`tanker2`] = true,
    [`trflat`] = true,
    [`trailerlogs`] = true,
    [`trailerlarge`] = true,
    [`proptrailer`] = true,
    [`20fttrailer`] = true,
}

local _validVehicleTypes = {
    automobile = true,
    bike = true,
    boat = true,
    heli = true,
    plane = true,
    submarine = true,
    trailer = true,
    train = true,
    quadbike = true,
    blimp = true,
    amphibious_automobile = true,
    amphibious_quadbike = true,
}

local _vehicleTypeAliases = {
    motorcycle = 'bike',
    motorbike = 'bike',
    helicopter = 'heli',
    plane_and_heli = 'plane',
}

function CreateVehicleFromType(type, model, coords, heading, useLegacyMethod)
    if not _validVehicleTypes[type] then
        type = _vehicleTypeAliases[type] or 'automobile'
    end

    if not heading then heading = 0.0 end

    -- Trailers always spawn via the legacy CreateVehicle path and get the despawn/setup event
    if _trailerModels[model] then
        local veh = CreateVehicle(model, coords.x, coords.y, coords.z + 0.2, heading + 0.0, true, true)
        while not DoesEntityExist(veh) do Wait(10) end
        local netId = NetworkGetNetworkIdFromEntity(veh)
        TriggerClientEvent("Vehicles:Client:SetDespawnStuff", -1, netId)
        return veh
    end

    if not useLegacyMethod then
        if model ~= nil then
            local veh = CreateVehicleServerSetter(model, type, coords.x, coords.y, coords.z, heading)
            if DoesEntityExist(veh) then
                return veh
            end
        end
        return nil
    else
        local veh = CreateVehicle(model, coords.x, coords.y, coords.z, heading + 0.0, true, true)
        while not DoesEntityExist(veh) do Wait(10) end
        return veh
    end
end

function ParseImpoundData(fine, hold, impounder)
    if not fine then
        fine = 0
    end
    if type(hold) ~= 'number' or hold <= 0 then
        hold = 0
    end
    return {
        Type = 0,
        Id = 0,
        Fine = fine,
        TimeHold = (hold > 0 and {
            ImpoundedAt = os.time(),
            ExpiresAt = os.time() + (hold * 3600),
            Length = (hold * 3600),
        } or false),
        Impounder = impounder,
    }
end

function GetVehicleTypeDefaultStorage(vehicleType)
    for k, v in pairs(_vehicleStorage) do
        if v.default and vehicleType == v.vehType then
            return {
                Type = 1,
                Id = k
            }
        end
    end
    return {
        Type = 0,
        Id = 0
    }
end

function DoesVehiclePassStorageRestrictions(source, restrictedData)
    for k, v in ipairs(restrictedData) do
        if plsr.Jobs.Permissions:HasJob(source, v.JobId, v.WorkplaceId) then
            return true
        end
    end
    return false
end