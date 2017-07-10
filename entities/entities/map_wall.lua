
AddCSLuaFile()

ENT.Type = "anim"
function ENT:Initialize()
	
	self:SetModel("models/hunter/plates/plate05x1.mdl")
	self:SetMaterial("phoenix_storms/stripes")
	-- self:SetModelScale(.75,0)
	self:PhysicsInit(SOLID_VPHYSICS)
	
	if SERVER then
		local phy = self:GetPhysicsObject()
		if IsValid(phy) then
			phy:EnableMotion(false)
		end
	end
	self:Activate()
end

function ENT:Draw()
	self:DrawModel()
end

