mousein = mousein or {}

function GM:PlayerCanBreak(ply,target)
	if IsValid(target) and target.IsFactoryPart and ply:HasPermission(target:GetMaker(),PERMISSION_ALL) then
		if target.IsFloor then
			local fac = ply:GetFactory()
			local x,y = target:GetGridPos()
			local w,h = target:GetSize()
			if !grid.CanPlace(fac, x, y, w, h) then
				return false
			end
			-- local count = 0
			-- for k,v in pairs(ents.FindByClass("*floor*"))do
				-- if v:GetMaker() == ply then
					-- count = count + 1
					-- if count == 2 then break end
				-- end
			-- end
			-- if count == 1 then return false end
		end
		return true
	end
	return false
end