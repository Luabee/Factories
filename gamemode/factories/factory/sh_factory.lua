
local plymeta = FindMetaTable("Player")
fact = fact or {}
fact.Factories = {}
fact.MaxFactorySize = 100
fact.FactoriesPerLayer = 3
fact.LowestZ = -12000
fact.ZHeight = 200
-- fact.Layers = {}

if SERVER then
	hook.Add("PlayerInitialSpawn","fact_createFactObj",function(ply)
		ply:ResetFactory()
	end)
	hook.Add("EntityRemoved","fact_removeFact",function(ent)
		if ent:IsPlayer() then
			for k,v in pairs(ents.GetAll())do
				if v.GetMaker and v:GetMaker() == ent or v.Owner == ent then
					v:Remove()
				end
			end
		end
	end)
else
	hook.Add("InitPostEntity","fact_createFactObj",function()
		fact.Create(LocalPlayer())
	end)
end

function plymeta:ResetFactory()
	if self:GetFactory() then
		for k,v in pairs(self:GetFactory().Ents)do
			v:Remove()
		end
	end
	
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
		local gridx, gridy = (pos + Vector( -grid.Size*.5, -grid.Size*.5, -1)):ToGrid(fac)
		grid.AddFloor(fac, gridx, gridy, 4, 4, floor)
		self:SetPos(pos+Vector(-grid.Size*.5,-grid.Size*.5,5))
		
		self:GiveInvItem("fact_floor")
		self:GiveInvItem("fact_floor")
		self:GiveInvItem("fact_floor")
		self:GiveInvItem("fact_floor")
		self:GiveInvItem("fact_inserter")
		self:GiveInvItem("fact_inserter")
		self:GiveInvItem("fact_inserter")
		self:GiveInvItem("fact_inserter")
		self:GiveInvItem("fact_importer")
		self:GiveInvItem("fact_importer")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_conveyor")
		self:GiveInvItem("fact_assembler")
		self:GiveInvItem("fact_assembler")
		self:GiveInvItem("fact_pallet")
		self:GiveInvItem("fact_pallet")
		self:GiveInvItem("fact_miner")
		self:GiveInvItem("fact_miner")
		self:SyncInventory()
	end)
end

function plymeta:GetFactory()
	return self.Factory
end

function fact.Create(ply)
	local f = {}
	
	f.Owner = ply
	
	f.Grid = {}
	f.Floors = {}
	for i=1, fact.MaxFactorySize do
		f.Floors[i] = {}
		f.Grid[i] = {}
	end
	
	f.Ents = {}
	f.Walls = {}
	f.Root = fact.GetFactoryRoot()
	table.insert(fact.Factories, f)
	
	ply.Factory = f
	return f
end

function fact.GetFactoryRoot()
	local count = player.GetCount()
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
		v:Remove()
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