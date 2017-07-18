
hook.Add("InitFactoryItems","fact_items_basic",function()
	
	local ITEM = {}
	ITEM.Name = "Iron Ore"
	ITEM.Desc = [[Iron ore mined from the ground.]]
	ITEM.BasePrice = 1
	ITEM.ForSale = true
	ITEM.Model = "models/props_debris/metal_panelchunk02d.mdl"
	ITEM.ConveyorScale = .75
	ITEM.ConveyorAngle = Angle(90,0,0)
	ITEM.ConveyorOffset = Vector(-5,10,0)
	ITEM.Recipe = recipes.Create("fact_miner",1.5)
	items.Register("fact_iron_ore", ITEM)

	local ITEM = {}
	ITEM.Name = "Iron Bar"
	ITEM.Desc = [[Refined and shaped iron.]]
	ITEM.BasePrice = 2
	ITEM.ForSale = true
	ITEM.Model = "models/Gibs/helicopter_brokenpiece_03.mdl"
	ITEM.ConveyorScale = .4
	ITEM.ConveyorAngle = Angle(0,90,20)
	ITEM.Recipe = recipes.Create("fact_iron_ore","fact_furnace",1)
	items.Register("fact_iron_bar", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Pipe"
	ITEM.Desc = [[A pipe which carries gas or liquid.]]
	ITEM.BasePrice = 3
	ITEM.ForSale = true
	ITEM.Model = "models/props_canal/mattpipe.mdl"
	-- ITEM.Material = "phoenix_storms/bluemetal"
	-- ITEM.ConveyorScale = .25
	ITEM.ConveyorAngle = Angle(90,90,0)
	ITEM.Recipe = recipes.Create("fact_iron_bar","fact_assembler",.5)
	items.Register("fact_pipe", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Steel Bar"
	ITEM.Desc = [[A bar of super-strong steel.]]
	ITEM.BasePrice = 4
	ITEM.ForSale = true
	ITEM.Model = "models/mechanics/solid_steel/i_beam_4.mdl"
	ITEM.Level = 2
	ITEM.ConveyorScale = .5
	ITEM.ConveyorAngle = Angle(0,90,0)
	ITEM.ConveyorOffset = Vector(0,0,1)
	ITEM.Recipe = recipes.Create("fact_iron_bar","fact_furnace2",2)
	items.Register("fact_steel_bar", ITEM)

	local ITEM = {}
	ITEM.Name = "Iron Gear"
	ITEM.Desc = [[A gear fastened from strong iron.]]
	ITEM.BasePrice = 5
	ITEM.ForSale = true
	ITEM.Model = "models/props_phx/gears/spur9.mdl"
	-- ITEM.ConveyorScale = .75
	ITEM.Recipe = recipes.Create("2fact_iron_bar","fact_assembler",.5)
	items.Register("fact_gear", ITEM)

	local ITEM = {}
	ITEM.Name = "Copper Ore"
	ITEM.Desc = [[Copper pulled from the earth in its raw form.]]
	ITEM.BasePrice = 1
	ITEM.ForSale = true
	ITEM.Model = "models/props_junk/terracotta_chunk01b.mdl"
	ITEM.ConveyorAngle = Angle(-90,0,0)
	ITEM.ConveyorOffset = Vector(5,0,-5)
	ITEM.Recipe = recipes.Create("fact_miner",1.5)
	items.Register("fact_copper_ore", ITEM)

	local ITEM = {}
	ITEM.Name = "Copper Bar"
	ITEM.Desc = [[Refined and shaped copper.]]
	ITEM.BasePrice = 2
	ITEM.ForSale = true
	ITEM.Model = "models/Mechanics/robotics/a1.mdl"
	ITEM.ConveyorScale = .6
	ITEM.ConveyorAngle = Angle(0,90,0)
	ITEM.Recipe = recipes.Create("fact_copper_ore","fact_furnace",1)
	items.Register("fact_copper_bar", ITEM)

	local ITEM = {}
	ITEM.Name = "Copper Wires"
	ITEM.Desc = [[Copper that has been pulled into a wire shape.]]
	ITEM.BasePrice = 5
	ITEM.ForSale = true
	ITEM.Model = "models/Items/CrossbowRounds.mdl"
	ITEM.ConveyorAngle = Angle(0,90,0)
	ITEM.Recipe = recipes.Create("2fact_copper_bar","fact_assembler",.5)
	items.Register("fact_wire", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Circuit Board"
	ITEM.Desc = [[A circuit for use in simple electronics.]]
	ITEM.BasePrice = 14
	ITEM.ForSale = true
	ITEM.Model = "models/hunter/plates/plate1x1.mdl"
	ITEM.Material = "phoenix_storms/wire/pcb_green"
	ITEM.ConveyorScale = .25
	ITEM.Level = 2
	ITEM.Recipe = recipes.Create("2fact_wire","fact_iron_bar","fact_assembler2",.8)
	items.Register("fact_circuit", ITEM)

	local ITEM = {}
	ITEM.Name = "Stone"
	ITEM.Desc = [[A chunk of rock.]]
	ITEM.BasePrice = 1
	ITEM.ForSale = true
	ITEM.ConveyorScale = .5
	ITEM.Model = "models/props_debris/prison_wallchunk001c.mdl"
	ITEM.Recipe = recipes.Create("fact_miner",1.5)
	items.Register("fact_stone_raw", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Rubber"
	ITEM.Desc = [[A chunk of rubber.]]
	ITEM.BasePrice = 2
	ITEM.ForSale = true
	ITEM.Level = 2
	ITEM.Model = "models/XQM/cylinderx1.mdl"
	ITEM.Material = "models/xqm/panel360_diffuse"
	ITEM.Recipe = recipes.Create("fact_miner2",1)
	items.Register("fact_rubber", ITEM)
	
	local ITEM = {}
	ITEM.Name = "Tire"
	ITEM.Desc = [[A rubber tire for vehicle wheels.]]
	ITEM.BasePrice = 12
	ITEM.FinishedProduct = false
	ITEM.ForSale = true
	ITEM.Model = "models/props_phx/wheels/magnetic_small.mdl"
	ITEM.ConveyorScale = 1.1
	ITEM.Level = 2
	ITEM.Recipe = recipes.Create("3fact_rubber","1fact_iron_bar","fact_assembler2",5)
	items.Register("fact_tire", ITEM)
	
	
end)