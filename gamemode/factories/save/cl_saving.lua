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

local plymeta = FindMetaTable("Player")

function plymeta:SaveSlots()
	local slots = {}
	
	for k,v in pairs(inv.ItemPanels) do
		local slot = v:GetKeySlot()
		if slot != 0 then
			slots[v:GetItem().ClassName] = slot
		end
	end
	
	local json = util.TableToJSON(slots)
	cookie.Set("fact_slots_"..game.GetIPAddress(), json)
end
function plymeta:LoadSlots()
	local json = cookie.GetString("fact_slots_"..game.GetIPAddress(), "[]")
	local slots = util.JSONToTable(json)
	if istable(slots) and not table.IsEmpty(slots) then
		for k,v in pairs(inv.ItemPanels) do
			local slot = slots[v:GetItem().ClassName]
			if slot then
				v:SetKeySlot(slot)
			end
		end
	end
	
end