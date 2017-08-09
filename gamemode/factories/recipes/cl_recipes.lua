
local PNL = {}
AccessorFunc(PNL,"Recipe","Recipe")
-- AccessorFunc(PNL,"ShowMadeIn","ShowMadeIn",FORCE_BOOL)

function PNL:Init()
	self:SetOverlap(-5)
	self:SetTall(50)
	-- self:SetShowMadeIn(true)
	
end

function PNL:SetRecipe(rec)
	self.Recipe = rec
	self:Update()
end

function PNL:Update()
	self:Clear()
	
	if !self.Recipe.ingredients then
		return
	end
	
	local cur, max = 0, table.Count(self.Recipe.ingredients)
	for k,v in pairs(self.Recipe.ingredients) do
		local item = items.Create(k)
		if not item then continue end
		
		cur = cur + 1
		local ii = vgui.Create("InvItem")
		self:AddPanel(ii)
		item.Quantity = v
		-- ii:SetForSale(true)
		ii:SetItem(item)
		ii.OnMousePressed = function() end
		function ii.OnMouseReleased()
			self:OnItemClicked(k,ii)
		end
		
		if cur < max then
			local symbol = vgui.Create("DLabel")
			symbol:SetFont("factRoboto48")
			symbol:SetText("＋")
			symbol:SizeToContents()
			symbol:SetTextColor(color_white)
			symbol:SetExpensiveShadow(1,color_black)
			symbol:SetContentAlignment(5)
			self:AddPanel(symbol)
		end
		
	end
	
	-- if self:GetShowMadeIn() then
		local arrow = vgui.Create("DLabel")
		arrow:SetFont("factRoboto48")
		arrow:SetText("➔")
		arrow:SizeToContents()
		arrow:SetTextColor(color_white)
		arrow:SetExpensiveShadow(1,color_black)
		arrow:SetContentAlignment(5)
		self:AddPanel(arrow)
		
		local into = vgui.Create("InvItem")
		self:AddPanel(into)
		for k,v in pairs(items.List)do
			if k:find( self.Recipe.madeIn ) and v.Level == self.Recipe.level then
				into:SetItem(v)
				break
			end
		end
		into.quan:SetVisible(false)
		into.OnMousePressed = function() end
	-- end
	
end

function PNL:Clear()
	self.pnlCanvas:Clear()
	self.Panels = {}
	self:InvalidateLayout( true )
end

function PNL:OnItemClicked(itemclass,pnl)
	--override
end

vgui.Register("RecipeTree",PNL,"DHorizontalScroller")
