
local plymeta = FindMetaTable("Player")

inv.List = inv.List or {} --this houses all the players' items.
util.AddNetworkString("fact_invsync")
util.AddNetworkString("fact_buyitem")
util.AddNetworkString("fact_sellitem")

net.Receive("fact_buyitem",function(len,ply)
	local class = net.ReadString()
	local i = items.List[class]
	if ply:CanAfford(i.BasePrice) then
		ply:AddMoney(-i.BasePrice)
		ply:GiveInvItem(class)
		
		-- for k,v in pairs(ply:GetInventory())do
			-- print(v.Name,v.Quantity)
		-- end
		-- ply:SyncInventory()
	end
end)

net.Receive("fact_sellitem",function(len,ply)
	local class = net.ReadString()
	local i = items.List[class]
	if ply:HasInvItem(class) then
		ply:AddMoney(i.BasePrice)
		ply:TakeInvItem(class)
	end
end)

hook.Add("PlayerInitialSpawn","fact_SetupInv",function(ply)
	inv.List[ply] = {}
	ply:LoadInventory()
	ply:SetMoney(10000) --testing
end)
hook.Add("PlayerDisconnected","fact_SetupInv",function(ply)
	ply:SaveInventory()
	inv.List[ply] = nil
end)
hook.Add("ShutDown","fact_SetupInv",function()
	for k,ply in pairs(player.GetAll()) do
		ply:SaveInventory()
	end
end)

function plymeta:GetInventory()
	return inv.List[self]
end
function plymeta:SyncInventory(all) --this is a full sync of the inventory. 
	net.Start("fact_invsync")
		net.WriteEntity(self)
		net.WriteFloat(table.Count(inv.List[self]))
		for k,v in pairs(self:GetInventory())do
			net.WriteString(v.ClassName)
			net.WriteFloat(v.Quantity)
		end
	if all then
		net.Broadcast()
	else
		net.Send(self)
	end
end
function plymeta:SaveInventory()
	--todo
end
function plymeta:LoadInventory()
	--todo
end
