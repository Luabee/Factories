 
local plymeta = FindMetaTable("Player")


function inv.BuyItem(class)
	if not LocalPlayer():CanAfford(items.List[class].BasePrice) then 
		notification.AddLegacy("You can't afford that.", NOTIFY_ERROR, 3)
		return 
	end
	
	net.Start("fact_buyitem")
		net.WriteString(class)
	net.SendToServer()
	
	surface.PlaySound("factories/coins.mp3")
	
	LocalPlayer():AddInvItem(class)
	
end

function inv.SellItem(class)
	net.Start("fact_sellitem")
		net.WriteString(class)
	net.SendToServer()
	
	LocalPlayer():TakeInvItem(class)
end

function inv.GetPanel(class)
	if istable(class) then class = class.ClassName end
	local pnl
	for k,v in pairs(inv.ItemPanels)do
		if IsValid(v) and v:GetItem().ClassName == class then
			pnl = v
			break
		end
	end
	return pnl
end

net.Receive("fact_invsync",function()
	local ply = net.ReadEntity()
	
	if ply == LocalPlayer() then
		ply:SaveSlots()
	end
	
	for k,v in pairs(ply:GetInventory()) do
		ply:RemoveInvItem(k,v.Quantity)
	end
	if IsValid(g_InHand) then g_InHand:Remove() end
	
	ply.Inventory = {}
	if IsValid(g_SpawnMenu) then	
		g_SpawnMenu:Update()
	end
	
	local size = net.ReadFloat()
	for i=1, size do
		ply:AddInvItem(net.ReadString(), net.ReadFloat())
	end
	
	if ply == LocalPlayer() then
		ply:LoadSlots()
	end
	
end)

