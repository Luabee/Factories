
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include( 'shared.lua' )

loadGMFiles("sv_")

local _, folders = file.Find("factories/gamemode/factories/*","LUA")
for k,fold in pairs(folders) do
	-- print(fold)
	local files = file.Find("factories/gamemode/factories/"..fold.."/*.lua","LUA")
	for k2, f in SortedPairs(files) do
		if !f:match("sv_") then
			AddCSLuaFile("factories/"..fold.."/"..f)
			-- print("factories/"..fold.."/"..f)
		end
	end
end


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

function GM:PlayerSpawn(ply)
	self.BaseClass.PlayerSpawn(self,ply)
	ply:CrosshairDisable()
	ply:SetWalkSpeed(200)
	ply:SetRunSpeed(ply:GetWalkSpeed())
end

function GM:PlayerSetModel(ply)
	ply:SetModel( "models/player/kleiner.mdl" )
end