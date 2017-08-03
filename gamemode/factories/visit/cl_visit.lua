
visit = visit or {}
local plymeta = FindMetaTable("Player")

hook.Add("InitPostEntity","fact_visit",function()
	LocalPlayer().Visitors = {}
end)

net.Receive("fact_visit_disconnect",function()
	LocalPlayer().Visitors[net.ReadEntity()] = nil
	if IsValid(visit.Frame) then visit.Frame:Update() end
end)
net.Receive("fact_visit",function()
	local ply = net.ReadEntity()
	if IsValid(ply) then
		if net.ReadBool() then
			ply.Visitors = net.ReadTable()
		else
			ply.Visitors = {}
		end
	end
	if ply == LocalPlayer() and IsValid(visit.Frame) then
		visit.Frame:Update()
	end
end)
net.Receive("fact_setfactory",function()
	local ply = net.ReadEntity()
	ply.Factory = net.ReadTable()
	ply.Factory.Owner.Factory = ply.Factory
end)

function visit.Open()
	-- E().Visitors = {[E(2)] = 1,[E(3)] = 2,[E(4)] = 2,[E(5)] = 2,[E(6)] = 2,[E(7)] = 2} //DEBUG

	if IsValid(g_PopUp) then g_PopUp:Close() if g_PopUp.visit then return end end
	if IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible() then g_SpawnMenu:Close() end
	local ply = LocalPlayer()
	
	local frame = vgui.Create("DFrame")
	g_PopUp = frame
	visit.Frame = frame
	frame.visit = true
	frame:SetSize(320,450)
	frame:CenterVertical()
	frame:AlignLeft(50)
	-- frame:AlignLeft(-ScrW()*.25)
	-- frame:MoveTo(50,select(2,frame:GetPos()), .3, 0, .8)
	frame:SetTitle("Visitors")
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
	-- function frame:Close()
		-- self:MoveTo(-self:GetWide(),select(2,self:GetPos()), .5, 0, 2, function()
			-- self:Remove()
		-- end)
	-- end
	
	local scroll = vgui.Create("DScrollPanel",frame)
	-- scroll:SetPos(4,24)
	-- scroll:SetSize(ScrW()*.25-9, ScrH()*.75 - 24 - 5)
	scroll:Dock(FILL)
	scroll:GetCanvas():DockPadding(0,0,0,0)
	
	function frame:Update()
		scroll:GetCanvas():Clear()
		
		for visitor,perm in pairs(ply.Visitors) do
			if not IsValid(visitor) then 
				ply.Visitors[visitor] = nil
				continue
			end
			
			local bg = scroll:Add("Panel")
			bg:SetTall(74)
			bg:DockMargin(0,0,0,5)
			bg:Dock(TOP)
			function bg:Paint(w,h)
				-- if self:IsHovered() then
					-- draw.RoundedBox(0,0,0,w,h,Color(150,150,150))
				-- else
					draw.RoundedBox(0,0,0,w,h,Color(120,120,120))
				-- end
				surface.SetDrawColor(color_black)
				self:DrawOutlinedRect()
			end
			
			local icon = bg:Add("AvatarImage")
			icon:SetPlayer(visitor, 64)
			icon:SetSize(64,64)
			icon:SetPos(5,5)
			
			local name = bg:Add("DLabel")
			name:SetText(visitor:Nick())
			name:SetFont("factRoboto22")
			name:SizeToContentsY()
			name:SetWide(135)
			name:SetTextColor(color_white)
			name:SetExpensiveShadow(1,color_black)
			name:SetPos(79,27)
				
			local perm = vgui.Create("DComboBox", bg)
			perm:SetSize(80, 25)
			perm:CenterVertical()
			perm:AlignLeft(219)
			perm:SetSortItems(false)
			perm:AddChoice(visit.PermissionString[PERMISSION_VIEW],PERMISSION_VIEW,visitor:GetPermission(ply)==(PERMISSION_VIEW or nil))
			perm:AddChoice(visit.PermissionString[PERMISSION_BUILD],PERMISSION_BUILD,visitor:GetPermission(ply)==PERMISSION_BUILD)
			perm:AddChoice(visit.PermissionString[PERMISSION_ALL],PERMISSION_ALL,visitor:GetPermission(ply)==PERMISSION_ALL)
			perm:AddChoice("Revoke Access", 0)
			
			function perm:OnSelect(i,txt,data)
				if data == 0 then
					net.Start("fact_visit_kickout")
						net.WriteEntity(ply)
						net.WriteEntity(visitor)
					net.SendToServer()
				else
					ply.Visitors[visitor] = data
					net.Start("fact_visit")
						net.WriteTable(ply.Visitors)
					net.SendToServer()
				end
			end
			
		end

		local add = scroll:Add("Panel")
		add:SetTall(74)
		add:DockMargin(0,0,0,5)
		add:Dock(TOP)
		function add:Paint(w,h)
			-- if self:IsHovered() then
				-- draw.RoundedBox(0,0,0,w,h,Color(150,150,150))
			-- else
				draw.RoundedBox(0,0,0,w,h,Color(120,120,120))
			-- end
			surface.SetDrawColor(color_black)
			self:DrawOutlinedRect()
		end

		local plysel = vgui.Create("DComboBox",add)
		plysel:SetSize(120, 25)
		plysel:AlignLeft(84)
		plysel:CenterVertical()
		plysel:SetText("Select a player...")
		for k,v in pairs(player.GetAll())do
			if IsValid(v) and v!=ply and !ply.Visitors[v] then
				plysel:AddChoice(v:Nick(),v)
			end
		end

		local perm = vgui.Create("DComboBox", add)
		perm:SetSize(80, 25)
		perm:CenterVertical()
		perm:AlignLeft(214)
		perm:SetSortItems(false)
		perm:AddChoice(visit.PermissionString[PERMISSION_VIEW],PERMISSION_VIEW,true)
		perm:AddChoice(visit.PermissionString[PERMISSION_BUILD],PERMISSION_BUILD)
		perm:AddChoice(visit.PermissionString[PERMISSION_ALL],PERMISSION_ALL)

		local plus = add:Add("DButton")
		plus:SetText("+")
		plus:SetSize(64,64)
		plus:SetPos(5,5)
		plus:SetTextColor(color_black)
		-- plus:SetExpensiveShadow(2,color_black)
		plus:SetFont("factRoboto48")
		function plus:DoClick()
			local other = select(2,plysel:GetSelected())
			if not IsValid(other) then return end
			local permission = select(2,perm:GetSelected())
			if not isnumber(permission) then return end
			
			print("You invited "..other:Nick().." to the factory.")
			net.Start("fact_visit_invite")
				net.WriteEntity(other)
				net.WriteUInt(permission,3)
			net.SendToServer()
		end
	
	end
	frame:Update()
	
	local comeback = vgui.Create("Panel", frame)
	local visit = comeback:Add("DLabel")
	visit:SetText("You are visiting another person.")
	visit:SetFont("factRoboto26")
	visit:SetTextColor(color_white)
	visit:SetExpensiveShadow(2,color_black)
	visit:SetContentAlignment(5)
	visit:Dock(TOP)
	visit:DockMargin(0,80,0,0)
	
	local rtrn = comeback:Add("DButton")
	rtrn:SetFont("factRoboto24")
	rtrn:SetText("Return to Factory")
	rtrn:SetTextColor(color_black)
	rtrn:SetSize(180,35)
	rtrn:Dock(TOP)
	rtrn:DockMargin(50,20,50,0)
	function rtrn:DoClick()
		if LocalPlayer().FactorySync then return end
		net.Start("fact_visit_kickout")
			net.WriteEntity(LocalPlayer():GetVisiting())
			net.WriteEntity(LocalPlayer())
		net.SendToServer()
		frame:Close()
	end
	
	
	function frame:Think()
		if IsValid(LocalPlayer():GetVisiting()) then
			scroll:Dock(NODOCK)
			scroll:SetVisible(false)
			comeback:SetVisible(true)
			comeback:Dock(FILL)
		else
			scroll:Dock(FILL)
			scroll:SetVisible(true)
			comeback:SetVisible(false)
			comeback:Dock(NODOCK)
		end
	end
	frame:Think()
	
