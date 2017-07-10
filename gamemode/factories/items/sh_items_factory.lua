
hook.Add("Initialize","fact_items_factory",function()

	local ITEM = {}
	ITEM.Name = "Inserter"
	ITEM.Desc = [[The Inserter picks up items and places them on the opposite side.

	It also pulls items out of containers such as furnaces and assemblers.

	Inserters always place their item on the far end of a conveyor.]]
	ITEM.BasePrice = 40
	ITEM.EntClass = "fact_inserter"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	ITEM.Model = "models/props_wasteland/buoy01.mdl"
	items.Register("fact_inserter", ITEM)

	local ITEM = {}
	ITEM.Name = "Conveyor"
	ITEM.Desc = [[Conveyors move items across your factory.

	They have two separate sides which pull on different tracks.]]
	ITEM.BasePrice = 15
	ITEM.Model = "models/hunter/plates/plate1x1.mdl"
	ITEM.EntClass = "fact_conveyor"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	items.Register("fact_conveyor", ITEM)

	local ITEM = {}
	ITEM.Name = "Assembler"
	ITEM.Desc = [[An assembler combines materials to create new items.

	The resulting product must be pulled out with an inserter.]]
	ITEM.BasePrice = 120
	ITEM.Model = "models/props_phx/construct/metal_wire1x2x2b.mdl"
	ITEM.EntClass = "fact_assembler"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	items.Register("fact_assembler", ITEM)

	local ITEM = {}
	ITEM.Name = "Furnace"
	ITEM.Desc = [[Furnaces cook single materials into their refined counterparts.

	Only certain items can be smelted in a furnace.]]
	ITEM.BasePrice = 90
	ITEM.EntClass = "fact_furnace"
	ITEM.ForSale = true
	ITEM.Model = "models/props_c17/furniturefireplace001a.mdl"
	ITEM.FactoryPart = true
	items.Register("fact_furnace", ITEM)

	local ITEM = {}
	ITEM.Name = "Miner"
	ITEM.Desc = [[Miners pull ore from the earth.

	Use inserters to place the ore onto conveyors.]]
	ITEM.BasePrice = 800
	ITEM.EntClass = "fact_miner"
	ITEM.Model = "models/props_phx/construct/metal_wire1x2x2b.mdl"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	items.Register("fact_miner", ITEM)

	local ITEM = {}
	ITEM.Name = "Power Pylon"
	ITEM.Desc = [[Provides power to nearby factory components.

	Without power, these components will cease to function.]]
	ITEM.BasePrice = 40
	ITEM.EntClass = "fact_pylon"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	items.Register("fact_pylon", ITEM)

	local ITEM = {}
	ITEM.Name = "Factory Floor"
	ITEM.Desc = [[Add on to your factory by building more floor space.]]
	ITEM.BasePrice = 800
	ITEM.EntClass = "fact_floor"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	ITEM.Model = "models/hunter/plates/plate4x4.mdl"
	items.Register("fact_floor",ITEM)

	local ITEM = {}
	ITEM.Name = "Importer"
	ITEM.Desc = [[The Importer buys materials from the market.

	Each time an inserter reaches into the importer, a purchase is made.
	Click the Importer to select a product to buy.

	Use Importers to create materials which you can't yet make yourself.]]
	ITEM.BasePrice = 100
	ITEM.EntClass = "fact_importer"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	ITEM.Model = "models/props_junk/cardboard_box001a.mdl"
	items.Register("fact_importer",ITEM)
	
	local ITEM = {}
	ITEM.Name = "Pallet"
	ITEM.Desc = [[The Pallet is how you sell the goods you create.
	
	Each pallet can hold 16 items per layer. Upgrade them to increase the number of layers. 
	
	Click a pallet to sell the items.]]
	ITEM.BasePrice = 130
	ITEM.EntClass = "fact_pallet"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	ITEM.Model = "models/props_junk/wood_pallet001a.mdl"
	items.Register("fact_pallet",ITEM)
	
	hook.Run("InitFactoryItems")
	
end)