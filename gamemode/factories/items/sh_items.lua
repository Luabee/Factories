
items = items or {}
items.List = items.List or {} --list of all item classes. Use items.Register() to add one.

items.Base = items.Base or { --base item. All items have these functions and fields.
	Name = "Base Item",
	Desc = [[No description available...]],
	ClassName = "Base",
	BasePrice = 100,
	ForSale = true,
	FinishedProduct = false,
	FactoryPart = false,
	Recipe = {},
	Quantity = 1,
	Owner = NULL,
	EntClass = nil,
	Model = "models/hunter/blocks/cube025x025x025.mdl",
	ConveyorScale = 1,
	ConveyorAngle = Angle(0,0,0),
	ConveyorOffset = Vector(0,0,0),
	
	SetupPreview = function(self, ent)
		
	end,
	GetClass = function(self)
		return self.ClassName
	end,
	GiveTo = function(self,ply)
		ply:AddInvItem(self)
	end,
	GetMaker = function(self)
		return self.Owner
	end,
	SetMaker = function(self,ply)
		self.Owner = ply
	end,
}


function items.Create(class, quan)
	local item = table.Copy(items.List[class])
	if item then
		item.Quantity = quan or 1
	end
	return item
end

function items.Register(class, item, baseclass) --classname, item table, baseclass to inherit from. Nil means it will inherit from the root base.
	baseclass = items.List[baseclass] or items.Base
	item.ClassName = class
	table.Inherit(item,baseclass)
	items.List[class] = item
end
