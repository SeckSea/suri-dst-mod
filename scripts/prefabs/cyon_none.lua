local assets =
{
	Asset( "ANIM", "anim/cyon.zip" ),
	Asset( "ANIM", "anim/ghost_cyon_build.zip" ),
}

local skins =
{
	normal_skin = "cyon",
	ghost_skin = "ghost_cyon_build",
}

return CreatePrefabSkin("cyon_none",
{
	base_prefab = "cyon",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"cyon", "CHARACTER", "BASE"},
	build_name_override = "cyon",
	rarity = "Character",
})