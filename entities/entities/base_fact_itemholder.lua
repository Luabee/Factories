
if SERVER then 
	AddCSLuaFile()
	resource.AddFile("sound/factories/chaching.mp3")
	resource.AddFile("sound/factories/coins.mp3")
end

ENT.Base = "base_fact"

ENT.IsItemHolder = true


function ENT:Initialize()
	
	self:SetSize(self.Dimensions.w, self.Dimensions.h)
	self:SetModel("models/props_junk/cardboard_box004a.mdl")
	self:SetupPreview()
	
	self:SetupTables()
	
	if ConVars.Server.collisions:GetBool() then
		self:PhysicsInit(SOLID_VPHYSICS)
		if SERVER then
			local phy = self:GetPhysicsObject()
			if IsValid(phy) then
				phy:EnableMotion(false)
			end
		end
	end
	
	timer.Simple(.5,function()
		if IsValid(self) then
			self:UpdateInOut()
			for k,v in pairs(self:GetAdjacentEnts())do
				if v.IsItemHolder then
					v:UpdateInOut()
				end
			end
		end
	end)
	
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ItemClass") 
	self:NetworkVar("Entity", 0, "Maker") 
	self:NetworkVar("Int", 0, "GridX") 
	self:NetworkVar("Int", 1, "GridY") 
	self:NetworkVar("Int", 2, "Level") 
	self:NetworkVar("Bool", 0, "PickingUp") 
	self:NetworkVar("Bool", 1, "DroppingOff") 
	
end

function ENT:SetupTables()
	--Lists of item classes we are accepting and requesting:
	self.Receives = {}
	self.Requesting = {}
	self.NoFilter = false --true means we accept all.

	--Lists of items:
	self.Holding = {}
	self.Using = {}

	--Lists of adjacent ents:
	self.Inputs = {}
	self.Outputs = {}
end

function ENT:Save(tbl)
	if self.Rotates then
		tbl.yaw = self.Yaw
	end
	tbl.level = self:GetLevel()
	
	tbl.Holding, tbl.Using, tbl.Receives, tbl.Requesting = {}, {}, {}, {}
	for k,v in pairs(self.Holding) do
		tbl.Holding[k] = {class=v.ClassName, quan=v.Quantity}
	end
	for k,v in pairs(self.Using) do
		tbl.Using[k] = {class=v.ClassName, quan=v.Quantity}
	end
	for k,v in pairs(self.Receives) do
		tbl.Receives[k] = true
	end
	for k,v in pairs(self.Requesting) do
		tbl.Requesting[k] = true
	end
	
	if self.GetImport then 
		tbl.item = self:GetImport() 
	elseif self.GetExport then
		tbl.item = self:GetExport()
	end
	
	return tbl
end
function ENT:Load(tbl)
	if self.Rotates then
		self.Yaw = tbl.yaw
	end
	self:SetLevel(tbl.level)
	
	for k,v in pairs(tbl.Holding) do
		self.Holding[k] = items.Create(v.class,v.quan)
	end
	for k,v in pairs(tbl.Using) do
		self.Using[k] = items.Create(v.class,v.quan)
	end
	for k,v in pairs(tbl.Receives) do
		self.Receives[k] = true
	end
	for k,v in pairs(tbl.Requesting) do
		self.Requesting[k] = true
	end
	
	if self.SetImport then 
		self:SetImport(tbl.item) 
	elseif self.SetExport then
		self:SetExport(tbl.item)
	end
	
end

function ENT.SetupPreview(self)
	
end
function ENT.PostDrawPreview(self)
end

function ENT:OnRemove()
	if IsValid(self:GetMaker()) then
		for k,v in pairs(self:GetAdjacentEnts())do
			if v.IsItemHolder then
				local e = v
				timer.Simple(.5,function()
					if IsValid(e) then
						e:UpdateInOut()
					end
				end)
			end
		end
	end
end

