local plymeta = FindMetaTable("Player")
util.AddNetworkString("fact_load")

local function report(err)
	ErrorNoHalt("[ERROR! Failed to load player's data!]: "..err)
	debug.Trace()
	-- ErrorNoHalt(debug.traceback( nil, "[Failed to load player's Factory/Money/Inventory/Research!]"..err, 1 ))
end
hook.Add("PlayerInitialSpawn","fact_loadEverything",function(ply)
	ply.Loading = true
	fact.Create(ply)
	timer.Simple(3,function()
		xpcall( ply.LoadMoney, report, ply )
		xpcall( ply.LoadFactory, report, ply)
		xpcall( ply.LoadInventory, report, ply)
		xpcall( ply.LoadResearch, report, ply)
		ply.Loading = false
	end)
end)

hook.Add("ShutDown","fact_saveEverything",function()
	for k,ply in pairs(player.GetAll())do
		ply:SaveMoney()
		ply:SaveInventory()
		ply:SaveFactory()
		ply:SaveResearch()
	end
end)

hook.Add("PlayerDisconnected","fact_saveEverything",function(ply)
	-- if ply:IsPlayer() then
		--save all shit.
		ply:SaveMoney()
		ply:SaveInventory()
		ply:SaveFactory()
		ply:SaveResearch()
		
		ply:RemoveFactory()
	-- end
end)

function plymeta:LoadMoney()
	local amt = tonumber(file.Read("factories/players/"..(self:SteamID64() or 0).."/money.txt","DATA") or ConVars.Server.startmoney:GetFloat())
	
	self:SetMoney(amt)
end
function plymeta:SaveMoney()
	file.CreateDir("factories/players/"..(self:SteamID64() or 0))
	local money = self:GetMoney()
	if money >= 0 then
		file.Write("factories/players/"..(self:SteamID64() or 0).."/money.txt",money) --todo: add mysql	
	end
end
timer.Create("fact_save_money",10,0,function()
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) then
			v:SaveMoney()
			v:SaveInventory()
		end
	end
end)


function plymeta:SaveFactory()
	local fac = self:GetFactory()
	if IsValid(self:GetVisiting()) then return end
	
	local savetbl = {
		ents = {},
		pos = {self:GetPos():ToGrid(fac)},
	}
	for k,v in pairs(fac.Ents) do
		if !IsValid(v) then continue end
		local tbl = {class=v:GetItemClass(),pos = {v:GetGridPos()}}
		table.insert(savetbl.ents, v:Save(tbl))
	end
	local json = util.TableToJSON(savetbl)
	file.CreateDir("factories/players/"..(self:SteamID64() or 0))
	file.Write("factories/players/"..(self:SteamID64() or 0).."/factory.txt", json) --todo: add mysql
	
	return json
end
function plymeta:LoadFactory()
	local json = file.Read("factories/players/"..(self:SteamID64() or 0).."/factory.txt","DATA")
	local loadtbl = util.JSONToTable(json or "")
	local fac = fact.Create(self)
	if istable(loadtbl) and #loadtbl.ents != 0 then
		
		self:SetPos(Vector(0,0,5) + grid.ToVector(fac, unpack(loadtbl.pos)))
		for k,v in pairs(loadtbl.ents) do
			local e = fact.PlaceObject(self,v.class,v.pos[1],v.pos[2],v.yaw,true)
			if e then
				local succ, err = pcall(e.Load, e, v)
				if !succ then
					ErrorNoHalt("ERROR! Failed to load "..(v.class or "[no class specified]")..". Error: "..(err or "(no error given)").."\n")
				end
				timer.Simple(1,function()
					net.Start("fact_load")
						net.WriteEntity(e)
						net.WriteTable(v)
					net.Send(fact.GetPlayers(fac))
				end)
			end
		end
	else
		self:ResetFactory()
	end
	return fac
end
concommand.Add("fact_resetall",function(ply,c,a)
	if IsValid(ply) then
		ply:ResetFactory()
		ply:ResetResearch()
		ply:SetMoney(ConVars.Server.startmoney:GetFloat())
		ply:SaveMoney()
		file.Delete("factories/players/"..(ply:SteamID64() or 0).."/factory.txt")
		-- ply:ConCommand("retry")
	end
end)

function plymeta:SaveResearch()
	local savetbl = {sel=self:GetResearchCategory(),res={}}
	for k,v in pairs(research.List) do
		savetbl.res[k] = self:GetResearch(k)
	end
	local json = util.TableToJSON(savetbl)
	file.CreateDir("factories/players/"..(self:SteamID64() or 0))
	file.Write("factories/players/"..(self:SteamID64() or 0).."/research.txt", json) --todo: add mysql
	
	return json
end
function plymeta:LoadResearch()
	local json = file.Read("factories/players/"..(self:SteamID64() or 0).."/research.txt","DATA")
	local loadtbl = util.JSONToTable(json or "")
	if istable(loadtbl) and table.Count(loadtbl.res) != 0 then
		for k,v in pairs(loadtbl.res) do
			self:SetResearch(v,k)
		end
		self:SetResearchCategory(loadtbl.sel)
	else
		self:ResetResearch()
	end
end

function plymeta:SaveInventory()
	local savetbl = {}
	for k,v in pairs(self:GetInventory()) do
		local tbl = {class = v.ClassName, quan = v.Quantity}
		table.insert(savetbl, tbl)
	end
	local json = util.TableToJSON(savetbl)
	file.CreateDir("factories/players/"..(self:SteamID64() or 0))
	file.Write("factories/players/"..(self:SteamID64() or 0).."/inv.txt", json) --todo: add mysql
	
	return json
end
function plymeta:LoadInventory()
	local json = file.Read("factories/players/"..(self:SteamID64() or 0).."/inv.txt","DATA")
	local loadtbl = util.JSONToTable(json or "")
	self.Inventory = {}
	if istable(loadtbl) and #loadtbl != 0 then
		for k,v in pairs(loadtbl) do
			self:AddInvItem(v.class,v.quan)
		end
	else
		self:ResetInventory()
	end
	self:SyncInventory()
end
-- concommand.Add("fact_resetinv",function(ply,c,a)
	-- if IsValid(ply) and ply:IsAdmin() then
		-- ServerLog("Resetting "..ply:Nick().."'s inventory...\n")
		-- ply:ResetInventory()
		-- file.Delete("factories/players/"..(self:SteamID64() or 0).."/inv.txt")
		-- -- ply:ConCommand("retry")
	-- end
-- end)


