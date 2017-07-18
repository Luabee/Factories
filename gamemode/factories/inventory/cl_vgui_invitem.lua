local PANEL = {}

inv.ItemPanels = inv.ItemPanels or {}

AccessorFunc(PANEL,"ForSale","ForSale",FORCE_BOOL)
AccessorFunc(PANEL,"Item","Item")
AccessorFunc(PANEL,"InHand","InHand", FORCE_BOOL)
AccessorFunc(PANEL,"KeySlot","KeySlot", FORCE_NUMBER)

function PANEL:Init()
	
	
	self:SetSize(50,50)
	
	self.mdl = vgui.Create("ItemPreview",self)
	self.mdl:Dock(FILL)
	self.mdl:SetMouseInputEnabled(false)
	
	self.price = vgui.Create("DLabel",self)
	self.price:SetFont("factRoboto14")
	self.price:SetTextColor(Color(80,255,80))
	self.price:SetExpensiveShadow(1,color_black)
	self.price:SetText("$"..string.Comma(4500))
	self.price:Dock(FILL)
	self.price:DockMargin(2,2,4,2)
	self.price:SetContentAlignment(3)
	
	self.quan = vgui.Create("DLabel",self)
	self.quan:SetFont("factRoboto14")
	self.quan:SetTextColor(color_white)
	self.quan:SetExpensiveShadow(1,color_black)
	self.quan:SetText("")
	self.quan:Dock(FILL)
	self.quan:DockMargin(4,2,2,2)
	self.quan:SetContentAlignment(7)
	
	
	self.key = vgui.Create("DLabel",self)
	self.key:SetFont("factRoboto14")
	self.key:SetTextColor(Color(200,200,0))
	self.key:SetText("")
	self.key:Dock(FILL)
	self.key:DockMargin(4,2,2,2)
	self.key:SetContentAlignment(1)
	self.key:SetVisible(false)
	
	
	self:SetForSale(false)
	self.KeySlot = 0
end

function PANEL:OnRemove()
	if self.id then
		table.remove(inv.ItemPanels, self.id)
	end
end

function PANEL:Index()
	self.id = #inv.ItemPanels + 1
	inv.ItemPanels[self.id] = self
end

local bgcol = Color(100,100,100,200)
local bgcol_finishedProduct = Color(80,80,120,200)
local bgcol_locked = Color(120,80,80,200)
local hovercol = Color(240,240,240)
function PANEL:Paint(w,h)

	if self:GetItem() and self:GetItem().FinishedProduct then
		surface.SetDrawColor(bgcol_finishedProduct)
	else
		surface.SetDrawColor(bgcol)
	end
	surface.DrawRect(0,0,w,h)
	
	-- surface.SetDrawColor(color_white)
	-- surface.SetMaterial(research.LevelMats[self:GetItem().Level])
	-- surface.DrawTexturedRectUV(0,0,w,h,0,0,w/600,h/600)
	surface.SetDrawColor(research.LevelColors[self:GetItem().Level])
	surface.DrawRect(0,0,w,h)
	
	-- surface.SetDrawColor(Color(0,0,0,240))
	-- surface.DrawRect(0,0,w,h)
	
end

function PANEL:PaintOver()
	if !self:IsHovered() or (IsValid(g_InHand) and self:GetForSale()) then
		surface.SetDrawColor(color_black)
	else
		surface.SetDrawColor(hovercol)
	end
	self:DrawOutlinedRect()
end

function PANEL:Think()
	if self:GetInHand() then
		local w, h = self:GetSize()
		local mx,my = math.Clamp(gui.MouseX()-w/2+2, 0, ScrW()-w), gui.MouseY()+20
		my = my < ScrH() - h and my or my - 30 - h
		if g_SpawnMenu:IsVisible() then
			local pw, ph = g_SpawnMenu:GetSize()
			local px, py = g_SpawnMenu:GetPos()
			if mx >= px+pw or mx+w <= px or my+h <= py or my >= py+ph then
				self:SetParent()
			else
				self:SetParent(g_SpawnMenu)
			end
		end
		
		self:SetPos(self:GetParent():ScreenToLocal(mx,my))
	elseif not IsValid(g_InHand) and not self:GetForSale() and self.id then
		if self:IsHovered() and IsValid(g_SpawnMenu) then
			g_SpawnMenu:SetItem(self:GetItem())
		end
	end
end

function PANEL:OnMousePressed(mc)
	g_SpawnMenu:SetItem(self:GetItem())
	if not self:GetForSale() then
		local key = self:GetKeySlot()
		self:SetKeySlot(0)
		if IsValid(g_InHand) and key != 0 then
			g_InHand:SetKeySlot(key)
			g_InHand:SetInHand(false)
		end
		
		self:SetInHand(true)
		
		-- mousein.Ghost:SetModel(self:GetItem().Model)
		-- local sent = scripted_ents.GetStored(self:GetItem().EntClass)
		-- if sent then
			-- sent = sent.t
			-- if sent.SetupPreview then
				-- sent.SetupPreview(mousein.Ghost)
			-- end
		-- end
	elseif IsValid(g_InHand) then
		inv.SellItem(g_InHand:GetItem().ClassName)
	elseif mc == MOUSE_RIGHT then
		inv.BuyItem(self:GetItem().ClassName)
	end
end

function PANEL:ApplySchemeSettings(mc)
	
end

function PANEL:SetItem(i)
	
	self.Item = i
	
	self.price:SetText("$"..string.Comma(i.BasePrice))
	self.quan:SetText(i.Quantity)
	
	//Set the model
	self.mdl:SetMaterial(i.Material)
	self.mdl:SetModel(i.Model)
	self.mdl:SetEntity(i.EntClass)
	self.mdl:SetLevel(i.Level)
	
	self:SetTooltip(i.Name)
	
	
end

function PANEL:SetForSale(b)
	self.ForSale = b
	self.price:SetVisible(b)
	self.quan:SetVisible(!b)
end

function PANEL:SetKeySlot(i)
	local old = self.KeySlot
	if i == old then return end
	
	self.KeySlot = i
	self.key:SetVisible(i!=0)
	if i != 0 then --adding it
		g_Hotbar.Slot[i] = self
		self:SetParent(g_Hotbar)
		self:SetPos((i-1)*50+(i-1)*5+5,5)
		self.key:SetVisible(true)
		self.key:SetText(i)
	elseif old != 0 then --removing it
		g_Hotbar:CreateSlot(old-1)
		self.key:SetVisible(false)
	end
	
end

function PANEL:SetInHand(b)
	self.InHand = b
	if b then
		if IsValid(g_InHand) then
			g_SpawnMenu.inv:Add(g_InHand)
			g_InHand:SetInHand(false)
		end
		g_InHand = self
		self:SetParent()
		g_SpawnMenu.buySell:SetText("Sell")
		g_SpawnMenu.buySell:SetVisible(true)
		g_SpawnMenu.preDescScr:SetTall(102)
	else
		g_SpawnMenu.buySell:SetVisible(false)
		g_SpawnMenu.preDescScr:SetTall(132)
		g_InHand = nil
	end
	
	self:NoClipping(b)
	
end


vgui.Register("InvItem",PANEL,"Panel")