function ENT:Think()
	if CLIENT and IsValid(self:GetMaker()) then
		if not LocalPlayer():HasPermission(self:GetMaker(),PERMISSION_VIEW) then return end
	end
	
	if self:GetPickingUp() then
		
		local item, input, track = self:IsThereInput()
		if item then
			if self:CanReceive(item,input,track) and input:CanGive(item,self,track) then
				self:PickUp(item, input, track)
			end
		end
		
	elseif self:GetDroppingOff() then
		
		local item, output, track = self:IsThereOutput()
		if item then
			if output:CanReceive(item,self,track) and self:CanGive(item,output,track) then
				self:DropOff(item, output, track)
			end
		end
		
	end
end

function ENT:SetupIO(adjacent_ents)
	--overwrite this. Set your ent's inputs and outputs here.
end

function ENT:Request(class) --ask for an item at nearest convenience.
	self.Requesting[class] = true
end
function ENT:OnReceive(item,input,track)
	--overwrite this
end
function ENT:OnGive(item,output,track)
	--overwrite this
end
function ENT:CanReceive(item,input,track)
	return true --overwrite this to perform a test.
end
function ENT:CanGive(item,output,track)
	return true --overwrite this to perform a test.
end

function ENT:GetItem(class) --find an item within the ent's holding table.
	for k,v in ipairs(self.Holding) do
		if v.ClassName == class then return v, k end
	end
	return false
end

function ENT:PickUp(class, input, track)
	local item, index = input:GetItem(class)
	if item then
		table.insert(self.Holding, item)
		
		self.Requesting[class] = nil
		table.remove(input.Holding, index)
		
		self:SetPickingUp(false)
		input:OnGive(item,self,track)
		self:OnReceive(item,input,track)
	end
end

function ENT:DropOff(class, output, track)

	local item, index = self:GetItem(class)
	if item then
		table.insert(output.Holding, item)
		
		output.Requesting[class] = nil
		table.remove(self.Holding, index)
		
		self:SetDroppingOff(false)
		self:OnGive(item,output,track)
		output:OnReceive(item,self,track)
	end
end

function ENT:IsThereOutput() --is there anything we can give to our outputs?
	for k1, output in pairs(self.Outputs)do
		if !IsValid(output) then continue end
		for i, holding in pairs(self.Holding)do
			if output.NoFilter or output.Requesting[holding.ClassName] then
				return holding.ClassName, output, holding.track
			end
		end
	end
end
function ENT:IsThereInput() --is there anything we can grab from our inputs?
	for k1, input in pairs(self.Inputs)do
		if !IsValid(input) then continue end
		for i, holding in pairs(input.Holding)do
			if self.NoFilter or self.Requesting[holding.ClassName] then
				return holding.ClassName, input, holding.track
			end
		end
	end
end

