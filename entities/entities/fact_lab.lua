AddCSLuaFile()

ENT.Base = "base_fact_itemholder"
ENT.BreakSpeed = 1
ENT.GridOffset = Vector(-48,12,5)
ENT.AngOffset = Angle(0,-90,0)
ENT.Dimensions = {w=2,h=2}
ENT.Capacity = 16
ENT.PreviewScale = 1.25

function ENT:Initialize()
	
	self:SetupTables()
	
	self:SetModel("models/props_lab/servers.mdl")
	
	self:SetupPreview()
	
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
	
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self:SellAll()
end

function ENT.SetupPreview(self)
	self:SetModelScale(.4)
	if CLIENT then
		self:SetRenderBounds(Vector(-48*3/2,-48*3/2,-4),Vector(48*3/2,48*3/2,90), Vector(48/2,-48,0))
	end
end

local model_list = {
	breenchair={ang=Angle(0,140,0),pos=Vector(-44,-32,0),mdl="models/props_combine/breenchair.mdl",},
	plotter={ang=Angle(0,90,0),pos=Vector(45,-58,-1),mdl="models/props_lab/plotter.mdl",},
	workspace001={ang=Angle(-0,-0,-0),pos=Vector(30,55,0),mdl="models/props_lab/workspace001.mdl",}
	-- cabinet={ang=Angle(0.0062427860684693,-97.546112060547,0.012987055815756),pos=Vector(20.524627685547,103.158134460449,13.682692527771),mdl="models/props_wasteland/controlroom_filecabinet001a.mdl",},
	-- cabinet1={ang=Angle(0.0062427860684693,-90.546112060547,0.012987055815756),pos=Vector(32.524627685547,78.158134460449,13.682692527771),mdl="models/props_wasteland/controlroom_filecabinet001a.mdl",},
	-- crematorcase={ang=Angle(-0.14710694551468,-23.701778411865,0.019795153290033),pos=Vector(8.3410959243774,30.362199783325,101.41258239746),mdl="models/props_lab/crematorcase.mdl",},
}

function ENT.PostDrawPreview(self)
	
	local oldpos = self:GetPos()
	local oldang = self:GetAngles()
	self:SetModelScale(.6)
	
	for k, model in pairs(model_list) do
		self:SetModel(model.mdl)
		self:SetAngles(oldang + model.ang)
		self:SetPos(self:LocalToWorld(model.pos))
		self:SetupBones()
		self:DrawModel()
		self:SetPos(oldpos)
	end
	
	self:SetModelScale(.4)
	self:SetPos(oldpos) --reset
	self:SetAngles(oldang)
	self:SetModel("models/props_lab/servers.mdl")
end
function ENT:Draw()
	self:DrawModel()
	self:PostDrawPreview()
end

function ENT:SetupIO(adjacent)
	
	//The inserters should handle this logic for us.
	self.Receives = {fact_research_1 = true, fact_research_2 = true, fact_research_3 = true, fact_research_4 = true}
	
end

function ENT:GetSelectionMat()
	return Material("factories/selected.png", "unlitgeneric"), 0
end

function ENT:Think()
	
	self.Requesting = table.Copy(self.Receives)
	if CLIENT then
		local count = #self.Holding
		if count > 0 then
			local ed = EffectData()
			ed:SetEntity(self)
			ed:SetOrigin( self:GetPos()+Vector(10,-38,50) )
			util.Effect( "TeslaHitboxes", ed )
		end
		-- self:NextThink(CurTime()+.5)
		-- return true
	end
	
end

function ENT:GetHeldQuantity()
	local count = 0
	for k,v in pairs(self.Holding) do
		count = count + v.Quantity
	end
	return count
end

function ENT:CanReceive(itemclass,input)
	return self:GetHeldQuantity() < self.Capacity
end

function ENT:SellAll()
	if IsValid(self:GetMaker()) and self:GetMaker().FactorySync then return end
	
	local maker = self:GetMaker()
	if IsValid(maker) then
		
		local total, b = 0, false
		for k,v in pairs(self.Holding) do
			if maker:GetResearchLevel() == v.Level then
				total = total + v.Quantity * v.BasePrice
			elseif CLIENT then
				b = v.Level
			end
		end
		if b then 
			notification.AddLegacy("Level "..(b+1).." research packs can't be used to research level "..maker:GetResearchLevel()+1 .." tech.",NOTIFY_ERROR,8)
		end
		self.Holding = {}
		
		if total == 0 then return end
		
		maker:AddResearch(total, self:GetPos()+Vector(10,-38,30))
		
		if SERVER then
			self:EmitSound("ambient/energy/newspark10.wav", 90)
		end
	end
	--TODO: animate the sale.
	
end


if SERVER then
else
	function ENT:DoClick()
		net.Start("fact_pallet")
			net.WriteEntity(self)
		net.SendToServer()
		self:SellAll()
	end
end
