local assets =
{
	Asset( "ANIM", "anim/meeta.zip" ),
	Asset( "ANIM", "anim/ghost_meeta_build.zip" ),
}

local skins =
{
	normal_skin = "meeta",
	ghost_skin = "ghost_meeta_build",
}

return CreatePrefabSkin("meeta_none",
{
	base_prefab = "meeta",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"meeta", "CHARACTER", "BASE"},
	build_name_override = "meeta",
	rarity = "Character",
})