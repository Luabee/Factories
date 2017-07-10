
AddCSLuaFile()

ENT.Type = "anim"

ENT.IsItem = true

function ENT:Initialize()
	
	self:SetModel(self:GetItem().Model)
	self:SetModelScale(self:GetItem().ModelScale or .2,0)
	
end

function ENT:GetItem()
	return items.List[self:GetItemClass()]
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ItemClass") 
	self:NetworkVar("Entity", 0, "Maker") 
	self:NetworkVar("Entity", 1, "Holder") 
end

function items.AddToEnt(ent,class)
	local item = items.Create(class)
	item.Owner = ent:GetMaker()
	ent.Holding[class] = item
	
	local itement = ents.Create("fact_item")
	itement:SetPos(ent:GetPos())
	itement:SetMaker(ent:GetMaker())
	itement:SetHolder(ent)
	itement:SetItemClass(class)
	itement:Spawn()
end
