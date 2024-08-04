local Assets =
{ 
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

	inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "images/inventoryimages/echogun.tex"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/echogun.xml"
    
    inst:AddComponent("equippable")
    
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)

	MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/echogun", MainFunction, Assets)