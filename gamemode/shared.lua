
GM.Name			= "Factories"
GM.Author		= "Bobblehead"
GM.Email		= "luabeegaming@gmail.com"
GM.Website		= "luabee.com"
GM.TeamBased	= false


//Convars:
ConVars = {}
	ConVars.Server = {}
	ConVars.Server.startmoney = CreateConVar("fact_money_start", 1000, { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE}, "Sets money new players start with.")
	ConVars.Server.collisions = CreateConVar("fact_collisions", 0, { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE}, "Whether players collide with certain factory parts.")
	
if CLIENT then
	ConVars.Client = {}
	ConVars.Client.inviteTime = CreateClientConVar("fact_invite_time", 30, true, false, "How long visiting invitations should stay on the screen.")
	
end

-- function GM:ShouldCollide( ent1, ent2 )
	-- if ( IsValid( ent1 ) and IsValid( ent2 ) and ent1:IsPlayer() and ent2:IsPlayer() ) then return false end
	-- return true
-- end

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

function table.IsEmpty(tbl)
	return next(tbl) == nil
end

--DEBUG:
E = function(i) return Entity(i or 1) end

--Load all files.
function loadGMFiles(ext)
	local _, folders = file.Find("factories/gamemode/factories/*","LUA")
	for k,fold in pairs(folders) do
		-- print(fold)
		local files = file.Find("factories/gamemode/factories/"..fold.."/"..ext.."*.lua","LUA")
		for k2, f in SortedPairs(files) do
			-- print(" ",f)
			include("factories/"..fold.."/"..f)
		end
	end
end
loadGMFiles("sh_")
