
hook.Add("InitFactoryItems","fact_items_finished",function()
	
	local ITEM = {}
	ITEM.Name = "Engine"
	ITEM.Desc = [[A 380 horsepower engine for use in a vehicle.]]
	ITEM.BasePrice = 150
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_c17/trappropeller_engine.mdl"
	ITEM.ConveyorScale = .45
	ITEM.ConveyorOffset = Vector(0,0,4)
	ITEM.Level = 3
	ITEM.Recipe = recipes.Create("2fact_steel_bar","4fact_pipe","6fact_gear","fact_assembler3",16)
	items.Register("fact_engine", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Bicycle"
	ITEM.Desc = [[A bike for adults and kids alike.]]
	ITEM.BasePrice = 50
	ITEM.FinishedProduct = true
	ITEM.Level = 2
	ITEM.ForSale = false
	ITEM.Model = "models/props_junk/bicycle01a.mdl"
	ITEM.ConveyorScale = .25
	ITEM.Recipe = recipes.Create("2fact_tire","2fact_steel_bar","2fact_gear","fact_assembler2",10)
	items.Register("fact_bike", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Monitor"
	ITEM.Desc = [[A computer monitor.]]
	ITEM.BasePrice = 84
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_lab/monitor01b.mdl"
	ITEM.ConveyorScale = 1
	ITEM.Level = 2
	ITEM.Recipe = recipes.Create("1fact_iron_bar","2fact_circuit","1fact_wire","fact_assembler2",10)
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
	ITEM.BasePrice = 70
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_c17/FurnitureWashingmachine001a.mdl"
	ITEM.ConveyorScale = .3
	ITEM.Level = 2
	ITEM.Recipe = recipes.Create("2fact_steel_bar","1fact_circuit","2fact_gear","fact_assembler2",10)
	items.Register("fact_washer", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Research Pack 1"
	ITEM.Desc = [[A pack of low-level research materials. Place them in a Lab to gain research progress.]]
	ITEM.BasePrice = 1
	ITEM.Level = 0
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_lab/jar01b.mdl"
	ITEM.Material = "phoenix_storms/wire/pcb_red"
	ITEM.ConveyorScale = 1
	ITEM.Recipe = recipes.Create("1fact_gear","1fact_wire","fact_assembler",5)
	items.Register("fact_research_1", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Research Pack 2"
	ITEM.Desc = [[A pack of mid-level research materials. Place them in a Lab to gain research progress.]]
	ITEM.BasePrice = 1
	ITEM.Level = 1
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_lab/jar01b.mdl"
	ITEM.Material = "phoenix_storms/wire/pcb_green"
	ITEM.ConveyorScale = 1
	ITEM.Recipe = recipes.Create("1fact_circuit","2fact_iron_bar","fact_assembler",5)
	items.Register("fact_research_2", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Research Pack 3"
	ITEM.Desc = [[A pack of high-tech research materials. Place them in a Lab to gain research progress.]]
	ITEM.BasePrice = 1
	ITEM.Level = 2
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_lab/jar01b.mdl"
	ITEM.Material = "phoenix_storms/wire/pcb_blue"
	ITEM.ConveyorScale = 1
	ITEM.Recipe = recipes.Create("2fact_pipe","1fact_circuit","1fact_steel_bar","fact_assembler2",5)
	items.Register("fact_research_3", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Research Pack 4"
	ITEM.Desc = [[A pack of future-tech research materials. Place them in a Lab to gain research progress.]]
	ITEM.BasePrice = 1
	ITEM.Level = 3
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_lab/jar01b.mdl"
	ITEM.Material = "factories/tech/tech_modelpink"
	ITEM.ConveyorScale = 1
	ITEM.Recipe = recipes.Create("1fact_copper_ore","2fact_circuit","1fact_tire","1fact_gear","fact_assembler3",5)
	items.Register("fact_research_4", ITEM)
	
end)