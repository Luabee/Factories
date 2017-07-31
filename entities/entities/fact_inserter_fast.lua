
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


function ENT:Save(tbl)
	tbl = self.BaseClass.BaseClass.Save(self,tbl)
	
	-- tbl.dir = self:GetDir()
	-- tbl.pickup = self:GetPickingUp()
	-- tbl.dropoff = self:GetDroppingOff()
	
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
