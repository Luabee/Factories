
research = research or {}
research.r = "Ʀ"
research.sr = " "..research.r
research.List = research.List or {}

research.LevelMats = {
	(Material("factories/tech/tech_red")),
	(Material("factories/tech/tech_green")),
	(Material("factories/tech/tech_blue")),
	(Material("factories/tech/tech_pink")),
}
research.LevelColors = {
	Color(120,80,80,200),
	Color(80,120,80,200),
	Color(80,80,120,200),
	Color(255,0,255,200),
}
research.LevelModelMats = {
	"phoenix_storms/wire/pcb_red",
	"phoenix_storms/wire/pcb_green",
	"phoenix_storms/wire/pcb_blue",
	"factories/tech/tech_modelpink",
}



research.LevelColors[0] = research.LevelColors[1]
research.LevelMats[0] = research.LevelMats[1]
research.LevelModelMats[0] = research.LevelModelMats[1]

function research.AddCategory(name,val)
	research.List[name] = val
end

local plymeta = FindMetaTable("Player")

function plymeta:SetResearchCategory(cat)
	self:SetNW2String("fact_researchcat", cat)
end
function plymeta:GetResearchCategory()
	return self:GetNW2String("fact_researchcat","production")
end

function plymeta:SetResearch(new,cat)
	cat = cat or self:GetResearchCategory()
	if SERVER then
		self:SetNW2Float("fact_research_"..cat, new)
	end
end
function plymeta:AddResearch(amt, source, cat)
	cat = cat or self:GetResearchCategory()
	local b = self:GetNeededResearch(cat) <= amt
	if SERVER then
		self:SetResearch(self:GetResearch(cat) + amt)
	elseif CLIENT and isvector(source) and amt != 0 then
		table.insert(research.incomes,{source,amt,RealTime()})
	end
	if b then
		hook.Run("OnResearchGained",cat,self:GetResearchLevel(cat))
	end
end
function plymeta:GetResearch(cat)
	cat = cat or self:GetResearchCategory()
	return self:GetNW2Float("fact_research_"..cat, 0)
end

function plymeta:GetNeededResearch(cat)
	cat = cat or self:GetResearchCategory()
	return (research.List[cat].levels[self:GetResearchLevel(cat)+1] or 0) - self:GetResearch(cat)
end

function plymeta:GetResearchLevel(cat)
	cat = cat or self:GetResearchCategory()
	local res = self:GetResearch(cat)
	local level = 0
	while research.List[cat].levels[level+1] and res >= research.List[cat].levels[level+1] do
		level = level + 1
	end
	
	return level
end

function plymeta:HasResearch(cat,level)
	cat = cat or self:GetResearchCategory()
	return self:GetResearchLevel(cat) >= level
end

function plymeta:ResetResearch()
	for k,v in pairs(research.List)do
		-- if k == "production" or k == "logistics" then 
			-- self:SetResearch(v.levels[1],k)
		-- else
			self:SetResearch(0,k)
		-- end
	end
end