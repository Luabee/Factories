local plymeta = FindMetaTable("Player")
util.AddNetworkString("fact_load")

local function report(err)
	ErrorNoHalt("[ERROR! Failed to load player's Factory/Money/Inventory/Research!]: "..err)
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

hook.Add("PlayerDisconnected","fact_saveEverything",function(ply)
	-- if ply:IsPlayer() then
		--save all shit.
		ply:SaveMoney()
		ply:SaveInventory()
		ply:SaveFactory()
		ply:SaveResearch()
		
		--remove all ents.
		for k,v in pairs(ply:GetFactory().Ents)do
			if IsValid(v) then
			-- if v.GetMaker and v:GetMaker() == ply or v.Owner == ply then
				v:Remove()
			-- end
			end
		end
		for k,v in pairs(ply:GetFactory().Walls)do
			if IsValid(v) then
			-- if v.GetMaker and v:GetMaker() == ply or v.Owner == ply then
				v:Remove()
			-- end
			end
		end
	-- end
end)

function plymeta:LoadMoney()
	self:SetMoney(self:GetPData("fact_money", GetConVarNumber("fact_money_start")),true)
end
function plymeta:SaveMoney()
	self:SetPData("fact_money", self:GetMoney())
end
timer.Create("fact_save",10,0,function()
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) then
			v:SaveMoney()
			v:SaveInventory()
		end
	end
end)


function plymeta:SaveFactory()
	local fac = self:GetFactory()
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
	file.CreateDir("factories/players/"..self:SteamID64()) --todo: attempt to concat nil value error fix
	file.Write("factories/players/"..self:SteamID64().."/factory.txt", json) --todo: add mysql
	
	return json
end
function plymeta:LoadFactory()
	local json = file.Read("factories/players/"..self:SteamID64().."/factory.txt","DATA")
	local loadtbl = util.JSONToTable(json or "")
	if istable(loadtbl) and #loadtbl.ents != 0 then
		
		self:SetPos(Vector(0,0,5) + grid.ToVector(self:GetFactory(), unpack(loadtbl.pos)))
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
					net.Send(self)
				end)
			end
		end
	else
		self:ResetFactory()
	end
end
concommand.Add("fact_resetall",function(ply,c,a)
	if IsValid(ply) then
		ply:ResetFactory()
		ply:ResetResearch()
		ply:SetMoney(GetConVarNumber("fact_money_start"))
		ply:SaveMoney()
		file.Delete("factories/players/"..ply:SteamID64().."/factory.txt")
		-- ply:ConCommand("retry")
	end
end)

function plymeta:SaveResearch()
	local savetbl = {sel=self:GetResearchCategory(),res={}}
	for k,v in pairs(research.List) do
		savetbl.res[k] = self:GetResearch(k)
	end
	local json = util.TableToJSON(savetbl)
	file.CreateDir("factories/players/"..self:SteamID64())
	file.Write("factories/players/"..self:SteamID64().."/research.txt", json) --todo: add mysql
	
	return json
end
function plymeta:LoadResearch()
	local json = file.Read("factories/players/"..self:SteamID64().."/research.txt","DATA")
	local loadtbl = util.JSONToTable(json or "")
	if istable(loadtbl) and #loadtbl.res != 0 then
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
	file.CreateDir("factories/players/"..self:SteamID64())
	file.Write("factories/players/"..self:SteamID64().."/inv.txt", json) --todo: add mysql
	
	return json
end
function plymeta:LoadInventory()
	local json = file.Read("factories/players/"..self:SteamID64().."/inv.txt","DATA")
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
		-- file.Delete("factories/players/"..ply:SteamID64().."/inv.txt")
		-- -- ply:ConCommand("retry")
	-- end
-- end)


