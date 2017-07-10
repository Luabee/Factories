
if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("fact_insertersync")
end

AccessorFunc(ENT,"PickingUp","PickingUp",FORCE_BOOL)
AccessorFunc(ENT,"DroppingOff","DroppingOff",FORCE_BOOL)

ENT.Base = "base_fact_itemholder"
ENT.BreakSpeed = .35
ENT.InsertSpeed = .95
ENT.PreviewScale = 1.5
ENT.IsInserter = true
ENT.Rotates = true
ENT.GridOffset = Vector(0,0,15)

function ENT:Initialize()
	
	self:SetupTables()
	self.NoFilter = true
	
	if SERVER then
		self:SetNW2Float("NextPickup",CurTime()+1+self.InsertSpeed/2)
	else
		-- self:SetPredictable(true)
	end
	local eid = self:EntIndex()
	timer.Create("insertersync"..eid,.01,0,function()
		if IsValid(self) then
			if CurTime() >= self:GetNW2Float("NextPickup") then
				self:SetPickingUp(true)
				self:SetDir(false)
				if SERVER then 
					timer.Adjust("insertersync"..eid,10,0,function()
						if IsValid(self) then
							net.Start("fact_insertersync")
								net.WriteEntity(self)
								net.WriteFloat(self:GetAngles().y)
							net.Broadcast()
						else
							timer.Remove("insertersync"..eid)
						end
					end)
				else
					timer.Remove("insertersync"..eid)
				end
			end
		else
			timer.Remove("insertersync"..eid)
		end
	end)
	
	self:SetModel("models/props_wasteland/buoy01.mdl")
	self:SetModelScale(.3)
	self.Yaw = self:GetAngles().y
	if CLIENT then self:SetRenderAngles(self:GetAngles()) end
	self:SetupPreview()

	timer.Simple(.5,function()
		self:UpdateInOut()
		for k,v in pairs(self:GetAdjacentEnts())do
			if v.IsItemHolder then
				v:UpdateInOut()
			end
		end
	end)
	
end
function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ItemClass") 
	self:NetworkVar("Entity", 0, "Maker") 
	self:NetworkVar("Int", 0, "GridX") 
	self:NetworkVar("Int", 1, "GridY") 
	-- self:NetworkVar("Bool", 0, "PickingUp") 
	-- self:NetworkVar("Bool", 1, "DroppingOff") 
end

function ENT.SetupPreview(self)
	if CLIENT then
		self:SetModelScale(.3)
		self.magnet = ClientsideModel("models/props_wasteland/cranemagnet01a.mdl")
		self.magnet:SetModelScale(.15)
		self.magnet:SetParent(self)
		local vec = Vector(-25,0,20)
		local ang = self:GetRenderAngles() or self:GetAngles()
		vec:Rotate(ang)
		self.magnet:SetPos(self:GetPos() + vec)
		self.magnet:SetAngles(ang + Angle(45,0,0))
		self.magnet:SetNoDraw(true)
	end
end
function ENT.PostDrawPreview(self)
	local vec = Vector(-25,0,20)
	local ang = self:GetRenderAngles() or self:GetAngles()
	vec:Rotate(ang)
	self.magnet:SetPos(self:GetPos() + vec)
	self.magnet:SetAngles(ang + Angle(45,0,0))
	self.magnet:DrawModel()
end
function ENT:Draw()
	self:DrawModel()
	local ang = self:GetRenderAngles() or self:GetAngles()
	local vec = Vector(-25,0,20)
	vec:Rotate(ang)
	self.magnet:SetPos(self:GetPos() + vec)
	self.magnet:SetAngles(ang + Angle(45,0,0))
	self.magnet:DrawModel()
end
function ENT:GetSelectionMat()
	return Material("factories/selected_inserter.png", "unlitgeneric"), self.Yaw
end
if CLIENT then
	function ENT:OnRemove()
		self.BaseClass.OnRemove(self)
		self.magnet:Remove()
	end
	net.Receive("fact_insertersync",function()
		local e = net.ReadEntity()
		if IsValid(e) then
			local a = Angle(0,net.ReadFloat(),0)
			e:SetAngles(a)
			e:SetRenderAngles(a)
		end
	end)
end

function ENT:SetDir(dir)
	self.Dir = dir
end
function ENT:GetDir() return self.Dir end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if IsValid(self.Outputs[1]) then
		self.Requesting = self.Outputs[1].Requesting
		self.Receives = self.Outputs[1].Receives
		self.NoFilter = self.Outputs[1].NoFilter
	end
	
	self:Animate()
	
	self:NextThink(CurTime())
	if CLIENT then
		self:SetNextClientThink(CurTime())
	end
	return true
end

-- local ct1, ct2 = 0,0
function ENT:OnReceive(item)
	-- ct2 = ct2 + 1
	-- print("Picked up: ",item.Name, ct2)
	self:SetDir(true)
end
function ENT:OnGive(item)
	-- ct1 = ct1+1
	-- print("Dropped off: ",item.Name, ct1)
	self:SetDir(false)
end

function ENT:SetupIO(adjacent)
	local forwardx, forwardy = math.Round(math.cos(math.rad(self.Yaw))), math.Round(math.sin(math.rad(self.Yaw)))
	local x,y = self:GetGridPos()
	for k,ent in pairs(adjacent) do
		if not IsValid(ent) or not ent.IsFactoryPart then continue end
		if ent.IsInserter then continue end
		local otherx, othery = ent:GetGridPos()
		local w,h = ent:GetSize()
		-- print(x+forwardx, otherx, otherx-w)
		if math.InRange(x + forwardx, otherx, otherx-w) and math.InRange(y + forwardy, othery, othery-h) then
			self.Outputs = {ent}
		elseif math.InRange(x - forwardx, otherx, otherx-w) and math.InRange(y - forwardy, othery, othery-h) then
			self.Inputs = {ent}
		end
	end
	
	-- print("Inputs:")
	-- PrintTable(self.Inputs)
	-- print("Outputs:")
	-- PrintTable(self.Outputs)
	-- print("")
	
end

function ENT:Animate()
	if self:GetDir() == true and not self:GetDroppingOff() then -- forward
		local a = self:GetAngles()
		a.y = math.ApproachAngle( a.y, self.Yaw+179, FrameTime() * (1/(self.InsertSpeed/179)))
		if CLIENT then
			self:SetRenderAngles(a)
		else
			self:SetAngles(a)
		end
		
		if math.AngleDifference(a.y, self.Yaw+179) == 0 then
			self:SetDroppingOff(true)
		end
	elseif self:GetDir() == false and not self:GetPickingUp() then -- reverse
		
		local a = self:GetAngles()
		a.y = math.ApproachAngle( a.y, self.Yaw, FrameTime() * (1/(self.InsertSpeed/179)))
		if CLIENT then
			self:SetRenderAngles(a)
		else
			self:SetAngles(a)
		end
		
		if math.AngleDifference(a.y, self.Yaw) == 0 then
			self:SetPickingUp(true)
		end
		
		
	end
end
