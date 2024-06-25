local assets =
{
    Asset("PKGREF", "anim/ui_chester_shadow_3x4.zip"), --switched to portal version
    Asset("ANIM", "anim/ui_portal_shadow_3x4.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),

    Asset("ANIM", "anim/chester.zip"),
    Asset("ANIM", "anim/chester_build.zip"),
    Asset("ANIM", "anim/chester_shadow_build.zip"),
    Asset("ANIM", "anim/chester_snow_build.zip"),
    Asset("ANIM", "anim/shadow_breath.zip"),
    Asset("ANIM", "anim/tophat_fx.zip"),

    Asset("SOUND", "sound/chester.fsb"),

    Asset("MINIMAP_IMAGE", "chester"),
    Asset("MINIMAP_IMAGE", "chestershadow"),
    Asset("MINIMAP_IMAGE", "chestersnow"),
}

local assets_swirl =
{
	Asset("ANIM", "anim/chester.zip"),
	Asset("ANIM", "anim/tophat_fx.zip"),
}

local prefabs =
{
    "chester_eyebone",
    "chesterlight",
    "chester_transform_fx",
    "globalmapiconunderfog",
	"frostbreath",
	"shadow_chester_swirl_fx",
}

local brain = require "brains/goobahbrain"

local ChesterStateNames =
{
	"NORMAL",
	"SNOW",
	"SHADOW",
}
local ChesterState = table.invert(ChesterStateNames)

local sounds =
{
    hurt = "dontstarve/creatures/chester/hurt",
    pant = "dontstarve/creatures/chester/pant",
    death = "dontstarve/creatures/chester/death",
    open = "dontstarve/creatures/chester/open",
    close = "dontstarve/creatures/chester/close",
    pop = "dontstarve/creatures/chester/pop",
    boing = "dontstarve/creatures/chester/boing",
    lick = "dontstarve/creatures/chester/lick",
}

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    --print(inst, "ShouldSleep", DefaultSleepTest(inst), not inst.sg:HasStateTag("open"), inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) and not TheWorld.state.isfullmoon
end

local function ShouldKeepTarget()
    return false -- chester can't attack, and won't sleep if he has a target
end



-- eye bone was killed/destroyed
local function OnStopFollowing(inst)
    --print("chester - OnStopFollowing")
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
    --print("chester - OnStartFollowing")
    inst:AddTag("companion")
end

local function OnClientChesterStateDirty(inst)
	ToggleBreath(inst)
end

local function OnHaunt(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_ALWAYS then
        inst.components.hauntable.panic = true
        inst.components.hauntable.panictimer = TUNING.HAUNT_PANIC_TIME_SMALL
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end

-- Make Goobahs follow player

--[[local function ShouldAcceptItem(inst, item)
    return true
end]]

local function OnGetItemFromPlayer(inst, giver, item)
    if(item.prefab == "rocks") then
        giver.components.leader:AddFollower(inst)
        return true
    end
    return true
end



local function create_goobah()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 75, .5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst:AddTag("companion")
    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("goobah")
    inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("trader")

    inst.MiniMapEntity:SetIcon("chester.png")
    inst.MiniMapEntity:SetCanUseCache(false)

    inst.AnimState:SetBank("chester")
    inst.AnimState:SetBuild("chester_build")

    inst.DynamicShadow:SetSize(2, 1.5)

    inst.Transform:SetFourFaced()

	inst._chesterstate = net_tinybyte(inst.GUID, "chester._chesterstate", "chesterstatedirty")
	inst._chesterstate:set(ChesterState.NORMAL)

	inst._frostbreathtrigger = net_event(inst.GUID, "chester._frostbreathtrigger")

	inst:AddComponent("container_proxy")
	inst.components.container_proxy:SetCanBeOpened(false)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		inst:ListenForEvent("chesterstatedirty", OnClientChesterStateDirty)
        return inst
    end

    ------------------------------------------
    inst:AddComponent("maprevealable")
    inst.components.maprevealable:SetIconPrefab("globalmapiconunderfog")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chester_body"
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
    inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 7
    inst.components.locomotor:SetAllowPlatformHopping(true)

    inst:AddComponent("trader")
    -- IF TRADING FAILS AGAIN CHECK HERE
    --inst.components.trader:SetAcceptTest(true)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    
    inst.components.trader.deleteitemonaccept = false


    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:AddComponent("follower")
    --inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)
    --inst.components.follower:SetLeader("suri")

    inst:AddComponent("knownlocations")

    MakeSmallBurnableCharacter(inst, "chester_body")

	--SwitchToContainer(inst)

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    MakeHauntableDropFirstItem(inst)
    AddHauntableCustomReaction(inst, OnHaunt, false, false, true)

    inst.sounds = sounds

    inst:SetStateGraph("SGchester")
    inst.sg:GoToState("idle")

    inst:SetBrain(brain)

	--inst.DebugMorph = DebugMorph
    --inst.MorphChester = MorphChester
    --inst:WatchWorldState("isfullmoon", CheckForMorph)
    --inst:ListenForEvent("onclose", CheckForMorph)

    --[[inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad
	inst.OnLoadPostPass = OnLoadPostPass
    inst.SetBuild = SetBuild -- NOTES(JBK): This is for skins.]]

    return inst
end

--------------------------------------------------------------------------

local function ReleaseSwirl(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot = inst.Transform:GetRotation()
	inst.entity:SetParent(nil)
	inst.Transform:SetPosition(x, y, z)
	inst.Transform:SetRotation(rot)
	inst.AnimState:PlayAnimation("swirl_pst")
	inst:ListenForEvent("animover", inst.Remove)
end

local function swirl_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("NOCLICK")
	--inst:AddTag("FX")
	inst:AddTag("CLASSIFIED") --unfortunately, in DST, "FX" still makes it mouseover when parented

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("chester")
	inst.AnimState:SetBuild("tophat_fx")
	inst.AnimState:PlayAnimation("swirl_pre")
	inst.AnimState:SetFinalOffset(1)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.AnimState:PushAnimation("swirl_loop", true)

	inst.persists = false

	inst.ReleaseSwirl = ReleaseSwirl

	return inst
end

--------------------------------------------------------------------------

return Prefab("goobah", create_goobah, assets, prefabs),
	Prefab("shadow_chester_swirl_fx", swirl_fn, assets_swirl)
