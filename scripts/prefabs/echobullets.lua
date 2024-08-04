local assets =
{
    Asset("ANIM", "anim/slingshotammo.zip"),
}

local assets =
{
    Asset("ANIM", "anim/slingshotammo.zip"),
}


local assets =
{
    Asset("ANIM", "anim/slingshotammo.zip"),
}

local function onThrown(inst, owner, target, attacker)
    inst:AddTag("NOCLICK")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
end

local function ImpactFx(inst, attacker, target)
    if target ~= nil and target:IsValid() then
		local impactfx = SpawnPrefab("slingshotammo_hitfx_rock")
		impactfx.Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

local function OnAttack(inst, attacker, target)
    if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        ImpactFx(inst, attacker, target)
    end
end

local function MainFunction()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst:Hide()

    inst.AnimState:SetBank("echobullets")
    inst.AnimState:SetBuild("echobullets")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.entity:AddNetwork()
    inst.Transform:SetFourFaced()
    MakeProjectilePhysics(inst)
    inst.AnimState:SetBank("slingshotammo")
    inst.AnimState:SetBuild("slingshotammo")
    inst.AnimState:PlayAnimation("spin_loop", true)
    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SLINGSHOT_AMMO_DAMAGE_ROCKS)
    inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(25)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnHitFn(inst.Remove)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(onThrown)
    inst.components.projectile.range = 30
    inst.components.projectile.has_damage_set = true

    return inst
end

return Prefab("common/inventory/echobullets", MainFunction, assets)
