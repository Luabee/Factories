AddCSLuaFile()

ENT.Base = "base_fact_itemholder"
ENT.BreakSpeed = 1
ENT.GridOffset = Vector(-48/2,-48/2,5)
ENT.Dimensions = {w=2,h=2}
ENT.Capacity = 16

function ENT:Initialize()
	
	self:SetupTables()
	self.NoFilter = true
	
	self:SetModel("models/props_junk/wood_pallet001a.mdl") --pallet
	
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
	
end
function ENT:DrawItems()
	
	if CLIENT and IsValid(self:GetMaker()) then
		if not LocalPlayer():HasPermission(self:GetMaker(),PERMISSION_VIEW) then return end
	end
	
	local oldpos = self:GetPos()
	local oldang = self:GetAngles()
	
	local count = 0
	for k, item in pairs(self.Holding) do
		for i = 1, item.Quantity do
			local pos = oldpos + Vector(count % 4 * 15 - 24, math.floor((count % 16) / 4) * 15 - 23, math.floor(count / 16)*10 + 5)
			count = count + 1
			
			self:SetMaterial(item.Material)
			self:SetModel(item.Model)
			self:SetModelScale(item.ConveyorScale,0)
			self:SetAngles(oldang + item.ConveyorAngle)
			local vec = Vector(item.ConveyorOffset)
			vec:Rotate(oldang)
			self:SetPos(pos + vec)
			self:SetupBones()
			self:DrawModel()
		end
	end
	
	self:SetMaterial()
	self:SetModelScale(1)
	self:SetPos(oldpos) --reset
	self:SetAngles(oldang)
	self:SetModel("models/props_junk/wood_pallet001a.mdl")
end
function ENT:Draw()
	self:DrawModel()
	self:DrawItems()
end

function ENT:SetupIO(adjacent)
	
	//The inserters should handle this logic for us.
	
end

function ENT:GetSelectionMat()
	return Material("factories/selected.png", "unlitgeneric"), 0
end

function ENT:Think()
	
	self.Capacity = self:GetMaker():GetResearchLevel("logistics") * 16
	
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
	
	local total = 0
	for k,v in pairs(self.Holding) do
		local can = v:OnSell(self)
		if can != false then
			total = total + v.Quantity * v.BasePrice
		end
	end
	self.Holding = {}
	
	if total == 0 then return end
	local maker = self:GetMaker()
	if IsValid(maker) then
		maker:AddMoney(total, self:GetPos()+Vector(0,0,20))
	
		if SERVER then
			if total > maker:GetMoney()*.08 then
				self:EmitSound("factories/chaching.mp3", 120)
			else
				self:EmitSound("factories/coins.mp3", 120)
			end
		end
	end
	--TODO: animate the sale.
	
end


if SERVER then
	util.AddNetworkString("fact_pallet")
	net.Receive("fact_pallet",function(len,ply)
		local imp = net.ReadEntity()
		if not IsValid(imp) then return end
		-- if imp:GetMaker() != ply then return end
		imp:SellAll()
	end)
else
	function ENT:DoClick()
		net.Start("fact_pallet")
			net.WriteEntity(self)
		net.SendToServer()
		self:SellAll()
	end
end
