local Assets =
{
    Asset("ANIM", "anim/hat_meeta.zip"),
    
    Asset("ATLAS", "images/inventoryimages/meetahat.xml"),
    Asset("IMAGE", "images/inventoryimages/meetahat.tex"),
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "hat_meeta", "swap_hat")
	owner.AnimState:Show("HAT")
	owner.AnimState:Show("HAIR_HAT")
	owner.AnimState:Hide("HAIR_NOHAT")
	owner.AnimState:Hide("HAIR")
	
	if owner:HasTag("player") then
		owner.AnimState:Hide("HEAD")
		owner.AnimState:Show("HEAD_HAT")
	end
	
	if inst.components.fueled ~= nil then
		inst.components.fueled:StartConsuming()
	end
end

local function OnUnequip(inst, owner) 
	owner.AnimState:ClearOverrideSymbol("swap_hat")
	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAIR_HAT")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")

	if owner:HasTag("player") then
		owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAT")
	end
	
	if inst.components.fueled ~= nil then
		inst.components.fueled:StopConsuming()
	end
end

local function MainFunction()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("hat_meeta")
    inst.AnimState:SetBuild("hat_meeta")
    inst.AnimState:PlayAnimation("anim")

	inst:AddTag("waterproofer")
	
	MakeInventoryFloatable(inst, "small", 0.1, 1.12)
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "meetahat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/meetahat.xml"
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.USAGE
	inst.components.fueled:InitializeFuelLevel(480*5)
	inst.components.fueled:SetDepletedFn(inst.Remove)

	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0.2)

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/meetahat", MainFunction, Assets)
