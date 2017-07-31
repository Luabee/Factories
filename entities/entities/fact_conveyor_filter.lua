AddCSLuaFile()

conveyors = conveyors or {}
conveyors.fast = conveyors.fast or {}

ENT.Base = "fact_conveyor"
ENT.Speed = 1 --time in seconds it takes to cross the entire conveyor.
ENT.Rotates = true

function ENT:Initialize()
	self.Tracks = {{},{}}
	self:SetupTables()
	-- self.NoFilter = true
	
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
	
	table.insert(conveyors.fast,self)
	
	if CLIENT then
		self.items = ClientsideModel("models/props_junk/cardboard_box004a.mdl")
		self.items:SetNoDraw(true)
	end
	
end

function ENT:SetupDataTables()
	self.BaseClass.BaseClass.SetupDataTables(self)
	self:NetworkVar("String",1,"Export")
end

function ENT:OnRemove()
	self.BaseClass.BaseClass.OnRemove(self)
	if CLIENT then
		self.items:Remove()
	end
	table.RemoveByValue(conveyors.fast,self)
	self:SellAll()
end

function ENT:CanReceive(classname,input,track)
	if self:GetExport() == classname then
		local newtr = self:GetInputTrack(input,track)
		if newtr then
			if #self.Tracks[newtr] < 5 then
				return true
			end
		end
	end
	return false
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

function ENT:GetSelectionMat()
	return Material("factories/selected.png", "unlitgeneric"), 0
end
function ENT:Save(tbl)
	tbl = self.BaseClass.Save(self,tbl)
	if items.List[self:GetExport()] then
		tbl.filter = self:GetExport()
	end
	return tbl
end
function ENT:Load(tbl)
	self.BaseClass.Load(self,tbl)
	if tbl.filter then
		self:SetExport(tbl.filter)
	end
end

if SERVER then
	util.AddNetworkString("fact_filter_conveyor")
	net.Receive("fact_filter_conveyor",function(len,ply)
		local class = net.ReadString()
		local imp = net.ReadEntity()
		if imp:GetMaker() != ply then return end
		imp:SetExport(class)
		imp:SellAll()
		imp.Tracks = {{},{}}
		imp.Holding = {}
	end)
else
	function ENT:DoClick()
		local netmsg = "fact_filter_conveyor"
		
		self:ShowSelectionMenu("Filter Conveyor", function(self,item)
			return !item.FactoryPart
		end,
		
		function(s)
			net.Start(netmsg)
				net.WriteString(s.Item and s.Item.ClassName or "")
				net.WriteEntity(self)
			net.SendToServer()
			self:SetExport(s.Item and s.Item.ClassName or "")
			self:SellAll()
			self.Tracks = {{},{}}
			self.Holding = {}
		end)
	end
end