 
local plymeta = FindMetaTable("Player")

inv = inv or {}

function inv.Print(ply)
    for k,v in pairs((ply or Entity(1)):GetInventory())do
        print(v.ClassName, v.Quantity)
    end
end

function plymeta:GetInventory()
	return self.Inventory or {}
end

function plymeta:GetInvItem(class)
	return self:GetInventory()[self:GetInvIndex(class)]
end

function plymeta:GetInvIndex(item) --returns the index of an item or item class in a player's inventory. returns false if it doesn't exist in the inv.
	if type(item) == "table" then
		for k,v in pairs(self:GetInventory()) do
			if v == item then
				return k
			end
		end
		return false
	else
		for k,v in pairs(self:GetInventory())do
			if v:GetClass() == item then
				return k
			end
		end
		return false
	end
end
plymeta.HasInvItem = plymeta.GetInvIndex

function plymeta:AddInvItem(item, quan) --accepts a classname or an item object. If you give a classname it will create the item.
	quan = quan or 1
	local i = self:GetInventory()
	local index = self:GetInvIndex(item)
	if index then
		i[index].Quantity = i[index].Quantity + quan
		if CLIENT then
			local pnl = inv.GetPanel(i[index].ClassName)
			if IsValid(pnl) then
				pnl.quan:SetText(i[index].Quantity)
			end
		end
	else
		if isstring(item) then
			item = items.Create(item)
		end
		item.Quantity = quan
		item.Owner = self
		
		i[#i+1] = item
		
		if CLIENT and IsValid(g_SpawnMenu) then
			local pnl = g_SpawnMenu.inv:Add("InvItem")
			pnl:SetItem(item)
			pnl:Index()
		end
	end
	
	return item
	
	
end
plymeta.GiveInvItem = plymeta.AddInvItem --alias
function plymeta:RemoveInvItem(item, quan) --accepts an item object or a classname.
	quan = quan or 1
	local i = self:GetInventory()
	if istable(item) or isstring(item) then
		item = self:GetInvIndex( item )
	end
	if i[item].Quantity > quan then
		i[item].Quantity = i[item].Quantity - quan
		if CLIENT then
			local pnl = inv.GetPanel(i[item].ClassName)
			if IsValid(pnl) then
				pnl.quan:SetText(i[item].Quantity)
			end
		end
	else
		if CLIENT then
			local pnl = inv.GetPanel(i[item].ClassName)
			if IsValid(pnl) then
				pnl:Remove()
				g_SpawnMenu:SetItem()
			end
		end
		i[item].Owner = NULL
		table.remove(i, item)
	end
	
end
plymeta.TakeInvItem = plymeta.RemoveInvItem --alias

