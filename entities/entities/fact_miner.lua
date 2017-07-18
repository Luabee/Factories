AddCSLuaFile()

ENT.Base = "base_fact_itemholder"
ENT.BreakSpeed = .8
ENT.GridOffset = Vector(-48,0,-5)
ENT.IsMiner = true
ENT.Dimensions = {w=2,h=2}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	
	
	self:SetupTables()
	self:SetDroppingOff(true)
	
	self:SetModel("models/props_phx/construct/metal_wire1x2x2b.mdl")
	-- sweeper models/Mechanics/robotics/xfoot.mdl
	-- bar models/Mechanics/robotics/a2.mdl
	-- crane models/hunter/blocks/cube025x2x025.mdl
	
	self:SetupPreview()
	
	self.Time = 0
	
	if ConVars.Server.collisions:GetBool() then
		self:PhysicsInit(SOLID_VPHYSICS)
		if SERVER then
			local phy = self:GetPhysicsObject()
			if IsValid(phy) then
				phy:EnableMotion(false)
			end
		end
	end
	
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
	self.BaseClass.SetupDataTables(self)
	self:NetworkVar("String",1,"Import")
end

function ENT.SetupPreview(self)
	
end
function ENT.PreDrawPreview(self)
	-- self:SetModelScale(.8)
end
function ENT.PostDrawPreview(self)
	
	local oldpos = self:GetPos()
	local oldang = self:GetAngles()
	local animate = self.Holding
	if animate and #self.Holding < 5 then
		self.Time = (self.Time or 0) + RealFrameTime()
	end
	
	--draw crane
	-- self:SetMaterial("phoenix_storms/dome")
	self:SetMaterial(research.LevelModelMats[self:GetLevel()])
	self:SetAngles(oldang)
	if animate then
		self:SetPos(oldpos+Vector(30 + (math.sin(self.Time/2) * 25),-23.7,35))
	else
		self:SetPos(oldpos + self:GetForward() * 30 + self:GetRight() * 23.7 + self:GetUp() * 35)
	end
	self:SetModel("models/hunter/blocks/cube025x2x025.mdl")
	self:SetupBones()
	self:DrawModel()
	
	--draw bar 
	self:SetModelScale(.8)
	self:SetMaterial("phoenix_storms/dome")
	if animate then
		self:SetPos(self:GetPos() + Vector(0,(math.sin(self.Time) * 18),-5))
		self:SetAngles(oldang + Angle(0,self.Time*64 + 90,0))
	else
		self:SetPos(oldpos + self:GetForward() * 25 + self:GetRight() * 23.7 + self:GetUp() * 30)
		self:SetAngles(oldang)
	end
	self:SetModel("models/Mechanics/robotics/a2.mdl")
	self:SetupBones()
	self:DrawModel()
	
	--draw sweeper 1
	self:SetMaterial("phoenix_storms/future_vents")
	self:SetModel("models/Mechanics/robotics/xfoot.mdl")
	self:SetPos(self:GetPos() + self:GetForward() * 18 + Vector(0,0,-7) )
	self:SetupBones()
	self:DrawModel()
	
	--sweeper 2
	self:SetPos(self:GetPos() - self:GetForward() * 18 * 2)
	self:SetAngles(self:GetAngles() + Angle(0,180,0))
	self:SetupBones()
	self:DrawModel()
	
	--reset
	self:SetMaterial()
	self:SetPos(oldpos)
	self:SetAngles(oldang)
	self:SetModelScale(1)
	self:SetModel("models/props_phx/construct/metal_wire1x2x2b.mdl")
	
end
function ENT:DrawTranslucent()
	self:PreDrawPreview()
	self:DrawModel()
	self:PostDrawPreview()
end

function ENT:SetupIO(adjacent)
	
	
end

function ENT:GetSelectionMat()
	return Material("factories/selected.png", "unlitgeneric"), 0
end

function ENT:Think()
	local old = self.Progress or 0
	local im = self:GetImport()
	local item = items.List[im]
	if item then
		local recipe = item.Recipe
		self.Progress = (CurTime() % recipe.time) / recipe.time
		if old > self.Progress and #self.Holding < 5 then --we finished the product since the last frame.
			
			table.insert(self.Holding,items.Create(im))
		end
	end
	
	self:NextThink(CurTime())
	if CLIENT then
		self:SetNextClientThink(CurTime())
	end
	return true
end

function ENT:CanGive(itemclass,output)
	return true
	-- return self:GetMaker():CanAfford(items.List[itemclass].BasePrice)
end
function ENT:OnGive(item)
	-- self:GetMaker():AddMoney(-item.BasePrice, self:GetPos()+Vector(0,0,20))
end

if SERVER then
else

	function ENT:DoClick()
		local netmsg = "fact_importer"
		
		self:ShowSelectionMenu("Miner", function(self,item)
			return item.Recipe.madeIn == self:GetClass() and item.Level <= self:GetLevel()
		end,
		
		function(s)
			local class = s.Item and s.Item.ClassName or ""
			net.Start(netmsg)
				net.WriteString(class)
				net.WriteEntity(self)
			net.SendToServer()
			self:SetImport(class)
			self.Holding = {}
		end)
		
		
	end
	
end
