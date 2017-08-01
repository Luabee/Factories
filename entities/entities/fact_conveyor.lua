if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/factories/selected_conveyor.png")
end

BEND_NONE = 0
BEND_LEFT = 1
BEND_RIGHT = 2

AccessorFunc(ENT,"Bend","Bend",FORCE_NUMBER)

conveyors = conveyors or {}
conveyors.normal = conveyors.normal or {}

ENT.Base = "base_fact_itemholder"
ENT.BreakSpeed = .2
ENT.Speed = 1 --time in seconds it takes to cross the entire conveyor.
ENT.IsConveyor = true
ENT.GridOffset = Vector(0,0,0)
ENT.Rotates = true

local smoothness = 45

function ENT:Initialize()
	self.Tracks = {{},{}}
	self:SetupTables()
	self.NoFilter = true
	
	self:SetBend(BEND_NONE)
	self:SetModel("models/hunter/plates/plate1x1.mdl")
	self:SetupPreview()
	self.Yaw = self:GetAngles().y
	
	timer.Simple(.5,function()
		if IsValid(self) then
			self:UpdateInOut()
			for k,v in pairs(self:GetAdjacentEnts())do
				if v.IsItemHolder then
					v:UpdateInOut()
				end
			end
		end
	end)
	
	table.insert(conveyors.normal,self)
	
	if CLIENT then
		self.items = ClientsideModel("models/props_junk/cardboard_box004a.mdl")
		self.items:SetNoDraw(true)
	end
	
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	if CLIENT then
		self.items:Remove()
	end
	table.RemoveByValue(conveyors.normal,self)
	self:SellAll()
end

function ENT:PostDrawPreview()
	local oldpos, oldang = self:GetPos(), self:GetAngles()
	self:SetAngles(oldang+Angle(0,-90,0))
	self:SetPos(oldpos + self:GetUp() * 1 + self:GetRight()*.001)
	self:SetModel("models/hunter/plates/plate025x1.mdl")
	self:SetMaterial(research.LevelModelMats[self:GetLevel()])
	self:SetupBones()
	self:DrawModel()
	
	self:SetModel("models/hunter/plates/plate1x1.mdl")
	self:SetMaterial("phoenix_storms/futuristictrackramp_1-2")
	self:SetPos(oldpos)
	self:SetAngles(oldang)
end

function ENT:Save(tbl)
	tbl.yaw = self.Yaw
	
	tbl.level = self:GetLevel()
	
	tbl.Holding = {}
	for k,v in pairs(self.Holding) do
		tbl.Holding[k] = {class=v.ClassName, quan=v.Quantity, track=v.track, slot=v.conveyorSlot, trackIndex=table.KeyFromValue(self.Tracks[v.track], v)}
	end
	
	if self.GetImport then 
		tbl.item = self:GetImport() 
	elseif self.GetExport then
		tbl.item = self:GetExport()
	end
	
	return tbl
end
function ENT:Load(tbl)
	self.Yaw = tbl.yaw
	self:SetLevel(tbl.level or 1)
	
	for k,v in pairs(tbl.Holding) do
		self.Holding[k] = items.Create(v.class,v.quan)
		self.Holding[k].track = v.track
		local tr = self.Tracks[v.track]
		tr[v.trackIndex] = self.Holding[k]
		self.Holding[k].conveyorSlot = v.slot
	end
	
	if self.SetImport then 
		self:SetImport(tbl.item) 
	elseif self.SetExport then
		self:SetExport(tbl.item)
	end
	
end

function ENT:GetSelectionMat()
	return Material("factories/selected_conveyor.png", "unlitgeneric"), self.Yaw
end

function ENT:SetBend(b)
	self.Bend = self.Bend == BEND_NONE and b or BEND_NONE
end

