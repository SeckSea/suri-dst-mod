local assets =
{
	Asset( "ANIM", "anim/maeve.zip" ),
	Asset( "ANIM", "anim/ghost_maeve_build.zip" ),
}

local skins =
{
	normal_skin = "maeve",
	ghost_skin = "ghost_maeve_build",
}

return CreatePrefabSkin("maeve_none",
{
	base_prefab = "maeve",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"maeve", "CHARACTER", "BASE"},
	build_name_override = "maeve",
	rarity = "Character",
})