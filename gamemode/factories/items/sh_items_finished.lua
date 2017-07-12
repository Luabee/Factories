
hook.Add("InitFactoryItems","fact_items_finished",function()
	
	local ITEM = {}
	ITEM.Name = "Engine"
	ITEM.Desc = [[A 380 horsepower engine for use in a vehicle.]]
	ITEM.BasePrice = 70
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_c17/trappropeller_engine.mdl"
	ITEM.ConveyorScale = .45
	ITEM.ConveyorOffset = Vector(0,0,4)
	ITEM.Recipe = recipes.Create("2fact_steel_bar","4fact_pipe","6fact_gear","fact_assembler",16)
	items.Register("fact_engine", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Bicycle"
	ITEM.Desc = [[A bike for adults and kids alike.]]
	ITEM.BasePrice = 35
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_junk/bicycle01a.mdl"
	ITEM.ConveyorScale = .25
	ITEM.Recipe = recipes.Create("2fact_tire","1fact_steel_bar","2fact_gear","fact_assembler",10)
	items.Register("fact_bike", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Monitor"
	ITEM.Desc = [[A computer monitor.]]
	ITEM.BasePrice = 65
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_lab/monitor01b.mdl"
	ITEM.ConveyorScale = 1
	ITEM.Recipe = recipes.Create("1fact_iron_bar","2fact_circuit","1fact_wire","fact_assembler",10)
	items.Register("fact_monitor", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Filing Cabinet"
	ITEM.Desc = [[A cabinet for holding documents.]]
	ITEM.BasePrice = 24
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_lab/partsbin01.mdl"
	ITEM.ConveyorAngle = Angle(0,180,0)
	ITEM.ConveyorOffset = Vector(0,0,10)
	ITEM.ConveyorScale = .8
	ITEM.Recipe = recipes.Create("2fact_iron_bar","3fact_gear","fact_assembler",8.5)
	items.Register("fact_cabinet", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Washing Machine"
	ITEM.Desc = [[A clothes-washing machine for home use.]]
	ITEM.BasePrice = 65
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_c17/FurnitureWashingmachine001a.mdl"
	ITEM.ConveyorScale = .3
	ITEM.Recipe = recipes.Create("2fact_iron_bar","2fact_circuit","2fact_gear","fact_assembler",10)
	items.Register("fact_washer", ITEM)
	
end)