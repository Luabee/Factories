
grid = grid or {}
grid.Size = 190/4 --units in the grid.

if SERVER then
	util.AddNetworkString("fact_additem")
	util.AddNetworkString("fact_addfloor")
end

math.roundToNearest = function(value, roundTo) 
    return math.Round(value / roundTo) * roundTo;
end

function grid.SnapTo(fac, pos, y) --accepts x,y or a single vector.
	local x
	if y then
		x = pos
	else
		x = pos.x
		y = pos.y
	end
	
	local nx = math.roundToNearest(x, grid.Size)
	local ny = math.roundToNearest(y, grid.Size)
	
	return Vector(nx,ny,fac.Root.z)
end

local vec = FindMetaTable("Vector")
function vec:ToGrid(fac) --converts a vector into an integer x and y coord on a grid.
	self = grid.SnapTo(fac,self)
	--the root is the top left, smallest number.
	local x,y
	
	x = math.roundToNearest(self.x - fac.Root.x, grid.Size) / grid.Size
	y = math.roundToNearest(self.y - fac.Root.y, grid.Size) / grid.Size
	
	x = math.Clamp(x, 1, fact.MaxFactorySize)
	y = math.Clamp(y, 1, fact.MaxFactorySize)
	
	return x,y
	
end

function grid.ToVector(fac,x,y)
	local vec = Vector(fac.Root)
	vec.x = vec.x + x*grid.Size
	vec.y = vec.y + y*grid.Size
	return vec
end

function grid.AddItem(fac,x,y,w,h,ent)
	if not fac.Floors[x] then error("Tried to place a floor outside the bounds.") end
	
	if ent.SetGridPos then
		ent:SetGridPos(x,y)
	end
	
	for checkX = x, x-w+1, -1 do
		for checkY = y, y-h+1, -1 do
			fac.Grid[checkX][checkY] = ent
		end
	end
	if SERVER then
		timer.Simple(.1,function()
			net.Start("fact_additem")
				net.WriteEntity(fac.Owner)
				net.WriteEntity(ent)
				net.WriteUInt(x,16)
				net.WriteUInt(y,16)
				net.WriteUInt(w,3)
				net.WriteUInt(h,3)
			net.Broadcast()
		end)
	end
end
function grid.AddFloor(fac,x,y,w,h,ent)
	
	for checkX = x, x-w+1, -1 do
		for checkY = y, y-h+1, -1 do
			if not fac.Floors[checkX] then error("Tried to place a floor outside the bounds.") end
			fac.Floors[checkX][checkY] = ent
		end
	end
	
	if ent.SetGridPos then
		ent:SetGridPos(x,y)
	end
	
	fact.RebuildWalls(fac)
	
	if SERVER then
		timer.Simple(.1,function()
			net.Start("fact_addfloor")
				net.WriteEntity(fac.Owner)
				net.WriteEntity(ent)
				net.WriteUInt(x,16)
				net.WriteUInt(y,16)
				net.WriteUInt(w,3)
				net.WriteUInt(h,3)
			net.Broadcast()
		end)
	end
end
if CLIENT then
	net.Receive("fact_addfloor",function()
		local owner = net.ReadEntity()
		local ent = net.ReadEntity()
		local x = net.ReadUInt(16)
		local y = net.ReadUInt(16)
		local w = net.ReadUInt(3)
		local h = net.ReadUInt(3)
		
		grid.AddFloor(owner:GetFactory(),x,y,w,h,ent)
	end)
	net.Receive("fact_additem",function()
		local owner = net.ReadEntity()
		local ent = net.ReadEntity()
		local x = net.ReadUInt(16)
		local y = net.ReadUInt(16)
		local w = net.ReadUInt(3)
		local h = net.ReadUInt(3)
		
		grid.AddItem(owner:GetFactory(),x,y,w,h,ent)
	end)
end


function grid.CanPlaceFloor(fac,x,y,w,h)
	
	if x < 1 or y < 1 then return false end
	if x+w > fact.MaxFactorySize or y+h > fact.MaxFactorySize then return false end
	
	for checkX = x, x-w+1, -1 do
		for checkY = y, y-h+1, -1 do
			
			if grid.IsThereFloor(fac,checkX,checkY) then
				return false
			end
		end
	end
	
	return true
end

function grid.CanPlace(fac,x,y,w,h)
	
	if ConVars.Server.collisions:GetBool() then
		local px,py = fac.Owner:GetPos():ToGrid(fac)
		if math.InRange(px, x, x-(w-1)) and  math.InRange(py, y, y-(h-1)) then return false end --TODO: Make it test the player's hull.
	end
	
	for checkX = x, x-w+1, -1 do
		for checkY = y, y-h+1, -1 do
			if not(grid.IsThereFloor(fac,checkX,checkY) and grid.IsThereSpace(fac,checkX,checkY)) then
				return false
			end
		end
	end
	
	return true
end
function grid.IsThereFloor(fac,x,y)
	return IsValid(fac.Floors[x] and fac.Floors[x][y])
end
function grid.IsThereSpace(fac,x,y)
	return !IsValid(fac.Grid[x] and fac.Grid[x][y])
end
