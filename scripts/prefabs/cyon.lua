local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs =
{
    "",
}

TUNING.CYON_HEALTH = 125
TUNING.CYON_HUNGER = 175
TUNING.CYON_SANITY = 125


TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.CYON = 
{
	"cyoncane",
	"cyonhat",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
   start_inv[string.lower(k)] = v.CYON
end

local prefabs = FlattenTree(start_inv, true)

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "cyon_speed_mod", 1.0)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "cyon_speed_mod")
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

local function sanityfn(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local delta = 0
	local ents = TheSim:FindEntities(x, y, z, 20, {"player"})
	for k, v in pairs(ents) do
		if v ~= inst then
			local bonus_sanity = TUNING.SANITYAURA_SMALL
			local distsq = math.max(inst:GetDistanceSqToInst(v), 1)
			delta = delta + bonus_sanity / distsq
		end
	end
	return delta
end

local function spidersanityfn(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local delta = 0
	local ents = TheSim:FindEntities(x, y, z, 10, {"spider","warrior_spider","spider_hider", "spider_spitter", "spider_dropper", "spider_moon", "spider_healer", "spider_water", "spider_queen"})
	for k, v in pairs(ents) do
		if v ~= inst then
			local bonus_sanity = -TUNING.SANITYAURA_LARGE
			local distsq = math.max(inst:GetDistanceSqToInst(v), 1)
			delta = delta + bonus_sanity / distsq
		end
	end
	return delta
end


local common_postinit = function(inst) 
	inst:AddTag("tanuki")
	inst.MiniMapEntity:SetIcon( "cyon.tex" )
end

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
	inst.soundsname = "willow"
	
	inst.components.health:SetMaxHealth(TUNING.CYON_HEALTH)
	inst.components.hunger:SetMax(TUNING.CYON_HUNGER)
	inst.components.sanity:SetMax(TUNING.CYON_SANITY)
	
    inst.components.combat.damagemultiplier = 1.0
	inst.components.hunger.hungerrate = 1.0 * TUNING.WILSON_HUNGER_RATE

    inst.components.temperature.inherentinsulation = TUNING.INSULATION_TINY
    inst.components.temperature.inherentsummerinsulation = -TUNING.INSULATION_TINY

	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
    inst.components.sanity.custom_rate_fn = sanityfn
    inst.components.sanity.custom_rate_fn = spidersanityfn
end

return MakePlayerCharacter("cyon", prefabs, assets, common_postinit, master_postinit, prefabs)
