
AddCSLuaFile()


ENT.Base = "fact_inserter"
ENT.BreakSpeed = .35
ENT.InsertSpeed = .24
ENT.PreviewScale = 1.2
ENT.Rotates = true
ENT.GridOffset = Vector(0,0,15)

if CLIENT then
	function ENT:OnRemove()
		self.BaseClass.BaseClass.OnRemove(self)
		self.magnet:Remove()
		self:SellAll()
	end
end

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
	self:NetworkVar("String",1,"Export")
end

function ENT:Save(tbl)
	tbl = self.BaseClass.BaseClass.Save(self,tbl)
	
	-- tbl.dir = self:GetDir()
	-- tbl.pickup = self:GetPickingUp()
	-- tbl.dropoff = self:GetDroppingOff()
	
	tbl.export = self:GetExport()
	
	return tbl
end
function ENT:Load(tbl)
	self.BaseClass.BaseClass.Load(self,tbl)
	
	-- self:SetDir(tbl.dir)
	-- self:SetPickingUp(tbl.pickup)
	-- self:SetDroppingOff(tbl.dropoff)
	self:SetPickingUp(false)
	self:SetDroppingOff(false)
	self:SetDir(false)
	self:SetAngles(Angle(0,self.Yaw,0))
	-- self:SetNW2Float("NextPickup",CurTime())
	if tbl.export and items.List[tbl.export] then
		self:SetExport(tbl.export)
	end
end

function ENT.SetupPreview(self)
	if CLIENT then
		self:SetModelScale(.3)
		self.magnet = ClientsideModel("models/props_wasteland/cranemagnet01a.mdl")
		self.magnet:SetModelScale(.15)
		-- self.magnet:SetParent(self)
		local vec = Vector(-25,0,20)
		local ang = self:GetRenderAngles() or self:GetAngles()
		vec:Rotate(ang)
		self.magnet:SetPos(self:GetPos() + vec)
		self.magnet:SetAngles(ang + Angle(45,0,0))
		self.magnet:SetNoDraw(true)
		self.magnet:SetMaterial(research.LevelModelMats[self:GetLevel()])
	end
end
function ENT.PostDrawPreview(self)
	local oldpos = self:GetPos()
	local vec = Vector(-25,0,20)
	local ang = self:GetRenderAngles() or self:GetAngles()
	
	if self.IsInserter then
		
		local item = self.Holding[1]
		if item then
			local pos = oldpos + self.magnet:GetForward() * -35 + self.magnet:GetUp() * -18
			
			self.magnet:SetModel(item.Model)
			self.magnet:SetModelScale(item.ConveyorScale,0)
			self.magnet:SetAngles(ang + item.ConveyorAngle)
			self.magnet:SetMaterial(item.Material)
			local vec = Vector(item.ConveyorOffset)
			vec:Rotate(ang)
			self.magnet:SetPos(pos + vec)
			self.magnet:SetupBones()
			self.magnet:DrawModel()
			
		end
	end
	
	vec:Rotate(ang)
	self.magnet:SetModel("models/props_wasteland/cranemagnet01a.mdl")
	self.magnet:SetMaterial(research.LevelModelMats[self:GetLevel()])
	self.magnet:SetModelScale(.15)
	self.magnet:SetPos(self:GetPos() + vec)
	self.magnet:SetAngles(ang + Angle(45,0,0))
	self.magnet:SetupBones()
	self.magnet:DrawModel()
end
function ENT:GetSelectionMat()
	return Material("factories/selected_inserter.png", "unlitgeneric"), self.Yaw
end


function ENT:Think()
	if self:GetPickingUp() then
		
		local item, input, track = self:IsThereInput()
		if item then
			if self:CanReceive(item,input,track) and input:CanGive(item,self,track) then
				self:PickUp(item, input, track)
			end
		end
		
	elseif self:GetDroppingOff() then
		
		local item, output, track = self:IsThereOutput()
		if item then
			if output:CanReceive(item,self,track) and self:CanGive(item,output,track) then
				self:DropOff(item, output, track)
			end
		end
		
	end
	
	if IsValid(self.Outputs[1]) then
		if self.Outputs[1].NoFilter then
			self.Requesting = {[self:GetExport()] = true}
			self.Receives = {[self:GetExport()] = true}
		else
			self.Requesting = {}
			for k,v in pairs(self.Outputs[1].Requesting) do
				if k == self:GetExport() then
					self.Requesting[k] = v
				end
			end
			self.Receives = {}
			for k,v in pairs(self.Outputs[1].Receives) do
				if k == self:GetExport() then
					self.Receives[k] = v
				end
			end
		end
		self.NoFilter = false
		
		if !self.Outputs[1].NoFilter and self:GetDroppingOff() and self.Holding[1] and !self.Receives[self.Holding[1].ClassName] then
			self.Holding = {}
			self:SetDir(false)
		end
	end
	
	self:Animate()
	
	self:NextThink(CurTime())
	if CLIENT then
		-- self:SetNextClientThink(CurTime()+engine.TickInterval())
		self:SetNextClientThink(CurTime())
	end
	return true
end


if SERVER then
	util.AddNetworkString("fact_filter_inserter")
	net.Receive("fact_filter_inserter",function(len,ply)
		local class = net.ReadString()
		local imp = net.ReadEntity()
		if imp:GetMaker() != ply then return end
		imp:SetExport(class)
		imp:SellAll()
		imp:SetPickingUp(false)
		imp:SetDroppingOff(false)
		imp:SetDir(false)
		imp:SetAngles(Angle(0,imp.Yaw,0))
	end)
else
	function ENT:DoClick()
		local netmsg = "fact_filter_inserter"
		
		self:ShowSelectionMenu("Filter Inserter", function(self,item)
			return !item.FactoryPart
		end,
		
		function(s)
			net.Start(netmsg)
				net.WriteString(s.Item and s.Item.ClassName or "")
				net.WriteEntity(self)
			net.SendToServer()
			self:SetExport(s.Item and s.Item.ClassName or "")
			self:SellAll()
			self:SetPickingUp(false)
			self:SetDroppingOff(false)
			self:SetDir(false)
			self:SetAngles(Angle(0,self.Yaw,0))
		end)
	end
end