function CreateInvMenu()
	if IsValid(g_PopUp) then g_PopUp:Close() end
	if IsValid(g_SpawnMenu) then 
		g_SpawnMenu:SetVisible(true) 
		g_SpawnMenu.shop:Populate() 
		return
	end
	
	local frame = vgui.Create("DFrame")
	g_SpawnMenu = frame
	frame:SetSize(700,400)
	frame:Center()
	frame:MakePopup()
	frame:SetKeyboardInputEnabled(false)
	frame:SetDeleteOnClose(false)
	frame:SetTitle("Factory Components")
	frame.lblTitle:SetFont("factRoboto24")
	frame.lblTitle:SetTextColor(color_white)
	frame.lblTitle:SetContentAlignment(7)
	frame.lblTitle:SizeToContents()
	function frame:Paint(w,h)
		surface.SetDrawColor(Color(0,0,0,220))
		surface.DrawRect(0,0,w,h)
		surface.SetDrawColor(color_black)
		self:DrawOutlinedRect()
	end
	function frame:Close()
		self:SetVisible(false)
		if IsValid(g_InHand) then
			g_InHand:SetParent()
		end
	end
	
	local tabs = vgui.Create("DPropertySheet",frame)
	tabs:Dock(LEFT)
	tabs:SetWide(343)
	
	
	//Inventory side
	local invScroll = vgui.Create( "DScrollPanel" ) //Create the Scroll panel
	-- invScroll:SetWide(335)
	invScroll:DockMargin(10,0,10,0)
	function invScroll:PaintOver(w,h)
		if IsValid(g_InHand) and (self:IsHovered() or self:IsChildHovered()) then
			local thick = 8
			local col = Color(220,220,220,math.cos(RealTime() * 6)*255/4 + 255*.75)
			
			surface.SetDrawColor(col)
			surface.DrawRect(0,0,w,thick)
			surface.DrawRect(w-thick,thick,thick,h-thick*2)
			surface.DrawRect(0,thick,thick,h-thick*2)
			surface.DrawRect(0,h-thick,w,thick)
		end
	end
	tabs:AddSheet("Inventory",invScroll,"icon16/bricks.png")

	local invpnl = vgui.Create( "DIconLayout", invScroll )
	invpnl:SetSize( 340, 200 )
	invpnl:SetPos( 0, 0 )
	invpnl:SetSpaceY( 5 ) //Sets the space in between the panels on the X Axis by 5
	invpnl:SetSpaceX( 5 ) //Sets the space in between the panels on the Y Axis by 5
	invpnl:SetMouseInputEnabled(true)
	function invpnl:OnMousePressed(mc)
		if mc == MOUSE_LEFT then
			if IsValid(g_InHand) then
				self:Add(g_InHand)
				g_InHand:SetInHand(false)
			end
		end
	end
	frame.inv = invpnl
	
	function invScroll:OnMousePressed(mc) invpnl:OnMousePressed(mc) end
	
	function frame:Update()
		local inventory = LocalPlayer():GetInventory()
		invpnl:Clear()
		if table.Count(inventory) == 0 then
			-- local empty = vgui.Create("DLabel",invScroll)
			-- empty:Dock(FILL)
			-- empty:DockMargin(0,20,0,0)
			-- empty:SetText("\n\n\nYour inventory is empty.")
			-- empty:SetFont("factRoboto30")
			-- empty:SetTextColor(color_white)
			-- empty:SetExpensiveShadow(1,color_black)
			-- empty:SetContentAlignment(5)
		else
			for k,v in pairs(inventory) do
				local ListItem = invpnl:Add( "InvItem" ) //Add DPanel to the DIconLayout
				ListItem:Index()
				ListItem:SetItem(v)
			end
		end
		if IsValid(g_Hotbar) then
			for i=0,8 do
				g_Hotbar.Slot[i+1]:Remove()
				g_Hotbar:CreateSlot(i)
			end
		end
	end
	frame:Update()
	
	
	//Shop side
	local shopScroll = vgui.Create( "DScrollPanel" ) //Create the Scroll panel
	-- invScroll:SetWide(335)
	shopScroll:DockMargin(10,0,10,0)
	shopScroll:SetMouseInputEnabled(true)
	function shopScroll:PaintOver(w,h)
		if IsValid(g_InHand) and (self:IsHovered() or self:IsChildHovered()) then
			local thick = 8
			local col = Color(50,255,50,math.cos(RealTime() * 6)*255/4 + 255*.75)
			surface.SetDrawColor(Color(0,0,0,200))
			surface.DrawRect(0,0,w,h)
			
			surface.SetDrawColor(col)
			surface.DrawRect(0,0,w,thick)
			surface.DrawRect(w-thick,thick,thick,h-thick*2)
			surface.DrawRect(0,thick,thick,h-thick*2)
			surface.DrawRect(0,h-thick,w,thick)
			
			local t = "Sell for $"..string.Comma(g_InHand:GetItem().BasePrice)
			draw.SimpleText(t, "factRoboto44", w/2+1, h/2+1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(t, "factRoboto44", w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	function shopScroll:OnMousePressed()
		if IsValid(g_InHand) then
			inv.SellItem(g_InHand:GetItem().ClassName)
		end
	end
	local store = tabs:AddSheet("Shop",shopScroll,"icon16/money.png")

	local shop = vgui.Create( "DIconLayout", shopScroll )
	shop:SetSize( 340, 200 )
	shop:SetPos( 0, 0 )
	shop:SetSpaceY( 5 ) //Sets the space in between the panels on the X Axis by 5
	shop:SetSpaceX( 5 ) //Sets the space in between the panels on the Y Axis by 5
	shop.OnMousePressed = shopScroll.OnMousePressed
	frame.shop = shop
	function shop:Populate()
		self:Clear()
		for k,v in SortedPairsByMemberValue(items.List,"Level") do //populate the store.
			if v.FactoryPart and (!v.NeedsResearch or LocalPlayer():GetResearchLevel(v.NeedsResearch) >= v.Level) then
				local ListItem = self:Add( "InvItem" ) //Add DPanel to the DIconLayout
				ListItem:SetForSale(true)
				ListItem:SetItem(v)
				
			end
		end
	end
	shop:Populate()
	
	
	//Recipe side
	local itemsBG = vgui.Create("Panel")
	itemsBG:DockMargin(10,0,10,0)
	
	local itemScroll = vgui.Create("DScrollPanel",itemsBG)
	itemScroll:Dock(FILL)
	itemScroll:DockMargin(0,25,0,0)
	itemScroll:SetMouseInputEnabled(true)
	
	local gloss = vgui.Create( "DIconLayout", itemScroll )
	gloss:SetSize( 340, 180 )
	gloss:SetPos( 0, 0 )
	gloss:SetSpaceY( 5 ) //Sets the space in between the panels on the X Axis by 5
	gloss:SetSpaceX( 5 ) //Sets the space in between the panels on the Y Axis by 5
	gloss.OnMousePressed = itemScroll.OnMousePressed
	frame.gloss = gloss
	function gloss:Populate(txt)
		self:Clear()
		
		local tbl = {}
		for k,v in pairs(items.List) do --descending order doesn't work so we do it manually
			tbl[#tbl+1] = v
		end
		
		table.sort(tbl, function(a,b)
			if a.Level != b.Level then
				return a.Level > b.Level
			end
			return a.BasePrice > b.BasePrice
		end)
		
		for k,v in ipairs(tbl) do //populate the store.
			if !v.FactoryPart --[[and (!v.NeedsResearch or LocalPlayer():GetResearchLevel(v.NeedsResearch) >= v.Level)]] then
				if txt and !v.Name:lower():find(txt:lower(),1,true) then continue end
				local ListItem = self:Add( "InvItem" ) //Add DPanel to the DIconLayout
				ListItem:SetForSale(true)
				ListItem:SetItem(v)
				function ListItem:OnMousePressed(mb)
					frame:SetItem(v)
				end
				
			end
		end
	end
	gloss:Populate()
	
	local search = vgui.Create("DTextEntry",itemsBG)
	search:SetPos(0,0)
	search:SetTall(20)
	search:SetWide(325)
	search:SetText("Search...")
	search:SetUpdateOnType(true)
	function search:OnGetFocus()
		self:SelectAll()
		frame:SetKeyboardInputEnabled(true)
	end
	function search:OnLoseFocus()
		frame:SetKeyboardInputEnabled(false)
	end
	function search:OnValueChange(new)
		gloss:Populate(new)
	end
	
	
	local glossary = tabs:AddSheet("Item Glossary",itemsBG,"icon16/book_open.png")
	
	//Selected item details side
	local selectedSide = vgui.Create("Panel",frame)
	selectedSide:Dock(RIGHT)
	selectedSide:DockMargin(0,20,0,0)
	selectedSide:SetWide(343)
	function selectedSide:Paint(w,h)
		draw.RoundedBox(0,0,0,w,h,Color(80,80,80,255))
		draw.RoundedBoxEx(0,0,0,w,59,Color(0,0,0,170),true,true,false,false)
		-- draw.RoundedBoxEx(0,0,h-132,w,132,Color(0,0,0,170),false,false,true,true)
		draw.RoundedBoxEx(0,0,h-100,w,100,Color(0,0,0,170),false,false,true,true)
		surface.SetDrawColor(color_black)
		self:DrawOutlinedRect()
	end
	
	//Title of selected item
	local preTitle = vgui.Create("DLabel",selectedSide)
	preTitle:Dock(TOP)
	preTitle:DockMargin(0,5,0,0)
	preTitle:SetText(" ")
	preTitle:SetFont("factRoboto26")
	preTitle:SetTextColor(color_white)
	preTitle:SetExpensiveShadow(1,color_black)
	preTitle:SetContentAlignment(8)
	preTitle:SizeToContents()
	
	local prePrice = vgui.Create("DLabel",selectedSide)
	prePrice:Dock(TOP)
	prePrice:DockMargin(0,5,0,0)
	prePrice:SetText(" ") --debug
	prePrice:SetFont("factRoboto18")
	prePrice:SetTextColor(Color(100,255,100))
	prePrice:SetExpensiveShadow(1,color_black)
	prePrice:SetContentAlignment(8)
	prePrice:SizeToContents()
	
	
	//Preview model
	local preview = vgui.Create("ItemPreview",selectedSide)
	preview:Dock(TOP)
	preview:DockMargin(0,5,5,0)
	preview:SetTall(187)
	frame.preview = preview
	
	local preDescScr = vgui.Create("DScrollPanel",selectedSide)
	preDescScr:Dock(TOP)
	preDescScr:SetTall(73)
	preDescScr:GetCanvas():DockPadding(0,-5,5,5)
	frame.preDescScr = preDescScr
	
	local preDescLbl = vgui.Create("DLabel",preDescScr)
	preDescLbl:Dock(TOP)
	preDescLbl:DockMargin(5,6,5,5)
	preDescLbl:SetAutoStretchVertical(true)
	preDescLbl:SetWrap(true)
	preDescLbl:SetContentAlignment(7)
	preDescLbl:SetFont("factRoboto16")
	preDescLbl:SetText(" ")
	
	local buySell = vgui.Create("DButton",selectedSide)
	frame.buySell = buySell
	buySell:Dock(TOP)
	buySell:SetText("Sell")
	buySell:SetFont("factRoboto20")
	buySell:SetTextColor(color_black)
	buySell:SetTall(30)
	buySell.oldOMP = buySell.OnMousePressed
	function buySell:OnMousePressed(mb)
		self:oldOMP(mb)
		if self:GetText() == "Buy" then
			inv.BuyItem(frame.Item.ClassName)
		else
			inv.SellItem(frame.Item.ClassName)
		end
	end
	
	local recipe = vgui.Create("RecipeTree",selectedSide)
	recipe:Dock(TOP)
	recipe:DockMargin(5,4,5,0)
	recipe:SetSize(250,50)
	recipe:SetVisible(false)
	function recipe:OnItemClicked(itemclass,pnl)
		frame:SetItem(items.List[itemclass])
	end
	
	function frame:SetItem(i)
		if not i then
			self.Item = nil
			self.preview:SetModel()
			self.preview:SetEntity()
			preTitle:SetText(" ")
			preDescLbl:SetText(" ")
			prePrice:SetText(" ")
			buySell:SetVisible(false)
			preDescScr:SetTall(102)
			return
		end
		
		if i != self.Item then
			self.Item = i
			self.preview:SetMaterial(i.Material)
			self.preview:SetModel(i.Model)
			self.preview:SetLevel(i.Level)
			self.preview:SetEntity(i.EntClass)
			preTitle:SetText(i.Name)
			preDescLbl:SetText(i.Desc)
			prePrice:SetText("$"..string.Comma(i.BasePrice))
			recipe:SetRecipe(i.Recipe)
		end
		if store.Tab:IsActive() then
			preDescScr:SetTall(72)
			buySell:SetText("Buy")
			buySell:Dock(TOP)
			recipe:Dock(NODOCK)
			buySell:SetVisible(true)
			recipe:SetVisible(false)
		elseif glossary.Tab:IsActive() then
			preDescScr:SetTall(42)
			buySell:SetVisible(false)
			buySell:Dock(NODOCK)
			recipe:Dock(TOP)
			recipe:SetVisible(true)
		else
			preDescScr:SetTall(102)
			buySell:SetVisible(false)
			recipe:SetVisible(false)
			buySell:Dock(NODOCK)
			recipe:Dock(NODOCK)
		end
	end
	if IsValid(g_InHand) then
		frame:SetItem(g_InHand:GetItem())
	end
	
end
hook.Add("OnSpawnMenuOpen","fact_openInventory",function()
	if IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible() then
		g_SpawnMenu:SetVisible(false)
		if IsValid(g_InHand) then
			g_InHand:SetParent()
		end
	else
		CreateInvMenu()
	end
end)
-- hook.Add("OnSpawnMenuClose","fact_openInventory",function()
	-- if IsValid(g_SpawnMenu) then
		-- g_SpawnMenu:SetVisible(false)
		-- if IsValid(g_InHand) then
			-- g_InHand:SetParent()
		-- end
	-- end
-- end)

function CreateHotbar()
	local hotbar = vgui.Create("Panel",g_MouseInput)
	hotbar:SetSize(500,60)
	hotbar:CenterHorizontal()
	hotbar:AlignBottom(0)
	hotbar:MoveToFront()
	local col = Color(0,0,0,200)
	function hotbar:Paint(w,h)
		draw.RoundedBoxEx(4,0,0,w,h,col,true, true, false, false)
	end
	hotbar.Slot = {}
	
	local bgcol = Color(100,100,100,200)
	local hovercol = Color(240,240,240)
	function hotbar:CreateSlot(i)
		local pnl = vgui.Create("Panel",self)
		pnl:SetSize(50,50)
		pnl:SetPos(i*50+i*5+5,5)
		function pnl:Paint(w,h)
			surface.SetDrawColor(bgcol)
			surface.DrawRect(0,0,w,h)
			if !self:IsHovered() then
				surface.SetDrawColor(color_black)
			else
				surface.SetDrawColor(hovercol)
			end
			surface.DrawOutlinedRect(0,0,w,h)
		end
		function pnl:OnMousePressed()
			if IsValid(g_InHand) then
				self:Remove()
				g_InHand:SetKeySlot(i+1)
				g_InHand:SetInHand(false)
			end
		end
		
		local lbl = vgui.Create("DLabel",pnl)
		lbl:SetText(i+1)
		lbl:SetTextColor(Color(200,200,0))
		lbl:SetFont("factRoboto14")
		lbl:SetContentAlignment(1)
		lbl:Dock(FILL)
		lbl:DockMargin(4,2,2,2)
		self.Slot[i+1] = pnl
		return pnl
	end
	
	for i=0,8 do
		hotbar:CreateSlot(i)
	end
	
	
	g_Hotbar = hotbar
end
hook.Add("InitPostEntity","fact_showHotbar",CreateHotbar)

hook.Add("PlayerBindPress","fact_hotbarSlots",function(ply,bind,down)
	local hotbar = g_Hotbar
	local slot = tonumber(bind:match("slot(%d)"))
	if slot and down and IsValid(hotbar) then
		local hovered = vgui.GetHoveredPanel()
		local slotPnl = g_Hotbar.Slot[slot]
		
		if hovered.Item then
			if hovered:GetForSale() then
			else
				-- if IsValid(slotPnl) and slotPnl.Item then
					-- slotPnl:SetKeySlot(0)
					-- slotPnl:SetInHand(true)
				-- end
				-- hovered:SetKeySlot(slot)
			end
		else
			-- slotPnl:OnMousePressed(MOUSE_LEFT)
		end
	end
end)