function ENT:SetupIO(adj)
	local fwx, fwy = -math.cos(math.rad(self.Yaw)), -math.sin(math.rad(self.Yaw))
	local leftx, lefty = -math.cos(math.rad(self.Yaw+90)), -math.sin(math.rad(self.Yaw+90))
	local x, y = self:GetGridPos()
	
	self:SetBend(BEND_NONE)
	local b = false
	for k,ent in pairs(adj) do
		local inx, iny = ent:GetGridPos()
		
		if ent.IsConveyor then
			if inx == x+fwx and iny == y+fwy then --ent is in front of us.
				self.Outputs[1] = ent
			else
				local infwx, infwy = -math.cos(math.rad(ent.Yaw)), -math.sin(math.rad(ent.Yaw))
				if inx == x-fwx and iny == y-fwy and x == inx+infwx and y == iny+infwy then --ent is behind us, facing us.
					table.insert(self.Inputs, ent)
					b = true
				elseif inx == x+leftx and iny == y+lefty and x == inx+infwx and y == iny+infwy then --ent is left of us, facing us.
					table.insert(self.Inputs, ent)
					self:SetBend(BEND_LEFT)
				elseif inx == x-leftx and iny == y-lefty and x == inx+infwx and y == iny+infwy then --ent is right of us, facing us.
					table.insert(self.Inputs, ent)
					self:SetBend(BEND_RIGHT)
				end
			end
		end
	end
	if b then
		self:SetBend(BEND_NONE)
	end
	
	-- print("Inputs:")
	-- PrintTable(self.Inputs)
	-- print("Outputs:")
	-- PrintTable(self.Outputs)
	-- print("")
	
end

function ENT:MoveTracks()
	if CLIENT and IsValid(self:GetMaker()) then
		if not LocalPlayer():HasPermission(self:GetMaker(),PERMISSION_VIEW) then return end
	end
	for t=1, 2 do
		for k = #self.Tracks[t], 1, -1 do
		local item = self.Tracks[t][k]
		-- for k,item in ipairs(self.Tracks[t]) do
			if item then
				if item.conveyorSlot > 1 then
					local next = self.Tracks[t][k-1]
					item.conveyorSlot = math.max(item.conveyorSlot - 1, next and next.conveyorSlot + smoothness/5 or 1)
				else
					local next = self.Outputs[1]
					if IsValid(next) and next.IsConveyor then
						if next:CanReceive(item.ClassName,self,t) and self:CanGive(item.ClassName, next, t) then
							self:DropOff(item,next,t)
						end
					end
				end
			end
		end
	end
end

function ENT:CanReceive(itemclass, input, track)
	
	local newtr = self:GetInputTrack(input,track)
	if newtr then
		if #self.Tracks[newtr] < 5 then
			return true
		end
	end
	return false
end

function ENT:OnReceive(item, input, track)
	local newtr = self:GetInputTrack(input,track)
	item.track = newtr
	local index = table.insert(self.Tracks[newtr], item)
	local next = self.Tracks[newtr][index-1]
	item.conveyorSlot = math.max(smoothness, next and next.conveyorSlot + smoothness/5 or 1)
	
	-- print("Tracks:")
	-- PrintTable(self.Tracks)
	-- print("Holding:")
	-- PrintTable(self.Holding)
	-- print("")
end

function ENT:OnGive(item,output,track)
	table.RemoveByValue(self.Tracks[track], item)
end

function ENT:DropOff(item, output, track)
	if item then
		table.insert(output.Holding, item)
		
		table.RemoveByValue(self.Holding, item)
		
		self:SetDroppingOff(false)
		self:OnGive(item,output,track)
		output:OnReceive(item,self,track)
	end
end

function ENT:GetInputTrack(input, track) --track is optional. Use it if the input is a conveyor.
	local fwx, fwy = -math.cos(math.rad(self.Yaw)), -math.sin(math.rad(self.Yaw))
	local leftx, lefty = -math.cos(math.rad(self.Yaw+90)), -math.sin(math.rad(self.Yaw+90))
	local inx, iny = input:GetGridPos()
	local x, y = self:GetGridPos()
	
	if inx == x+fwx and iny == y+fwy then --input is in front of us.
		-- print("Front:",input)
		if input.IsInserter then
			return 2
		else
			return false
		end
	elseif inx == x-fwx and iny == y-fwy then --input is behind us.
		-- print("Behind:",input)
		if input.IsInserter then
			return 1
		else
			return track
		end
	elseif inx == x-leftx and iny == y-lefty then --input is right of us.
		-- print("Right:",input)
		if input.IsInserter then
			return 2
		else
			if self:GetBend() == BEND_NONE then
				return 1
			else
				return track
			end
		end
	elseif inx == x+leftx and iny == y+lefty then --input is left of us.
		-- print("Left:",input)
		if input.IsInserter then
			return 1
		else
			if self:GetBend() == BEND_NONE then
				return 2
			else
				return track
			end
		end
	end
	
	return false --failsafe
end

