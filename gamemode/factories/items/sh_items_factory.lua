
hook.Add("Initialize","fact_items_factory",function()

	local ITEM = {}
	ITEM.Name = "Inserter"
	ITEM.Desc = [[The Inserter picks up items and places them on the opposite side.

	It also pulls items out of containers such as furnaces and assemblers.

	Inserters always place their item on the far end of a conveyor.]]
	ITEM.BasePrice = 60
	ITEM.EntClass = "fact_inserter"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	ITEM.NeedsResearch = "logistics"
	ITEM.Model = "models/props_wasteland/buoy01.mdl"
	items.Register("fact_inserter", ITEM)
	
	ITEM.Level = 2
	ITEM.BasePrice = 105
	ITEM.Name = "Filter Inserter"
	items.Register("fact_inserter2",ITEM)
	ITEM.Level = 3
	ITEM.BasePrice = 200
	ITEM.Name = "Fast Inserter"
	items.Register("fact_inserter3",ITEM)

	local ITEM = {}
	ITEM.Name = "Conveyor"
	ITEM.Desc = [[Conveyors move items across your factory.

	They have two separate sides which pull on different tracks.]]
	ITEM.BasePrice = 15
	ITEM.Model = "models/hunter/plates/plate1x1.mdl"
	ITEM.Material = "phoenix_storms/futuristictrackramp_1-2"
	ITEM.EntClass = "fact_conveyor"
	ITEM.NeedsResearch = "logistics"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	items.Register("fact_conveyor", ITEM)
	
	ITEM.Level = 2
	ITEM.BasePrice = 25
	ITEM.Name = "Filter Conveyor"
	items.Register("fact_conveyor2",ITEM)
	ITEM.Level = 3
	ITEM.BasePrice = 50
	ITEM.Name = "Fast Conveyor"
	items.Register("fact_conveyor3",ITEM)

	local ITEM = {}
	ITEM.Name = "Assembler"
	ITEM.Desc = [[An assembler combines materials to create new items.
	
	The resulting product must be pulled out with an inserter.]]
	ITEM.BasePrice = 250
	ITEM.Model = "models/props_phx/construct/metal_wire1x2x2b.mdl"
	ITEM.EntClass = "fact_assembler"
	ITEM.NeedsResearch = "production"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	items.Register("fact_assembler", ITEM)
	
	ITEM.Level = 2
	ITEM.BasePrice = 550
	ITEM.Name = "Advanced Assembler"
	items.Register("fact_assembler2",ITEM)
	ITEM.Level = 3
	ITEM.Name = "Ultra Assembler"
	ITEM.BasePrice = 1300
	items.Register("fact_assembler3",ITEM)

	local ITEM = {}
	ITEM.Name = "Furnace"
	ITEM.Desc = [[Furnaces cook single materials into their refined counterparts.

	Only certain items can be smelted in a furnace.]]
	ITEM.BasePrice = 200
	ITEM.EntClass = "fact_furnace"
	ITEM.ForSale = true
	ITEM.NeedsResearch = "production"
	ITEM.Model = "models/props_c17/furniturefireplace001a.mdl"
	ITEM.FactoryPart = true
	items.Register("fact_furnace", ITEM)
	
	ITEM.Level = 2
	ITEM.BasePrice = 450
	ITEM.Name = "Advanced Furnace"
	items.Register("fact_furnace2",ITEM)
	ITEM.Level = 3
	ITEM.BasePrice = 1000
	ITEM.Name = "Ultra Furnace"
	items.Register("fact_furnace3",ITEM)

	local ITEM = {}
	ITEM.Name = "Miner"
	ITEM.Desc = [[Miners pull ore from the earth.

	Use inserters to place the ore onto conveyors.]]
	ITEM.BasePrice = 1200
	ITEM.EntClass = "fact_miner"
	ITEM.Model = "models/props_phx/construct/metal_wire1x2x2b.mdl"
	ITEM.NeedsResearch = "production"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	items.Register("fact_miner", ITEM)
	
	ITEM.Level = 2
	ITEM.BasePrice = 2500
	ITEM.Name = "Advanced Miner"
	items.Register("fact_miner2",ITEM)
	ITEM.Level = 3
	ITEM.Name = "Ultra Miner"
	ITEM.BasePrice = 4000
	items.Register("fact_miner3",ITEM)

	-- local ITEM = {}
	-- ITEM.Name = "Power Pylon"
	-- ITEM.Desc = [[Provides power to nearby factory components.

	-- Without power, these components will cease to function.]]
	-- ITEM.BasePrice = 40
	-- ITEM.EntClass = "fact_pylon"
	-- ITEM.ForSale = true
	-- ITEM.FactoryPart = true
	-- items.Register("fact_pylon", ITEM)

	local ITEM = {}
	ITEM.Name = "Factory Floor"
	ITEM.Desc = [[Add on to your factory by building more floor space.]]
	ITEM.BasePrice = 1000
	ITEM.EntClass = "fact_floor"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	ITEM.Model = "models/hunter/plates/plate4x4.mdl"
	ITEM.Material = "phoenix_storms/metalfloor_2-3"
	items.Register("fact_floor",ITEM)

	local ITEM = {}
	ITEM.Name = "Importer"
	ITEM.Desc = [[The Importer buys materials from the market at an inflated price.

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
	
	local ITEM = {}
	ITEM.Name = "Lab"
	ITEM.Desc = [[The Lab converts Research Packs into new technologies.
	
	The Lab works like a pallet. Once it's full of research packs, you have to click it to use them.]]
	ITEM.BasePrice = 1000
	ITEM.EntClass = "fact_lab"
	ITEM.ForSale = true
	ITEM.FactoryPart = true
	ITEM.Model = "models/props_lab/servers.mdl"
	items.Register("fact_lab",ITEM)
	
	hook.Run("InitFactoryItems") --Create our factory items before we make our other items.
	
end)