end
concommand.Add("fact_visit",visit.Open)

function visit.OpenInvite(inv,perm)
	if IsValid(visit.Invite) then visit.Invite.decline:DoClick() end
	
	local frame = vgui.Create("DFrame")
	visit.Invite = frame
	frame:SetSize(180,150)
	frame:CenterVertical()
	frame:AlignRight(25)
	frame:SetTitle("")
	frame:MakePopup()
	frame:SetKeyboardInputEnabled(false)
	frame:ShowCloseButton(false)
	function frame:Paint(w,h)
		surface.SetDrawColor(Color(0,0,0,220))
		surface.DrawRect(0,0,w,h)
		surface.SetDrawColor(color_black)
		self:DrawOutlinedRect()
	end
	
	local name = vgui.Create("DLabel",frame)
	name:SetText(inv:Nick())
	name:SetFont("factRoboto28")
	name:SizeToContents()
	name:SetTextColor(color_white)
	name:SetExpensiveShadow(1,color_black)
	name:CenterHorizontal()
	name:AlignTop(10)
	
	local invited = vgui.Create("DLabel",frame)
	invited:SetText("invited you to")
	invited:SetFont("factRoboto20")
	invited:SizeToContents()
	invited:SetTextColor(color_white)
	invited:SetExpensiveShadow(1,color_black)
	invited:CenterHorizontal()
	invited:AlignTop(39)
	
	local totheir = vgui.Create("DLabel",frame)
	totheir:SetText("their factory.")
	totheir:SetFont("factRoboto20")
	totheir:SizeToContents()
	totheir:SetTextColor(color_white)
	totheir:SetExpensiveShadow(1,color_black)
	totheir:CenterHorizontal()
	totheir:AlignTop(57)
	
	local access = frame:Add("DLabel")
	access:SetText("( "..visit.PermissionString[perm].." )")
	access:SetFont("factRoboto14")
	access:SizeToContents()
	access:SetTextColor(color_white)
	access:SetExpensiveShadow(1,color_black)
	access:CenterHorizontal()
	access:AlignTop(83)
	
	local accept = frame:Add("DButton")
	accept:SetText("ACCEPT")
	accept:SetWide(83)
	accept:SetPos(5,103)
	accept:SetTextColor(color_white)
	accept:SetFont("factRoboto16")
	function accept:Paint(w,h)
		if self:IsHovered() then
			surface.SetDrawColor(Color(90,90,90))
		else
			surface.SetDrawColor(Color(70,70,70))
		end
		surface.DrawRect(0,0,w,h)
		surface.SetDrawColor(color_black)
		self:DrawOutlinedRect()
	end
	function accept:DoClick()
		if LocalPlayer().FactorySync then
			notification.AddLegacy("Wait until your factory is finished syncronizing.",NOTIFY_ERROR,2)
			return
		end
		frame:Close()
		net.Start("fact_visit_invite_result")
			net.WriteEntity(inv)
			net.WriteBool(true)
		net.SendToServer()
	end
	local decline = frame:Add("DButton")
	frame.decline = decline
	decline:SetText("DECLINE")
	decline:SetWide(83)
	decline:SetPos(92,103)
	decline:SetTextColor(color_white)
	decline:SetFont("factRoboto16")
	function decline:DoClick()
		frame:Close()
		net.Start("fact_visit_invite_result")
			net.WriteEntity(inv)
			net.WriteBool(false)
		net.SendToServer()
	end
	decline.Paint = accept.Paint
	
	local prog = frame:Add("DProgress")
	prog:SetSize(170,15)
	prog:SetPos(5,129)
	local start = RealTime()
	function prog:Think()
		local frac = 1-((RealTime() - start) / ConVars.Client.inviteTime:GetFloat())
		self:SetFraction(frac)
		if frac < 0 then
			decline:DoClick()
		end
	end
	function prog:Paint(w,h)
		surface.SetDrawColor(color_black)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(Color(0,100,220))
		surface.DrawRect(1, 1, (w-2) * self:GetFraction(), h-2)
		
	end
	
end
net.Receive("fact_visit_invite",function()
	local inv = net.ReadEntity()
	local perm = net.ReadUInt(3)
	if IsValid(inv) then
		visit.OpenInvite(inv,perm)
	end
end)

hook.Add("Initialize","fact_visitlabel",function()
	visit.Label = vgui.Create("DLabel")
	visit.Label:ParentToHUD()
	visit.Label:SetFont("factRoboto30")
	visit.Label:SetText("")
	function visit.Label:Think()
		local vis = IsValid(LocalPlayer()) and LocalPlayer():GetVisiting()
		if IsValid(vis) then
			self:SetText("Visiting "..vis:Nick())
			self:SizeToContents()
			self:CenterHorizontal()
		else
			self:SetText("")
		end
	end
	visit.Label:CenterHorizontal()
	visit.Label:AlignTop(20)
	visit.Label:SetTextColor(color_white)
	visit.Label:SetExpensiveShadow(2,color_black)
end)
