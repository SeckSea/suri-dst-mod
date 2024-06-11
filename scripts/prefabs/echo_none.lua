local assets =
{
	Asset( "ANIM", "anim/echo.zip" ),
	Asset( "ANIM", "anim/ghost_echo_build.zip" ),
}

local skins =
{
	normal_skin = "echo",
	ghost_skin = "ghost_echo_build",
}

return CreatePrefabSkin("echo_none",
{
	base_prefab = "echo",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"echo", "CHARACTER", "BASE"},
	build_name_override = "echo",
	rarity = "Character",
})