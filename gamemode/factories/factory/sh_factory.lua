
local plymeta = FindMetaTable("Player")
fact = fact or {}
fact.Factories = {}
fact.MaxFactorySize = 100
fact.FactoriesPerLayer = 3
fact.LowestZ = -12000
fact.ZHeight = 500
-- fact.Layers = {}

if CLIENT then
	hook.Add("Initialize","fact_loading",function()
		fact.Loading = true
	end)
	hook.Add("InitPostEntity","fact_createFactObj",function()
		for k,v in pairs(player.GetAll()) do
			fact.Create(v)
		end
		fact.Loading = false
	end)
	net.Receive("fact_initialSpawn",function()
		local ply = net.ReadEntity()
		if IsValid(ply) and ply != LocalPlayer() then
			fact.Create(ply)
		end
	end)
else
	util.AddNetworkString("fact_initialSpawn")
	hook.Add("PlayerInitialSpawn","fact_createFactObj",function(ply)
		net.Start("fact_initialSpawn")
			net.WriteEntity(ply)
		net.SendOmit(ply)
	end)
	hook.Add("PlayerTick","fact_nofall",function(ply,mv)
		if mv:GetOrigin().z < ply:GetFactory().Root.z-5 then
			for k1,v1 in pairs(ply:GetFactory().Floors)do
				for k2,v2 in pairs(v1)do
					if IsValid(v2) then
						mv:SetOrigin(v2:GetPos()+Vector(0,0,5))
					end
				end
			end
		end
	end)
end

function plymeta:ResetFactory()
	if IsValid(self:GetVisiting()) then return end
	
	if self:GetFactory() then
		self:RemoveFactory()
	end
	for k,v in pairs(self:GetInventory())do
		self:RemoveInvItem(v)
	end
	self.Inventory = {}
	
	local fac = fact.Create(self)
	-- local pos = fac.Root + Vector((fact.MaxFactorySize-4)*grid.Size, (fact.MaxFactorySize-4)*grid.Size, -1) 
	local pos = fac.Root + Vector(fact.MaxFactorySize*grid.Size/2, fact.MaxFactorySize*grid.Size/2, -1) 
	local floor = ents.Create("fact_floor")
	floor:SetMaker(self)
	floor:SnapToGrid(pos)
	floor:SetPos(floor:GetPos() + Vector( -grid.Size*1.5, -grid.Size*1.5, -1))
	floor:Spawn()
	floor.Item = items.Create("fact_floor")
	floor:SetItemClass("fact_floor")
	table.insert(fac.Ents, floor)
	
	timer.Simple(1,function()
		if IsValid(self) then
			local gridx, gridy = (pos + Vector( -grid.Size*.5, -grid.Size*.5, -1)):ToGrid(fac)
			grid.AddFloor(fac, gridx, gridy, 4, 4, floor)
			self:SetPos(pos+Vector(-grid.Size*.5,-grid.Size*.5,5))
			-- self:SendLua("fact.Loading = false")
			
			self:ResetInventory()
		end
	end)
end

function fact.PlaceObject(ply,item,gridX, gridY,rot,nosound)
	local fac = ply:GetFactory()
	local vec = grid.ToVector(fac, gridX, gridY)	
	if isstring(item) then
		item = items.Create(item)
	end
	
	if item and item.EntClass then
		
		local e = scripted_ents.GetStored(item.EntClass)
		if e then e = e.t else return end
		local dim,floor = e.Dimensions or {w=1, h=1}, e.IsFloor
		local can = (floor and grid.CanPlaceFloor(fac,gridX, gridY, dim.w, dim.h)) or (not floor and grid.CanPlace(fac, gridX, gridY, dim.w, dim.h))
		
		if can then
			
			
			local ent = ents.Create(item.EntClass)
			ent:SetPos(vec + ent.GridOffset)
			local ang = ent.AngOffset-- - Angle(0,90,0)
			if ent.Rotates then
				ang = ang + Angle(0,rot,0)
			end
			ent:SetAngles(ang)
			table.insert(fac.Ents, ent)
			ent:SetMaker(fac.Owner)
			ent:SetGridPos(gridX, gridY)
			ent.Item = item
			ent:SetItemClass(item.ClassName)
			ent:SetLevel(item.Level or 0)
			ent:Spawn()
			if not nosound then
				sound.Play( ent:GetPlaceSound(), ent:GetPos(), 75, 100, 1 )
			end
			-- debugoverlay.Box(vec, Vector(-grid.Size/2, -grid.Size/2, -5), Vector(grid.Size/2, grid.Size/2, 5), 20, Color(0,0,255,100))
			
			
			if floor then
				grid.AddFloor(fac,gridX, gridY, dim.w, dim.h, ent)
			else
				grid.AddItem(fac,gridX, gridY, dim.w, dim.h, ent)
			end
			
			return ent
			
		end
		
		
	end
end

