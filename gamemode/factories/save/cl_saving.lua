net.Receive("fact_load",function()
	local ent = net.ReadEntity()
	local tbl = net.ReadTable()
	if IsValid(ent) then
		if ent.IsFloor then
			grid.AddFloor(LocalPlayer():GetFactory(), tbl.pos[1], tbl.pos[2], ent.Dimensions.w, ent.Dimensions.h, ent)
		else
			grid.AddItem(LocalPlayer():GetFactory(), tbl.pos[1], tbl.pos[2], ent.Dimensions.w, ent.Dimensions.h, ent)
		end
		ent:Load(tbl)
	end
end)