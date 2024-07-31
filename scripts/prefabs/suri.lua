local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs =
{
    "",
}

TUNING.SURI_HEALTH = 150
TUNING.SURI_HUNGER = 200
TUNING.SURI_SANITY = 125


TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.suri = {
	"goldnugget",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
   start_inv[string.lower(k)] = v.suri
end

local prefabs = FlattenTree(start_inv, true)

local function GetFuelMasterBonus(inst, item, target)

    -- The TAG "firefuellight" is used for items that are not campfires in that they won't incubate something but Willow should benefit from fueling it.
    return (target:HasTag("firefuellight") or target:HasTag("campfire") or target.prefab == "nightlight") and TUNING.WILLOW_CAMPFIRE_FUEL_MULT or 1
end

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "suri_speed_mod", 1)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "suri_speed_mod")
end

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end

local common_postinit = function(inst) 
	inst:AddTag("expertchef")
    inst:AddTag("pyromaniac")
    inst:AddTag("heatresistant")
	inst.MiniMapEntity:SetIcon( "suri.tex" )
end

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
	inst.soundsname = "willow"
	
	inst.components.health:SetMaxHealth(TUNING.SURI_HEALTH)
	inst.components.hunger:SetMax(TUNING.SURI_HUNGER)
	inst.components.sanity:SetMax(TUNING.SURI_SANITY)
	
    inst.components.combat.damagemultiplier = 1.0
	inst.components.hunger.hungerrate = 1.15 * TUNING.WILSON_HUNGER_RATE

    inst.components.temperature.inherentinsulation = -TUNING.INSULATION_SMALL
    inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_SMALL

    
	inst.OnLoad = onload
    inst.OnNewSpawn = onload

    inst:AddComponent("fuelmaster")
    inst.components.fuelmaster:SetBonusFn(GetFuelMasterBonus)
	
end

return MakePlayerCharacter("suri", prefabs, assets, common_postinit, master_postinit, prefabs)
