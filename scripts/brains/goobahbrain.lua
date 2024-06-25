require "behaviours/follow"
require "behaviours/wander"
require "behaviours/faceentity"
local BrainCommon = require("brains/braincommon")

local SEE_ITEM_DIST = 10 -- Can possibly use for perk? Have goobah collect things for Suri?

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 8
local TARGET_FOLLOW_DIST = 6

local MAX_WANDER_DIST = 5

local GoobahBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local GETTRADER_MUST_TAGS = { "player" }
local function GetTraderFn(inst)
    return inst.components.trader ~= nil
        and FindEntity(inst, TRADE_DIST, function(target) return inst.components.trader:IsTryingToTradeWithMe(target) end, GETTRADER_MUST_TAGS)
        or nil
end

local function KeepTraderFn(inst, target)
    return inst.components.trader ~= nil
        and inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GoHomeAction(inst)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil

    if home ~= nil and ((home.components.burnable ~= nil and home.components.burnable:IsBurning()) or
                        (home.components.freezable ~= nil and home.components.freezable:IsFrozen()) or
                        (home.components.health ~= nil and home.components.health:IsDead())) then
        home = nil
    end 

    return home ~= nil
        and home:IsValid()
        and home.components.childspawner ~= nil
        and (home.components.health == nil or not home.components.health:IsDead())
        and BufferedAction(inst, home, ACTIONS.GOHOME)
        or nil
end

function GoobahBrain:OnStart()
    local post_nodes = PriorityNode({
        DoAction(self.inst, function() return InvestigateAction(self.inst) end ),
            
        WhileNode(function() return (TheWorld.state.iscaveday or self.inst._quaking) and not self.inst.summoned end, "IsDay",
                DoAction(self.inst, function() return GoHomeAction(self.inst) end ) ),
        
        FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
    })

    local root =
    PriorityNode({
		BrainCommon.PanicTrigger(self.inst),
        Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST),
        post_nodes
    }, .25)
    self.bt = BT(self.inst, root)
end

function GoobahBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()))

end

return GoobahBrain