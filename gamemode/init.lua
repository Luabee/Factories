
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include( 'shared.lua' )

loadGMFiles("sv_")


--[[---------------------------------------------------------
	Show the default team selection screen
-----------------------------------------------------------]]
function GM:ShowTeam( ply )
	
	-- For clientside see cl_pickteam.lua
	-- ply:SendLua( "GAMEMODE:ShowTeam()" )

end



function GM:EntityTakeDamage( )
	return true
end
function GM:CanPlayerSuicide()
	return false
end

function GM:PlayerInitialSpawn(ply)
	ply:SetStepSize(5)
	ply:SetJumpPower(0)
	ply:SetHull(Vector(-5,-5,0),Vector(5,5,64))
end

function GM:PlayerSetModel(ply)
	ply:SetModel( "models/player/kleiner.mdl" )
	ply:CrosshairDisable()
	ply:SetWalkSpeed(200)
	ply:SetRunSpeed(ply:GetWalkSpeed())
end