local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs =
{
    "",
}

TUNING.ECHO_HEALTH = 225
TUNING.ECHO_HUNGER = 125
TUNING.ECHO_SANITY = 100


TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.ECHO = {
   "echogun",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
   start_inv[string.lower(k)] = v.ECHO
end

local prefabs = FlattenTree(start_inv, true)

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "echo_speed_mod", 0.95)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "echo_speed_mod")
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
	inst:AddTag("fearless_leader")
	inst.MiniMapEntity:SetIcon( "echo.tex" )
end

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
	inst.soundsname = "willow"
	
	inst.components.health:SetMaxHealth(TUNING.ECHO_HEALTH)
	inst.components.hunger:SetMax(TUNING.ECHO_HUNGER)
	inst.components.sanity:SetMax(TUNING.ECHO_SANITY)
	
    inst.components.combat.damagemultiplier = 1.0
	inst.components.hunger.hungerrate = 0.95 * TUNING.WILSON_HUNGER_RATE

    
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
end

return MakePlayerCharacter("echo", prefabs, assets, common_postinit, master_postinit, prefabs)
