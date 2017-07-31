

research.AddCategory("production",{
	color = Color(161,48,52),
	levels = { --how much research is needed to acquire each level.
		0,
		300,
		10000,
	},
	benefits = { --the benefits unlocked at each level.
		{ --Level 1
			"Basic Assemblers",
			"Basic Miners",
			"Basic Furnaces",
		}, 
		{ --Level 2
			"Advanced Assemblers",
			"Advanced Miners",
			"Advanced Furnaces",
		},
		{ --Level 3
			"Ultra Assemblers",
			"Ultra Miners",
			"Ultra Furnaces",
		},
	},
	index = 1,  --how low on the list to put this category
})

research.AddCategory("logistics",{
	color = Color(253,253,129),
	levels = { --how much research is needed to acquire each level.
		0,
		300,
		10000,
		20000
	},
	benefits = { --the benefits unlocked at each level.
		{ --Level 1
			"Basic Conveyors",
			"Basic Inserters",
			"+1 Pallet Layer",
		}, 
		{ --Level 2
			"Fast Conveyors",
			"Fast Inserters",
			"+1 Pallet Layer",
		},
		{ --Level 3
			"Filter Conveyors",
			"Filter Inserters",
			"+1 Pallet Layer",
		},
		{ --Level 4
			"+1 Pallet Layer",
		},
	},
	index = 2, --how low on the list to put this category
})

research.AddCategory("personal",{
	color = Color(67,166,67),
	levels = { --how much research is needed to acquire each level.
		300,
		-- 2500
	},
	benefits = { --the benefits unlocked at each level.
		{ --Level 1
			"Pointshop Packs",
		}, 
		-- { --Level 2
			-- ""
		-- },
	},
	index = 3, --how low on the list to put this category
})
-- research.AddCategory("power",{
	-- levels = {
		-- 100,
		-- 1000,
		-- 10000
	-- },
	-- benefits = {},
-- })
-- research.AddCategory("cosmetic",{
	-- levels = {
		-- 100,
		-- 1000,
		-- 10000
	-- },
	-- benefits = {},
-- })