function ENT:UpdateInOut()
	self.Inputs, self.Outputs = {},{}
	local adj = self:GetAdjacentEnts()
	self:SetupIO(adj)
	for k,v in pairs(adj)do
		if !v.IsItemHolder then continue end
		if table.HasValue(v.Outputs,self) and not table.HasValue(self.Inputs,v) then
			self.Inputs[#self.Inputs+1] = v
		end
		if table.HasValue(v.Inputs,self) and not table.HasValue(self.Outputs,v) then
			self.Outputs[#self.Outputs+1] = v
		end
	end
	
	-- if self.IsConveyor then
		-- print("Inputs:")
		-- PrintTable(self.Inputs)
		-- print("Outputs:")
		-- PrintTable(self.Outputs)
		-- print("")
	-- end
end

function ENT:GetAdjacentEnts()
	local fac = self:GetMaker():GetFactory()
	local x,y = self:GetGridPos()
	local w,h = self.Dimensions.w, self.Dimensions.h
	
	local e = {}
	
	for chx = x+1, x-w, -1 do
		for chy = y+1, y-h, -1 do
			if chx == x-w and chy == y-h then continue end
			if chx == x+1 and chy == y+1 then continue end
			if chx == x-w and chy == y+1 then continue end
			if chx == x+1 and chy == y-h then continue end
			local ent = fac.Grid[chx] and fac.Grid[chx][chy]
			if CLIENT and ent == mousein.Ghost then continue end
			if IsValid(ent) and ent != self then
				e[#e+1] = ent
			end
		end
	end
	
	return e
end

function ENT:SellAll()
	if IsValid(self:GetMaker()) and self:GetMaker().FactorySync then return end
	
	local total = 0
	for k,v in pairs(self.Holding or {}) do
		local can = v:OnSell(self)
		if can != false then
			total = total + v.Quantity * v.BasePrice
		end
	end
	self.Holding = {}
	if total == 0 then return end
	local maker = self:GetMaker()
	if IsValid(maker) then
		maker:AddMoney(total, self:GetPos()+Vector(0,0,20))
	
		if SERVER then
			if total > maker:GetMoney()*.08 then
				self:EmitSound("factories/chaching.mp3", 120)
			else
				self:EmitSound("factories/coins.mp3", 120)
			end
		end
	end
end



local bgcol = Color(100,100,100,200)
local bgcol_finishedProduct = Color(80,80,120,200)
local bgcol_locked = Color(120,80,80,200)

--This function allows modularity for a very common menu
--name is the name of the popup window.
--filter is a boolean function which determines which items appear in the list. Its arguments are:
	--ent, the entity we opened the menu for
	--item, the item to test.
--onclose is a function which is run when the menu is closed
function ENT:ShowSelectionMenu(name, filter, onclose)
	
	local item = items.List[self.GetImport and self:GetImport() or self.GetExport and self:GetExport() or ""]
	if IsValid(g_PopUp) then
		g_PopUp:Close()
	end
	
	local frame = vgui.Create("DFrame")
	g_PopUp = frame
	frame.Item = item
	frame:SetTitle(name)
	frame:SetSize(420,400)
	frame:Center()
	frame:MakePopup()
	frame:SetKeyboardInputEnabled(false)
	frame.lblTitle:SetFont("factRoboto24")
	frame.lblTitle:SetTextColor(color_white)
	frame.lblTitle:SetContentAlignment(7)
	function frame:Paint(w,h)
		surface.SetDrawColor(Color(0,0,0,220))
		surface.DrawRect(0,0,w,h)
		surface.SetDrawColor(color_black)
		self:DrawOutlinedRect()
	end
	function frame:Think()
		if not IsValid(vgui.GetKeyboardFocus()) and (input.IsKeyDown(KEY_W) or input.IsKeyDown(KEY_A) or input.IsKeyDown(KEY_S) or input.IsKeyDown(KEY_D) or input.IsKeyDown(KEY_E)) then
			self:Close()
		end
	end
	function frame.OnClose(s)
		if IsValid(self) then
			onclose(s)
		end
	end
	
	local bg = vgui.Create("Panel",frame)
	bg:SetSize(145,145)
	bg:SetPos(5,30)
	function bg:Paint(w,h)

		if frame.Item then
		-- if frame.Item and frame.Item.FinishedProduct then
			surface.SetDrawColor(research.LevelColors[frame.Item.Level])
			-- surface.SetDrawColor(bgcol_finishedProduct)
		-- else
			-- surface.SetDrawColor(bgcol)
		end
		surface.DrawRect(0,0,w,h)
	end
	local selected = vgui.Create("ItemPreview",bg)
	selected:Dock(FILL)
	if item then
		selected:SetModel(item.Model)
		if item.EntClass then
			selected:SetEntity(item.EntClass)
		end
		selected:SetLevel(item.Level)
		selected:SetMaterial(item.Material)
	end
	function selected:PaintOver(w,h)
		surface.SetDrawColor(color_black)
		surface.DrawOutlinedRect(0,0,w,h)
	end
	
	local price = vgui.Create("DLabel",selected)
	price:SetFont("factRoboto20")
	price:SetTextColor(Color(80,255,80))
	price:SetExpensiveShadow(1,color_black)
	price:SetText("$"..string.Comma(item and item.BasePrice or 0))
	price:Dock(FILL)
	price:DockMargin(4,4,6,4)
	price:SetContentAlignment(3)
	
	local desc = vgui.Create("DLabel",frame)
	desc:SetPos(160,60)
	desc:SetSize(255,18*3)
	desc:SetText(item and item.Desc or "Click a product below to select it.")
	desc:SetWrap(true)
	desc:SetContentAlignment(7)
	desc:SetFont("factRoboto18")
	desc:SetTextColor(color_white)
	desc:SetExpensiveShadow(1,color_black)
	function desc:Paint(w,h)
		DisableClipping(true)
			draw.RoundedBox(4,-5,-30,w+5,145,Color(50,50,50,255))
		DisableClipping(false)
	end
	
	local title = vgui.Create("DLabel",frame)
	title:SetPos(160,30)
	title:SetSize(255,25)
	title:SetText(item and item.Name or "Select a Product")
	title:SetFont("factRoboto26")
	title:SetTextColor(color_white)
	title:SetExpensiveShadow(1,color_black)
	
	local list
	
	local search = vgui.Create("DTextEntry",frame)
	search:Dock(TOP)
	search:DockMargin(5,155,5,0)
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
		list:Update(new)
	end
	
	local scroll = vgui.Create("DScrollPanel",frame)
	search:MoveToFront()
	scroll:Dock(FILL)
	scroll:DockPadding(5,5,5,5)
	function scroll:Paint(w,h)
		DisableClipping(true)
			draw.RoundedBox(4,0,-25,w,h+25,Color(50,50,50,255))
		DisableClipping(false)
	end
	
	local recipe = vgui.Create("RecipeTree",frame)
	recipe:SetPos(160,65+18*3)
	recipe:SetSize(250,50)
	-- recipe:SetShowMadeIn(false)
	if item then
		recipe:SetRecipe(item.Recipe)
	end
	function recipe.OnItemClicked(s,itemclass)
		local item = items.List[itemclass]
		if filter(self,item) then
			selected:SetModel(item.Model)
			if item.EntClass then
				selected:SetEntity(item.EntClass)
			end
			selected:SetLevel(item.Level)
			selected:SetMaterial(item.Material)
			title:SetText(item.Name)
			price:SetText("$"..string.Comma(item.BasePrice))
			desc:SetText(item.Desc)
			s:SetRecipe(item.Recipe)
			frame.Item = item
		end
	end
	
	list = vgui.Create("DIconLayout",scroll)
	list:SetSize( 50*7 + 5*7, 200 )
	list:SetPos( 5, 5 )
	list:SetSpaceY( 5 ) //Sets the space in between the panels on the X Axis by 5
	list:SetSpaceX( 5 ) //Sets the space in between the panels on the Y Axis by 5
	function list.Update(s,txt)
		s:Clear()
		
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
			if filter(self,v) then
				if txt and !v.Name:lower():find(txt:lower(),1,true) then continue end
				local ListItem = s:Add( "InvItem" ) //Add DPanel to the DIconLayout
				ListItem:SetForSale(true)
				ListItem:SetItem(v)
				function ListItem.OnMousePressed(s,mc)
					selected:SetModel(v.Model)
					if v.EntClass then
						selected:SetEntity(v.EntClass)
					end
					selected:SetLevel(v.Level)
					selected:SetMaterial(v.Material)
					title:SetText(v.Name)
					price:SetText("$"..string.Comma(v.BasePrice))
					desc:SetText(v.Desc)
					recipe:SetRecipe(v.Recipe)
					frame.Item = v
				end
			end
		end
	end
	list:Update()
end