local Assets = {
    Asset("ANIM", "anim/swap_echogun.zip"),

    Asset("ATLAS", "images/inventoryimages/echogun.xml"),
    Asset("IMAGE", "images/inventoryimages/echogun.tex"),
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_echogun", "swap_echogun")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function CanFire(inst, doer, target, pos)
    if not doer.components.combat:CanTarget(target) or doer.components.combat:IsAlly(target) then
        target = FUNCS.FindTarget(doer, pos or target:GetPosition())
    end
    local flag = target ~= nil
    flag = flag and not target:IsInLimbo()
    flag = flag and target.entity:IsVisible()
    flag = flag and target.components.health ~= nil
    flag = flag and not target.components.health:IsDead()
    return flag
end

-- stolen from another mod
local function FindTarget(doer, pos)
    local x, y, z = pos:Get()
    local range = 4
    if doer.components.playercontroller.isclientcontrollerattached then
        range = 15
    end
    local minDist = nil;
    local target = nil;
    for k,v in pairs(TheSim:FindEntities(x, y, z, range, nil, {"wall"})) do
        if FUNCS.CheckTarget(doer.replica.combat, v) then
            local tmpDist = (pos - v:GetPosition()).magnitude
            if not minDist or tmpDist < minDist then
                minDist = tmpDist
                target = v
            end
        end
    end
    return target
end

local function CheckTarget(combat, target)
    return combat and combat:CanTarget(target) and not combat:IsAlly(target) and not target:HasTag("wall")
end
-- end stolen

local function OnFire(inst, doer, target, pos, homing)
    if not doer.components.combat:CanTarget(target) or doer.components.combat:IsAlly(target) then
        target = FindTarget(doer, pos or target:GetPosition())
    end
    local proj = SpawnPrefab("echobullets")
    local damage = TUNING.CANE_DAMAGE
    local multiplier = 1  -- Is her gun OP?
    proj.components.weapon:SetDamage(damage * multiplier)
    proj:AddComponent("inventoryitem")
    proj.Transform:SetPosition(doer.Transform:GetWorldPosition())
    proj.components.inventoryitem.owner = doer
    proj._effect = SpawnPrefab("lanternlight") or SpawnPrefab("lanternfire")
    proj._effect.Transform:SetPosition(doer.Transform:GetWorldPosition())
    proj._effect.Light:Enable(true)
    proj._effect.Light:SetRadius(1)
    proj._effect.Light:SetFalloff(4)
    proj._effect.Light:SetIntensity(0.25)
    proj._effect:DoPeriodicTask(0.1,proj._effect.Remove)
    proj.components.projectile:SetHoming(homing)
    proj.components.projectile:Throw(proj, target, doer)
    proj:Show()
end

local function MainFunction()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("echogun")
    inst.AnimState:SetBuild("swap_echogun")
    inst.AnimState:PlayAnimation("idle")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    local swap_data = {sym_build = "swap_echogun"}
    MakeInventoryFloatable(inst, "med", 0.05, {0.85, 0.45, 0.85}, true, 1, swap_data)

    inst.scrapbook_subcat = "tool"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    MakeHauntableLaunch(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "echogun"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/echogun.xml"

    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)
    inst.components.weapon:SetRange(15, 30)
    inst.components.weapon:SetProjectile("echobullet")
    inst.components.weapon:SetOnAttack(nil)
    inst.components.weapon:SetOnProjectileLaunch(OnFire)


    return inst
end

return Prefab("common/inventory/echogun", MainFunction, Assets)