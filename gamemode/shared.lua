
GM.Name			= "Factories"
GM.Author		= "Bobblehead"
GM.Email		= "luabeegaming@gmail.com"
GM.Website		= "luabee.com"
GM.TeamBased	= false


//Convars:
ConVars = {}
	ConVars.Server = {}
	ConVars.Server.startmoney = CreateConVar("fact_money_start", 1000, { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE}, "Sets money new players start with.")
	
if CLIENT then
	ConVars.Client = {}
	-- ConVars.Client.autoCrouch = CreateClientConVar("fact_auto_crouch", 1, true, true, "Whether to automatically crouch while jumping and sprinting.")
	
end

function GM:ShouldCollide( ent1, ent2 )
	if ( IsValid( ent1 ) and IsValid( ent2 ) and ent1:IsPlayer() and ent2:IsPlayer() ) then return false end
	return true
end

function math.InRange(x,min,max)
	if min > max then 
		local temp = min
		min = max
		max = temp
	end
	return x >= min and x <= max
end

function table.RandomSeq(tbl)
	local rand = math.random( 1, #tbl )
	return tbl[rand], rand
end

--DEBUG:
E = function(i) return Entity(i or 1) end

--Load all files.
function loadGMFiles(ext)
	local _, folders = file.Find("gamemodes/factories/gamemode/factories/*","GAME")
	for k,fold in pairs(folders) do
		-- print(fold)
		local files = file.Find("gamemodes/factories/gamemode/factories/"..fold.."/"..ext.."*.lua","GAME")
		for k2, f in SortedPairs(files) do
			-- print(" ",f)
			include("factories/"..fold.."/"..f)
			if ext != "sv_" then
				AddCSLuaFile("factories/"..fold.."/"..f)
			end
		end
	end
end
loadGMFiles("sh_")
