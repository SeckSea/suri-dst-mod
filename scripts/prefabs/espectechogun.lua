local assets =
{
    Asset("ANIM", "anim/swap_echogun.zip"),

	Asset("ATLAS", "images/inventoryimages/echogun.xml"),
    Asset("IMAGE", "images/inventoryimages/echogun.tex"),
}

local prefabs =
{
	"slingshotammo_rock_proj",
}

local SCRAPBOOK_DEPS =
{
    "slingshotammo_rock",
    "slingshotammo_gold",
    "slingshotammo_marble",
    "slingshotammo_thulecite",
    "slingshotammo_freeze",
    "slingshotammo_slow",
    "slingshotammo_poop",
    "trinket_1",
}

local PROJECTILE_DELAY = 2 * FRAMES

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    owner.AnimState:OverrideSymbol("swap_object", "swap_echogun", "swap_echogun")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

local function OnEquipToModel(inst, owner, from_ground)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

local function OnProjectileLaunched(inst, attacker, target)
	if inst.components.container ~= nil then
		local ammo_stack = inst.components.container:GetItemInSlot(1)
		local item = inst.components.container:RemoveItem(ammo_stack, false)
		if item ~= nil then
			if item == ammo_stack then
				item:PushEvent("ammounloaded", {slingshot = inst})
			end

			item:Remove()
		end
	end
end

local function OnAmmoLoaded(inst, data)
	if inst.components.weapon ~= nil then
		if data ~= nil and data.item ~= nil then
			inst.components.weapon:SetProjectile(data.item.prefab.."_proj")
			inst:AddTag("ammoloaded")
			data.item:PushEvent("ammoloaded", {slingshot = inst})
		end
	end
end

local function OnAmmoUnloaded(inst, data)
	if inst.components.weapon ~= nil then
		inst.components.weapon:SetProjectile(nil)
		inst:RemoveTag("ammoloaded")
		if data ~= nil and data.prev_item ~= nil then
			data.prev_item:PushEvent("ammounloaded", {slingshot = inst})
		end
	end
end

local floater_swap_data = {sym_build = "swap_echogun"}

local function MainFunction()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("echogun")
    inst.AnimState:SetBuild("echogun")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("rangedweapon")
    inst:AddTag("slingshot")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --inst.projectiledelay = PROJECTILE_DELAY

    MakeInventoryFloatable(inst, "med", 0.075, {0.5, 0.4, 0.5}, true, -7, floater_swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_adddeps = SCRAPBOOK_DEPS
    inst.scrapbook_weapondamage = { TUNING.SLINGSHOT_AMMO_DAMAGE_ROCKS, TUNING.SLINGSHOT_AMMO_DAMAGE_MAX }

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.restrictedtag = "fearless_leader"
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnEquipToModel(OnEquipToModel)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(TUNING.SLINGSHOT_DISTANCE, TUNING.SLINGSHOT_DISTANCE_MAX)
    inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)
    inst.components.weapon:SetProjectile(nil)
	inst.components.weapon:SetProjectileOffset(1)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("slingshot")
	inst.components.container.canbeopened = false
    inst.components.container.stay_open_on_hide = true
    inst:ListenForEvent("itemget", OnAmmoLoaded)
    inst:ListenForEvent("itemlose", OnAmmoUnloaded)

    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/echogun", MainFunction, assets, prefabs)