function fact.GetPlayers(fac)
	local t = {fac.Owner}
	if fac.Owner and fac.Owner.Visitors then
		for k, v in pairs(fac.Owner.Visitors) do
			t[#t+1] = k
		end
	end
	return t
end

if SERVER then
	util.AddNetworkString("fact_syncfactory")
	util.AddNetworkString("fact_syncfactory_tell")
	net.Receive("fact_syncfactory",function(len,ply)
		if ply:GetFactory().Owner != ply then 
			net.Start("fact_syncfactory_tell")
				net.WriteBool(false)
			net.Send(ply)
			return
		end
		ply:SyncFactory()
	end)
	function plymeta:SyncFactory()
		if self:GetFactory().Owner != self then return end
		if self.FactorySync then return end
		
		local pos = self:GetPos()
		local p = {}
		for k,v in pairs(fact.GetPlayers(self:GetFactory()))do
			if IsValid(v) then
				p[v]=v:GetPos()
				net.Start("fact_syncfactory_tell")
					net.WriteBool(true)
				net.Send(v)
			end
		end
		
		self:SaveFactory()
		self:SetMoveType(MOVETYPE_NOCLIP)
		
		self.FactorySync = true
		self:RemoveFactory()
		self:SyncInventory()
		
		timer.Simple(1,function()
			local root = self:GetFactory().Root
			local fac = self:LoadFactory()
			fac.Root = root
			for k,v in pairs(p)do
				k.Factory = fac
				net.Start("fact_setfactory")
					net.WriteEntity(k)
					net.WriteTable(fac)
				net.Send(k)
				k:SetPos(v)
			end
			self:SetPos(pos)
			self:SetMoveType(MOVETYPE_WALK)
			self.FactorySync = false
			
			net.Start("fact_syncfactory_tell")
				net.WriteBool(false)
			net.Send(fact.GetPlayers(fac))
			net.Start("fact_syncfactory")
			net.Send(self)
			-- net.Send(fac:GetPlayers())
			
		end)
	end
	
	function plymeta:RemoveFactory()
		local fac = self:GetFactory()
		if fac.Owner != self then return end
		for k,v in pairs(fac.Ents)do
			if IsValid(v) then
				v:Remove()
			end
		end
		for k,v in pairs(fac.Walls)do
			if IsValid(v) then
				v:Remove()
			end
		end
	end
else
	function fact.Sync()
		LocalPlayer().FactorySync = true
		net.Start("fact_syncfactory")
		net.SendToServer()
	end
	concommand.Add("fact_sync",function() timer.Simple(.01,fact.Sync) end)
end

function plymeta:GetFactory()
	return self.Factory
end

function fact.Create(ply, new)
	local f
	if new then
		f = {}
	else
		if ply:GetFactory() then
			table.Empty(ply:GetFactory())
			f = ply:GetFactory()
		else
			f = {}
		end
	end
	
	f.Owner = ply
	
	f.Grid = {}
	f.Floors = {}
	for i=1, fact.MaxFactorySize do
		f.Floors[i] = {}
		f.Grid[i] = {}
	end
	
	f.Ents = {}
	f.Walls = {}
	f.Root = fact.GetFactoryRoot(ply)
	table.insert(fact.Factories, f)
	
	ply.Factory = f
	return f
end

function fact.GetFactoryRoot(ply)
	local count = ply:EntIndex()
	-- local count = player.GetCount()
	local x = (count-1) % fact.FactoriesPerLayer --+ 1
	local y = math.floor((count-1)/fact.FactoriesPerLayer) % fact.FactoriesPerLayer --+ 1
	local z = math.floor((count-1) / (fact.FactoriesPerLayer ^ 2)) --+ 1
	-- if SERVER and not IsValid(fact.Layers[z]) then
		-- fact.Layers[z] = ents.Create("map_floor")
		-- fact.Layers[z]:SetPos(Vector(0,0,fact.LowestZ + z*fact.ZHeight - 149))
		-- fact.Layers[z]:Spawn()
		-- fact.Layers[z]:Activate()
	-- end
	local off = 12000
	return Vector(math.roundToNearest(x*fact.MaxFactorySize*grid.Size - off, grid.Size), math.roundToNearest(y*fact.MaxFactorySize*grid.Size - off, grid.Size), fact.LowestZ + z*fact.ZHeight)
end

function fact.RebuildWalls(fac)
	if CLIENT then return end
	local f = fac.Floors
	
	for k,v in pairs(fac.Walls)do
		if IsValid(v) then
			v:Remove()
		end
	end
	
	local wallEnts = {}
	local walls = {}
	for x, col in pairs(f) do
		for y, floor in pairs(col) do
			if not IsValid(floor) then continue end
			
			if !IsValid(f[x][y-1]) then --right
				local wall = ents.Create("map_wall")
				wall.Owner = fac.Owner
				wall.Factory = fac
				wall:SetPos(grid.ToVector(fac,x,y) + Vector(0,-25,25/4))
				wall:SetAngles(Angle(90,90,0))
				wall:Spawn()
				-- wall:SetColor(color_black)
				wallEnts[#wallEnts+1] = wall
			end
				
			if !IsValid(f[x+1][y]) then --up
				local wall = ents.Create("map_wall")
				wall.Owner = fac.Owner
				wall.Factory = fac
				wall:SetPos(grid.ToVector(fac,x,y) + Vector(25,0,25/4))
				wall:SetAngles(Angle(90,0,0))
				wall:Spawn()
				-- wall:SetColor(Color(255,0,0))
				wallEnts[#wallEnts+1] = wall
			end	
			
			if !IsValid(f[x][y+1]) then --left
				local wall = ents.Create("map_wall")
				wall.Owner = fac.Owner
				wall.Factory = fac
				wall:SetPos(grid.ToVector(fac,x,y) + Vector(0,25,25/4))
				wall:SetAngles(Angle(90,90,0))
				wall:Spawn()
				-- wall:SetColor(Color(0,255,0))
				wallEnts[#wallEnts+1] = wall
			end
			
			if !IsValid(f[x-1][y]) then --down
				local wall = ents.Create("map_wall")
				wall.Owner = fac.Owner
				wall.Factory = fac
				wall:SetPos(grid.ToVector(fac,x,y) + Vector(-25,0,25/4))
				wall:SetAngles(Angle(90,0,0))
				-- wall:SetColor(Color(0,0,255))
				wall:Spawn()
				wallEnts[#wallEnts+1] = wall
			end
			
		end
	end
	
	fac.Walls = wallEnts
end