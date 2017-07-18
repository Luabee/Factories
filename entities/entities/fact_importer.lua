AddCSLuaFile()

ENT.Base = "base_fact_itemholder"
ENT.BreakSpeed = .8
ENT.GridOffset = Vector(0,0,10)

function ENT:Initialize()
	
	
	self:SetupTables()
	self:SetDroppingOff(true)
	
	self:SetModel("models/props_junk/cardboard_box001a.mdl")
	
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
	self.BaseClass.SetupDataTables(self)
	self:NetworkVar("String",1,"Import")
end

function ENT.SetupPreview(self)
	
end
function ENT.PreDrawPreview(self)
	self:SetModelScale(.8)
end
function ENT.PostDrawPreview(self)
	
	local oldpos = self:GetPos()
	local oldang = self:GetAngles()
	
	self:SetPos(oldpos + Vector(0,0,17)) --medium box
	self:SetModel("models/props_junk/cardboard_box003a.mdl")
	self:SetupBones()
	self:DrawModel()
	
	self:SetPos(oldpos + self:GetForward() * -6 + self:GetRight() * -5 + self:GetUp() * 15) --little box
	self:SetAngles(oldang + Angle(0,90,0)) --little box
	self:SetModel("models/props_junk/cardboard_box004a.mdl")
	self:SetupBones()
	self:DrawModel()
	
	self:SetPos(oldpos) --reset
	self:SetAngles(oldang)
	self:SetModelScale(1)
	self:SetModel("models/props_junk/cardboard_box001a.mdl")
	self:SetupBones()
	
end
function ENT:Draw()
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
	local import = self:GetImport()
	if import and import != "" and #self.Holding == 0 then
		self.Holding[1] = items.Create(import)
	end
end

function ENT:CanGive(itemclass,output)
	return self:GetMaker():CanAfford(math.floor(items.List[itemclass].BasePrice * 1.5))
end
function ENT:OnGive(item)
	self:GetMaker():AddMoney(math.floor(-item.BasePrice*1.5), self:GetPos()+Vector(0,0,20))
end

if SERVER then
	util.AddNetworkString("fact_importer")
	net.Receive("fact_importer",function(len,ply)
		local class = net.ReadString()
		local imp = net.ReadEntity()
		if imp:GetMaker() != ply then return end
		imp:SetImport(class)
		imp.Holding = {}
	end)
else
	function ENT:DoClick()
		local netmsg = "fact_importer"
		
		self:ShowSelectionMenu("Importer", function(self,item)
			return item.ForSale and !item.FactoryPart and !item.FinishedProduct
		end,
		
		function(s)
			net.Start("fact_importer")
				net.WriteString(s.Item and s.Item.ClassName or "")
				net.WriteEntity(self)
			net.SendToServer()
			self:SetImport(s.Item and s.Item.ClassName or "")
			self.Holding = {}
		end)
		
		
	end
	
end