hook.Add("PlayerTick","fact_conveyormove",function(ply,mv)
	local pos = mv:GetOrigin()
	local fac = ply:GetFactory()
	if fac then
		local x,y = pos:ToGrid(fac)
		if fac.Grid[x] and IsValid(fac.Grid[x][y]) and fac.Grid[x][y].IsConveyor then
			local e = fac.Grid[x][y]
			mv:SetVelocity(mv:GetVelocity() - e:GetForward() * (1/e.Speed)*25/7.5)
		end
	end
end)

local s = ENT.Speed
local next = CurTime()
local crawl = 0
local cs = (1/ENT.Speed)
hook.Add("Think","fact_convey",function()
	local ct = CurTime()
	if ct > next then
		next = ct + s / (smoothness/5)/3
		for k,v in pairs(conveyors.normal)do
			if IsValid(v) then
				v:MoveTracks()
			end
		end
	end
	crawl = ( crawl + FrameTime()* s * 25 ) % 47
end)

if CLIENT then
	
	function ENT:Draw()
		
		if CLIENT and IsValid(self:GetMaker()) then
			if not LocalPlayer():HasPermission(self:GetMaker(),PERMISSION_VIEW) then
				self:DrawModel()
				self:PostDrawPreview()
				return
			end
		end
		
		local oldpos = self:GetPos()
		local oldang = self:GetAngles()
		local normal = -self:GetForward() -- Everything "behind" this normal will be clipped
		local p = oldpos + self:GetForward() * (47 - crawl)
		local position = normal:Dot( oldpos + self:GetForward() * 24 ) -- self:GetPos() is the origin of the clipping plane

		local oldEC = render.EnableClipping( true )
		render.PushCustomClipPlane( normal, position )

		self:SetRenderOrigin(p)
		self:SetModel("models/hunter/plates/plate1x1.mdl")
		self:SetupBones()
		self:DrawModel()
		self:SetRenderOrigin(p + Vector(0,0,1))
		self:SetRenderAngles(oldang+Angle(0,-90,0))
		self:SetModel("models/hunter/plates/plate025x1.mdl")
		self:SetMaterial(research.LevelModelMats[self:GetLevel()])
		self:SetupBones()
		self:DrawModel()
		
		render.PopCustomClipPlane()
		
		normal = self:GetForward()
		p = p - self:GetForward() * 47.5
		position = normal:Dot( oldpos - self:GetForward() * 24 ) -- self:GetPos() is the origin of the clipping plane
		render.PushCustomClipPlane( normal, position )
		
		self:SetRenderOrigin(p + Vector(0,0,1))
		self:SetupBones()
		self:DrawModel()
		self:SetMaterial("phoenix_storms/futuristictrackramp_1-2")
		self:SetModel("models/hunter/plates/plate1x1.mdl")
		self:SetRenderAngles(oldang)
		self:SetRenderOrigin(p)
		self:SetupBones()
		self:DrawModel()
		
		render.PopCustomClipPlane()
		
		render.EnableClipping( oldEC )
		self:SetRenderOrigin(oldpos)
		self:SetRenderAngles(oldang)
		
		self:DrawItems()
	end
	
	function ENT:DrawItems()
		for track = 1, 2 do
			for _,item in pairs(self.Tracks[track]) do
				local i = item.conveyorSlot
				local pos
				
				local bend = self:GetBend()
				if bend == BEND_NONE then
					pos = self:GetPos() + self:GetForward() * -(21 - ((i/(smoothness/5))*9.5)) + self:GetRight()*(30*(track-1) - 15) + Vector(0,0,5)
				elseif bend == BEND_LEFT then
					pos = self:GetPos() + self:GetForward() * -(21 - ((i/(smoothness/5))*9.5)) + self:GetRight()*(30*(track-1) - 15) + Vector(0,0,5)
				else --BEND_RIGHT
					pos = self:GetPos() + self:GetForward() * -(21 - ((i/(smoothness/5))*9.5)) + self:GetRight()*(30*(track-1) - 15) + Vector(0,0,5)
				end
				
				self.items:SetModel(item.Model)
				self.items:SetMaterial(item.Material)
				self.items:SetModelScale(item.ConveyorScale,0)
				self.items:SetAngles(self:GetAngles() + item.ConveyorAngle)
				local vec = Vector(item.ConveyorOffset)
				vec:Rotate(self:GetAngles())
				self.items:SetPos(pos + vec)
				self.items:SetupBones()
				self.items:DrawModel()
			end
		end
		
	end

end
