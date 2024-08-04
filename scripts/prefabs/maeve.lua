local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs =
{
    "",
}

TUNING.MAEVE_HEALTH = 150
TUNING.MAEVE_HUNGER = 125
TUNING.MAEVE_SANITY = 125


TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.MAEVE = {
	"maevesword",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
   start_inv[string.lower(k)] = v.MAEVE
end

local prefabs = FlattenTree(start_inv, true)

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "maeve_speed_mod", 1)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "maeve_speed_mod")
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

local function checksanity(inst)
    local sanity = inst.components.sanity:GetPercent()
    if sanity ~= nil and not inst.components.health:IsDead() then
        if sanity >= .95 then
            local damage_multiplier = 1.7
            inst.components.combat.externaldamagemultipliers:SetModifier(inst, damage_multiplier, "damage_from_sanity")
        elseif (sanity >= 0.8) or (sanity < 0.95) then
            local damage_multiplier = 1.5
            inst.components.combat.externaldamagemultipliers:SetModifier(inst, damage_multiplier, "damage_from_sanity")
        elseif (sanity >= 0.6) or (sanity < 0.8) then
                local damage_multiplier = 1.2
                inst.components.combat.externaldamagemultipliers:SetModifier(inst, damage_multiplier, "damage_from_sanity")
        elseif (sanity >= 0.4) or (sanity < 0.6) then
                inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, "damage_from_sanity")   
        elseif (sanity >= 0.2) or (sanity < 0.4) then
                local damage_multiplier = 0.8
                inst.components.combat.externaldamagemultipliers:SetModifier(inst, damage_multiplier, "damage_from_sanity")
        else
                local damage_multiplier = 0.5
                inst.components.combat.externaldamagemultipliers:SetModifier(inst, damage_multiplier, "damage_from_sanity")
        end
    end
end

local MONSTER_TAGS = { "monster" }
local function monstersanityfn(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local delta = 0
	local ents = TheSim:FindEntities(x, y, z, 10, MONSTER_TAGS)
	for k, v in pairs(ents) do
		if v ~= inst then
			local bonus_sanity = -TUNING.SANITYAURA_MED
			local distsq = math.max(inst:GetDistanceSqToInst(v), 1)
			delta = delta + bonus_sanity / distsq
		end
	end
	return delta
end

local common_postinit = function(inst) 
	inst:AddTag("")
	inst.MiniMapEntity:SetIcon( "maeve.tex" )
end

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
	inst.soundsname = "willow"
	
	inst.components.health:SetMaxHealth(TUNING.MAEVE_HEALTH)
	inst.components.hunger:SetMax(TUNING.MAEVE_HUNGER)
	inst.components.sanity:SetMax(TUNING.MAEVE_SANITY)
	
    inst.components.combat.damagemultiplier = 1.0
	inst.components.hunger.hungerrate = 1.0 * TUNING.WILSON_HUNGER_RATE
    
    inst:ListenForEvent("sanitydelta", checksanity)
    inst.components.sanity.custom_rate_fn = monstersanityfn

	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
end

return MakePlayerCharacter("maeve", prefabs, assets, common_postinit, master_postinit, prefabs)
