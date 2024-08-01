local Assets =
{ 
	Asset("ANIM", "anim/swap_maevesword.zip"),

    Asset("ATLAS", "images/inventoryimages/maevesword.xml"),
    Asset("IMAGE", "images/inventoryimages/maevesword.tex"),
}

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_maevesword", "swap_maevesword")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function OnUnequip(inst, owner) 
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal") 
end

local function SanityHeal(inst, owner)
	owner.components.sanity:DoDelta(1.5)
end

local function MainFunction()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("maevesword")
	inst.AnimState:SetBuild("swap_maevesword")
	inst.AnimState:PlayAnimation("idle")

	--weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    local swap_data = {sym_build = "swap_maevesword"}
    MakeInventoryFloatable(inst, "med", 0.05, {0.85, 0.45, 0.85}, true, 1, swap_data)

    inst.scrapbook_subcat = "tool"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "maevesword"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/maevesword.xml"
    
    inst:AddComponent("equippable")
    
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.HAMBAT_DAMAGE)
	inst.components.weapon:SetOnAttack(SanityHeal)

	MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/maevesword", MainFunction, Assets)
