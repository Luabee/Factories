AddCSLuaFile()

ENT.Base = "base_fact"
ENT.IsFloor = true
ENT.Dimensions = {w=4, h=4}
ENT.GridOffset = Vector(-grid.Size*1.5, -grid.Size*1.5 ,-1)
ENT.BreakSpeed = 2.5

function ENT:Initialize()
	
	-- self:SetModel("models/props_phx/construct/metal_plate4x4.mdl")
	self:SetModel("models/hunter/plates/plate4x4.mdl")
	self:SetupPreview()
	self:PhysicsInit(SOLID_VPHYSICS)
	
	if SERVER then
		local phy = self:GetPhysicsObject()
		if IsValid(phy) then
			phy:EnableMotion(false)
		end
	end
	
end

function ENT.SetupPreview(self)
	self:SetMaterial("phoenix_storms/metalfloor_2-3")
end

