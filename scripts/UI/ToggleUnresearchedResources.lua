print("=== Toggle Unresearched Resources (UI) Loading ===")

ExposedMembers.Resources = ExposedMembers.Resources or {}

function ShowResourceMapPins(playerID, cityID)
    local player = Players[playerID]
    if player == nil or not player:IsHuman() then
        return
    end

    local city = CityManager.GetCity(playerID, cityID)
    if city == nil then
        return
    end

    local resourcesToShow = {}
    local techs = player:GetTechs()
    for row in GameInfo.Resources() do
        if (
            row.PrereqTech ~= nil and
            not techs:HasTech(GameInfo.Technologies[row.PrereqTech].Index)
        ) then
            resourcesToShow[row.Index] = true
        end
    end

    local config = PlayerConfigurations[playerID]
    local iX = city:GetX()
    local iY = city:GetY()
    local radiusPlots = Map.GetNeighborPlots(iX, iY, 3)
    for i = 1, #radiusPlots do
        local plot = radiusPlots[i]
        local resource = plot:GetResourceType()
        if resourcesToShow[resource] ~= nil then
            local x = plot:GetX()
            local y = plot:GetY()
            local pin = config:GetMapPin(x, y)
            local info = GameInfo.Resources[resource]
            pin:SetIconName("ICON_" .. info.ResourceType)
            Network.BroadcastPlayerInfo()
        end
    end
end

function HideResourceMapPins(playerID, cityID)
    local player = Players[playerID]
    if player == nil or not player:IsHuman() then
        return
    end

    local city = CityManager.GetCity(playerID, cityID)
    if city == nil then
        return
    end

    local resourcesToHide = {}
    local techs = player:GetTechs()
    for row in GameInfo.Resources() do
        if (
            row.PrereqTech ~= nil and
            not techs:HasTech(GameInfo.Technologies[row.PrereqTech].Index)
        ) then
            resourcesToHide[row.Index] = true
        end
    end

    local config = PlayerConfigurations[playerID]
    local x1 = city:GetX()
    local y1 = city:GetY()
    local pins = config:GetMapPins()
    for pinID, pin in pairs(pins) do
        local x2 = pin:GetHexX()
        local y2 = pin:GetHexY()
        local distance = Map.GetPlotDistance(x1, y1, x2, y2)
        if distance <= 3 then
            local iconName = pin:GetIconName():gsub("^ICON_", "")
            local info = GameInfo.Resources[iconName]
            if (
                info ~= nil and
                resourcesToHide[info.Index] ~= nil
            ) then
                config:DeleteMapPin(pinID)
                Network.BroadcastPlayerInfo()
            end
        end
    end
end

ExposedMembers.Resources.ShowResourceMapPins = ShowResourceMapPins
ExposedMembers.Resources.HideResourceMapPins = HideResourceMapPins

print("=== Toggle Unresearched Resources (UI) Loaded ===")
