
money = money or {}

local plymeta = FindMetaTable("Player")

function plymeta:SetMoney(new,nosave)
	if SERVER then
		self:SetNW2Float("fact_money", new)
	end
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
	return self:GetNW2Float("fact_money", GetConVarNumber("fact_money_start"))
end
function plymeta:CanAfford(amt)
	return self:GetMoney() >= amt
end
