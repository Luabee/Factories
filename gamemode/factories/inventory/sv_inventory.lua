
local plymeta = FindMetaTable("Player")

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
		ply:AddMoney(math.floor(i.BasePrice*.8))
		ply:TakeInvItem(class)
	end
end)

function plymeta:SyncInventory(all) --this is a full sync of the inventory. 
	local inv = self:GetInventory()
	net.Start("fact_invsync")
		net.WriteEntity(self)
		net.WriteFloat(table.Count(inv))
		for k,v in pairs(inv)do
			net.WriteString(v.ClassName)
			net.WriteFloat(v.Quantity)
		end
	if all then
		net.Broadcast()
	else
		net.Send(self)
	end
end

function plymeta:ResetInventory()
	self.Inventory = {}
	self:GiveInvItem("fact_floor",3)
	self:GiveInvItem("fact_inserter",10)
	self:GiveInvItem("fact_conveyor",15)
	self:GiveInvItem("fact_assembler",2)
	self:GiveInvItem("fact_pallet",1)
	self:GiveInvItem("fact_miner",1)
	self:GiveInvItem("fact_furnace",2)
	self:SyncInventory()
end