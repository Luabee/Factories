local plymeta = FindMetaTable("Player")
util.AddNetworkString("fact_load")

hook.Add("PlayerInitialSpawn","fact_loadEverything",function(ply)
	ply.Loading = true
	fact.Create(ply)
	timer.Simple(3,function()
		ply:LoadMoney()
		ply:LoadFactory()
		ply:LoadInventory()
		ply.Loading = false
	end)
end)

hook.Add("EntityRemoved","fact_saveEverything",function(ply)
	if ply:IsPlayer() then
		
		--save all shit.
		ply:SaveMoney()
		ply:SaveInventory()
		ply:SaveFactory()
		
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
	end
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
concommand.Add("fact_resetmoney",function(ply,c,a)
	if IsValid(ply) then
		ply:SetMoney(GetConVarNumber("fact_money_start"))
		ply:SaveMoney()
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
	file.CreateDir("factories/players/"..self:SteamID64())
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
				e:Load(v)
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
		file.Delete("factories/players/"..ply:SteamID64().."/factory.txt")
		ply:ConCommand("retry")
	end
end)

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
	if istable(loadtbl) then
		for k,v in pairs(loadtbl) do
			self:AddInvItem(v.class,v.quan)
		end
	end
	self:SyncInventory()
end
concommand.Add("fact_resetinv",function(ply,c,a)
	if IsValid(ply) then
		ply:ResetInventory()
		file.Delete("factories/players/"..ply:SteamID64().."/inv.txt")
		-- ply:ConCommand("retry")
	end
end)


