local assets =
{
    Asset("ANIM", "anim/goldcoins.zip"),

    Asset("ATLAS", "images/inventoryimages/goldcoins.xml"),
    Asset("IMAGE", "images/inventoryimages/goldcoins.tex")
}

local function GoldBuff(inst, eater)
    --if eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
        --not (eater.components.health ~= nil and eater.components.health:IsDead()) and
        --not eater:HasTag("playerghost") and eater:HasTag("dragoobah") then
        --eater.components.debuffable:AddDebuff("gold_buff", "gold_buff")
    eater.components.combat.externaldamagemultipliers:SetModifier(inst, 2.0, "damage_from_gold")
    eater.components.combat.externaldamagetakenmultipliers:SetModifier(inst, 2.0, "defense_from_gold")
    --end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("goldcoins")
    inst.AnimState:SetBuild("goldcoins")
    inst.AnimState:PlayAnimation("idle")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
    inst:AddComponent("inspectable")
    inst:AddComponent("edible")
    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_LARGE
    inst.components.edible.sanityvalue = TUNING.SANITY_MED
    inst.components.edible.oneaten = function(inst, eater)
        --if eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
            --not (eater.components.health ~= nil and eater.components.health:IsDead()) and
            --not eater:HasTag("playerghost") then
                eater.components.combat.externaldamagemultipliers:SetModifier(inst, 1.2, "damage_from_gold")
        --end
    end
    
    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/goldcoins.xml"

    return inst
end

return Prefab("common/inventory/goldcoins", fn, assets)
