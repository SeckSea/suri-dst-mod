local assets =
{
	Asset( "ANIM", "anim/suri.zip" ),
	Asset( "ANIM", "anim/ghost_suri_build.zip" ),
}

local skins =
{
	normal_skin = "suri",
	ghost_skin = "ghost_suri_build",
}

return CreatePrefabSkin("suri_none",
{
	base_prefab = "suri",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"suri", "CHARACTER", "BASE"},
	build_name_override = "suri",
	rarity = "Character",
})