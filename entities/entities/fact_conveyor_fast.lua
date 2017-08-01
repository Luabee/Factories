AddCSLuaFile()

conveyors = conveyors or {}
conveyors.fast = conveyors.fast or {}

ENT.Base = "fact_conveyor"
ENT.BreakSpeed = .2
ENT.Speed = .3 --time in seconds it takes to cross the entire conveyor.
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
	
	table.insert(conveyors.fast,self)
	
	if CLIENT then
		self.items = ClientsideModel("models/props_junk/cardboard_box004a.mdl")
		self.items:SetNoDraw(true)
	end
	
end

function ENT:OnRemove()
	self.BaseClass.BaseClass.OnRemove(self)
	if CLIENT then
		self.items:Remove()
	end
	table.RemoveByValue(conveyors.fast,self)
	self:SellAll()
end

function ENT:GetSelectionMat()
	return Material("factories/selected_conveyor.png", "unlitgeneric"), self.Yaw
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

local s = ENT.Speed
local next = CurTime()
local crawl = 0
local cs = (1/ENT.Speed)
hook.Add("Think","fact_convey_fast",function() --TODO: Make this nicer.
	local ct = CurTime()
	if ct > next then
		next = ct + s / (smoothness/5)/50
		for k,v in pairs(conveyors.fast)do
			if IsValid(v) then
				v:MoveTracks()
			end
		end
	end
	crawl = ( crawl + FrameTime()* cs * 15 ) % 47
end)

if CLIENT then
	
	function ENT:Draw()
		
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

end
