recipes = recipes or {}

--when making a recipe, specify any item as ingredients, any factory part as the thing it's made in, and any number as the time it takes.

function recipes.Set(itemclass, ...)
	
	local item = items.List[itemclass]
	
	if item then
		item.Recipe = recipes.Create(...)
	end
	
	return rec
end

function recipes.Create(...)
	local args = {...}
	local rec = {
		ingredients = {},
		time = 1,
		madeIn = "fact_assembler"
	}
	
	for k,part in pairs(args) do
		if isstring(part) then
			local num,part = part:match("(%d*)(.+)")
			num = tonumber(num)
			local other = items.List[part]
			if other and other.FactoryPart then
				rec.madeIn = part
			else
				rec.ingredients[part] = (rec.ingredients[part] or 0) + (num or 1)
			end
			
		elseif isnumber(part) then
			rec.time = part
		end
	end
	
	return rec
end