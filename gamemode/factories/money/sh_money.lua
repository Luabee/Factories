
money = money or {}

local plymeta = FindMetaTable("Player")

function plymeta:SetMoney(new)
	if SERVER then
		self:SetNWFloat("fact_money", new)
	end
	self:SaveMoney()
end
function plymeta:AddMoney(amt, source)
	if SERVER then
		self:SetMoney(self:GetMoney() + amt)
	elseif CLIENT and isvector(source) and amt != 0 then
		table.insert(money.incomes,{source,amt,RealTime()})
	end
end
plymeta.GiveMoney = plymeta.AddMoney

function plymeta:GetMoney()
	return self:GetNWFloat("fact_money",-1)
end
function plymeta:CanAfford(amt)
	return self:GetMoney() >= amt
end
