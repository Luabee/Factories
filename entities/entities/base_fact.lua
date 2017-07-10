
AddCSLuaFile()
AccessorFunc(ENT,"Wide","Wide",FORCE_NUMBER)
AccessorFunc(ENT,"Tall","Tall",FORCE_NUMBER)
AccessorFunc(ENT,"Item","Item")

ENT.Type = "anim"
ENT.IsFactoryPart = true

ENT.GridOffset = Vector(0,0,0)
ENT.AngOffset = Angle(0,0,0)
ENT.Dimensions = {w=1, h=1}
ENT.BreakSpeed = .65
ENT.Rotates = false
ENT.PlaceSounds = {
	-- Sound("doors/door_metal_medium_close1.wav"),
	-- Sound("doors/door_metal_medium_open1.wav"),
	Sound("doors/door_metal_thin_open1.wav"),
	Sound("doors/door_metal_thin_close2.wav"),
	-- Sound("doors/door_latch1.wav"),
	-- Sound("doors/wood_stop1.wav"),
	-- Sound("garrysmod/balloon_pop_cute.wav"),
}
ENT.BreakSounds = {
	Sound("doors/vent_open1.wav"),
	Sound("doors/vent_open2.wav"),
	Sound("doors/vent_open3.wav"),
	-- Sound("garrysmod/balloon_pop_cute.wav"),
}

function ENT:Initialize()

	self:SetSize(self.Dimensions.w, self.Dimensions.h)
	self:SetModel("models/props_junk/cardboard_box004a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	if SERVER then
		local phy = self:GetPhysicsObject()
		if IsValid(phy) then
			phy:EnableMotion(false)
		end
	end
	
end

local place, Break = 0, 0
function ENT:GetPlaceSound()
	local new = place
	local max = #self.PlaceSounds
	while new == place do
		new = math.random(1,max)
	end
	place = new
	return self.PlaceSounds[new]
end
function ENT:GetBreakSound()
	local new = Break
	local max = #self.BreakSounds
	while new == Break do
		new = math.random(1,max)
	end
	Break = new
	return self.BreakSounds[new]
end

function ENT:SetupPreview()
	--Setup the model to be rendered in the menu models and as a ghost before placing it.
end
function ENT:PreDrawPreview()
	--this is called each frame just before a model is rendered in the menu models and as a ghost before placing it.
end
function ENT:PostDrawPreview()
	--this is called each frame just after a model is rendered in the menu models and as a ghost before placing it.
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ItemClass") 
	self:NetworkVar("Entity", 0, "Maker") 
	self:NetworkVar("Int", 0, "GridX") 
	self:NetworkVar("Int", 1, "GridY") 
end

function ENT:SnapToGrid(pos)
	self:SetPos(grid.SnapTo(self:GetMaker():GetFactory(), pos or self:GetPos()))
end
function ENT:SetGridPos(x,y)
	self:SetGridX(x)
	self:SetGridY(y)
end
function ENT:GetGridPos()
	return self:GetGridX(), self:GetGridY()
end
function ENT:SetSize(w,h)
	self.Wide = w
	self.Tall = h
end
function ENT:GetSize()
	return self.Wide or self.Dimensions.w, self.Tall or self.Dimensions.h
end
