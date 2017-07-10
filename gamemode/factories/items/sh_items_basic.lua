
hook.Add("InitFactoryItems","fact_items_basic",function()

	local ITEM = {}
	ITEM.Name = "Stone"
	ITEM.Desc = [[A chunk of rock.]]
	ITEM.BasePrice = 1
	ITEM.ForSale = true
	ITEM.ConveyorScale = .5
	ITEM.Model = "models/props_debris/prison_wallchunk001c.mdl"
	ITEM.Recipe = recipes.Create("fact_miner",1)
	items.Register("fact_stone_raw", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Brick"
	ITEM.Desc = [[A block of stone smelted to be more sturdy and versatile.]]
	ITEM.BasePrice = 1
	ITEM.ForSale = true
	ITEM.ConveyorScale = .5
	ITEM.Model = "models/props_debris/prison_wallchunk001c.mdl"
	ITEM.Recipe = recipes.Create("fact_stone_raw", "fact_furnace", 1)
	items.Register("fact_stone_raw", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Iron Ore"
	ITEM.Desc = [[Iron ore mined from the ground.]]
	ITEM.BasePrice = 1
	ITEM.ForSale = true
	ITEM.Model = "models/props_debris/metal_panelchunk02d.mdl"
	ITEM.ConveyorScale = .75
	ITEM.ConveyorAngle = Angle(90,0,0)
	ITEM.ConveyorOffset = Vector(-5,10,0)
	ITEM.Recipe = recipes.Create("fact_miner",1)
	items.Register("fact_iron_ore", ITEM)

	local ITEM = {}
	ITEM.Name = "Iron Bar"
	ITEM.Desc = [[Refined and shaped iron.]]
	ITEM.BasePrice = 3
	ITEM.ForSale = true
	ITEM.Model = "models/Gibs/helicopter_brokenpiece_03.mdl"
	ITEM.ConveyorScale = .4
	ITEM.ConveyorAngle = Angle(0,90,20)
	ITEM.Recipe = recipes.Create("fact_iron_ore","fact_furnace",1)
	items.Register("fact_iron_bar", ITEM)

	local ITEM = {}
	ITEM.Name = "Iron Gear"
	ITEM.Desc = [[A gear fastened from strong iron.]]
	ITEM.BasePrice = 9
	ITEM.ForSale = true
	ITEM.Model = "models/props_phx/gears/spur12.mdl"
	ITEM.ConveyorScale = .75
	ITEM.Recipe = recipes.Create("2fact_iron_bar","fact_assembler",.5)
	items.Register("fact_iron_gear", ITEM)

	local ITEM = {}
	ITEM.Name = "Copper Ore"
	ITEM.Desc = [[Copper pulled from the earth in its raw form.]]
	ITEM.BasePrice = 1
	ITEM.ForSale = true
	ITEM.Model = "models/props_junk/terracotta_chunk01b.mdl"
	ITEM.ConveyorAngle = Angle(-90,0,0)
	ITEM.ConveyorOffset = Vector(5,0,-5)
	ITEM.Recipe = recipes.Create("fact_miner",1.1)
	items.Register("fact_copper_ore", ITEM)

	local ITEM = {}
	ITEM.Name = "Copper Bar"
	ITEM.Desc = [[Refined and shaped copper.]]
	ITEM.BasePrice = 3
	ITEM.ForSale = true
	ITEM.Model = "models/Mechanics/robotics/a1.mdl"
	ITEM.ConveyorScale = .6
	ITEM.ConveyorAngle = Angle(0,90,0)
	ITEM.Recipe = recipes.Create("fact_copper_ore","fact_furnace",1)
	items.Register("fact_copper_bar", ITEM)

	local ITEM = {}
	ITEM.Name = "Copper Wires"
	ITEM.Desc = [[Copper that has been pulled into a wire shape.]]
	ITEM.BasePrice = 9
	ITEM.ForSale = true
	ITEM.Model = "models/Items/CrossbowRounds.mdl"
	ITEM.ConveyorAngle = Angle(0,90,0)
	ITEM.Recipe = recipes.Create("2fact_copper_bar","fact_assembler",.5)
	items.Register("fact_copper_wire", ITEM)

	local ITEM = {}
	ITEM.Name = "Engine"
	ITEM.Desc = [[A 400 Horsepower engine for use in a vehicle.]]
	ITEM.BasePrice = 100
	ITEM.FinishedProduct = true
	ITEM.ForSale = false
	ITEM.Model = "models/props_c17/trappropeller_engine.mdl"
	ITEM.ConveyorScale = .45
	ITEM.ConveyorOffset = Vector(0,0,4)
	ITEM.Recipe = recipes.Create("3fact_iron_bar","6fact_iron_gear","fact_assembler",8)
	items.Register("fact_engine", ITEM)
end)