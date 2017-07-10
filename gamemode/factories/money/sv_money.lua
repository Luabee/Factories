
local plymeta = FindMetaTable("Player")

function plymeta:LoadMoney()
	self:SetMoney(self:GetPData("fact_money", GetConVarNumber("fact_money_start")),true)
end