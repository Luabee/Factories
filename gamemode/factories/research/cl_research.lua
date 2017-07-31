 
research.incomes = research.incomes or {}

hook.Add("PostDrawTranslucentRenderables","fact_drawresearch",function(sky)
	local rt = RealTime()
	for k,v in pairs(research.incomes)do
		local source, amt, startTime = unpack(v)
		local dt = rt - startTime
		if dt > 3 then table.remove(research.incomes,k) continue end
		
		local pos = source + Vector(0, 0, dt*20)
		cam.Start3D2D(pos, Angle(0,-90,90), .3)
			draw.SimpleText("+"..string.Comma(amt)..research.sr, "factRoboto48", 1, 1, Color(0,0,0,Lerp(dt/3,255,0)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("+"..string.Comma(amt)..research.sr, "factRoboto48", 0, 0, amt > 0 and Color(0,150,255,Lerp(dt/3,255,0)) or Color(255,80,80,Lerp(dt/3,255,0)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
		
	end
	
end)

function research.Open()
	if IsValid(g_PopUp) then g_PopUp:Close() if g_PopUp.research then return end end
	if IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible() then g_SpawnMenu:Close() end
	
	local frame = vgui.Create("DFrame")
	g_PopUp = frame
	frame.research = true
	frame:SetSize(ScrW()*.65, ScrH()*.75)
	frame:Center()
	frame:SetTitle("Research")
	frame:MakePopup()
	frame:SetKeyboardInputEnabled(false)
	frame:SetSizable(true)
	frame.lblTitle:SetFont("factRoboto24")
	frame.lblTitle:SetTextColor(color_white)
	frame.lblTitle:SetContentAlignment(7)
	function frame:Paint(w,h)
		surface.SetDrawColor(Color(0,0,0,220))
		surface.DrawRect(0,0,w,h)
		surface.SetDrawColor(color_black)
		self:DrawOutlinedRect()
	end
	
	local scroll = vgui.Create("DScrollPanel",frame)
	scroll:Dock(FILL)
	scroll:GetCanvas():DockPadding(0,0,0,0)
	
	for name, resCat in SortedPairsByMemberValue(research.List, "index") do
		
		local left = vgui.Create("Panel")
		scroll:AddItem(left)
		left:Dock(TOP)
		left:SetTall(180)
		
		local bg = vgui.Create("Panel", left)
		bg:Dock(LEFT)
		bg:DockMargin(1,1,5,6)
		bg:DockPadding(0,30,0,0)
		bg:SetWide(math.min(#resCat.benefits * 204, frame:GetWide() - (scroll:GetVBar():IsVisible() and 30 or 5)))
		function bg:Think()
			self:SetWide(math.min(#resCat.benefits * 204, frame:GetWide() - (scroll:GetVBar():IsVisible() and 30 or 5)))
		end
		local c1, c2 = Color(60,60,80,255), Color(60,60,120,255)
		function bg:Paint(w,h)
			local tw,th = self.title:GetSize()
			draw.RoundedBoxEx(6, 5, 0, tw+15, th+6, LocalPlayer():GetResearchCategory() == name and c2 or c1, true, true, false, false)
			surface.SetDrawColor(color_black)
			surface.DrawLine(5,th+5,tw+20,th+5)
			-- draw.RoundedBox(4, 0, th+5, w, h-th-5, Color(100,100,115,255))
		end
		
		local title = vgui.Create("DLabel",bg)
		title:SetPos(13,3)
		-- if LocalPlayer():GetResearchCategory() == name then
			-- title:SetText(name:sub(1,1):upper()..name:sub(2).." - Selected")
		-- else
			title:SetText(name:sub(1,1):upper()..name:sub(2))
		-- end
		title:SetFont("factRoboto22")
		bg.title = title
		title:SetTextColor(color_white)
		title:SetExpensiveShadow(1,color_black)
		title:SizeToContents()
		title:SetSize(title:GetWide()+2,title:GetTall()+2)
		
		local select = vgui.Create("DButton",bg)
		select:SetPos(20+title:GetWide(), 5)
		select:SetTall(26)
		select:SetText(LocalPlayer():GetResearchCategory() == name and "Selected" or "Select")
		select:SetWide(80)
		select:SetFont("factRoboto20")
		select:SetTextColor(color_white)
		select:SetExpensiveShadow(1,color_black)
		function select:Paint(w,h)
			if LocalPlayer():GetResearchCategory() == name then
				self:SetText("Selected")
			else
				self:SetText("Select")
			end
			if self:IsHovered() then
				draw.RoundedBoxEx(6,0,0,w,h,Color(150,150,165,255), false, true, false, false)
			else
				draw.RoundedBoxEx(6,0,0,w,h,Color(100,100,115,255), false, true, false, false)
			end
			surface.SetDrawColor(color_black)
			surface.DrawLine(0,h-2,w,h-2)
			surface.DrawLine(0,-1,0,h)
		end
		function select:DoClick()
			net.Start("fact_researchcat")
				net.WriteString(name)
			net.SendToServer()
		end
		
		
		local sidescr = vgui.Create("DHorizontalScroller",bg)
		sidescr:Dock(FILL)
		sidescr:SetOverlap(1)
		function sidescr:OnMouseWheeled()
		end
		
		for level, benefits in ipairs(resCat.benefits)do
			
			local box = vgui.Create("DPanel")
			box:SetWide(200)
			box.first = level == 1
			box.last = level == #resCat.benefits
			sidescr:AddPanel(box)
			function box:Paint(w,h)
				draw.RoundedBoxEx(8,0,0,w,h,Color(100,100,115,255), self.first, self.last, self.first, self.last)
				
				if LocalPlayer():GetResearchLevel(name) < level then
					surface.SetMaterial(Material("factories/lock.png","unlitgeneric"))
					surface.SetDrawColor(Color(0,0,0,200))
					surface.DrawTexturedRect(w/2-32,h/2-32+10,64,64)
				end
				
				if !self.last then
					surface.SetDrawColor(color_black)
					surface.DrawLine(w-2,0,w-2,h)
				end
			end
			function box:PaintOver(w,h)
				if LocalPlayer():GetResearchLevel(name) < level then
					draw.RoundedBoxEx(8,0,25,w,h-25,Color(0,0,0,130), false, false, self.first, self.last)
				end
			end
			
			local prog = vgui.Create("DProgress",box)
			prog:Dock(TOP)
			prog:SetTall(25)
			function prog:GetVal(levelAt)
				return (resCat.levels[level]-(resCat.levels[level-1] or 0))
			end
			function prog:Paint(w,h)
				local levelAt = LocalPlayer():GetResearchLevel(name)
				if levelAt >= level then
					self:SetFraction(1)
				elseif levelAt+1 < level then
					self:SetFraction(0)
				else
					local val = self:GetVal(levelAt)
					self:SetFraction( (val - LocalPlayer():GetNeededResearch(name)) / val)
				end
				-- self:SetFraction(math.sin(RealTime())/2+.5)
				
				stencil.Clear()
				stencil.Mask(255)
				stencil.Reference(1)
				stencil.Enable(true)
					stencil.Fail(STENCIL_REPLACE)
					stencil.Pass(STENCIL_KEEP)
					stencil.Compare(STENCIL_NEVER)
					draw.RoundedBoxExStencil(8,0,0,w,h,color_black, box.first, box.last, false,false)
					
					stencil.Fail(STENCIL_KEEP)
					stencil.Pass(STENCIL_REPLACE)
					stencil.Compare(STENCIL_EQUAL)
					
					surface.SetDrawColor(Color(0,0,0,200))
					surface.DrawRect(0,0,w,h)
					
					surface.SetMaterial(research.LevelMats[level])
					surface.SetDrawColor(color_white)
					surface.DrawTexturedRectUV((1-self:GetFraction())*-(w+5),0,w,h,0,0,w/256,h/256)
					
					surface.SetDrawColor(color_black)
					surface.DrawLine(-1,h-1,w,h-1)
					
					if !box.last then
						surface.DrawLine(w-2,0,w-2,h)
					end
					
					surface.SetDrawColor(Color(0,0,0,150))
					surface.DrawRect(0,0,w,h)
					
					if level == levelAt+1 then
						local val = self:GetVal(levelAt)
						local b = math.floor(val - LocalPlayer():GetNeededResearch(name))
						if val != b then 
							local txt = b.." / "..val
							draw.SimpleText(txt,"factRoboto24",w-4,3,color_black, TEXT_ALIGN_RIGHT)
							draw.SimpleText(txt,"factRoboto24",w-6,1,color_white, TEXT_ALIGN_RIGHT)
						end
					end
				
					
					draw.SimpleText("Level "..level,"factRoboto24",6,3,color_black)
					draw.SimpleText("Level "..level,"factRoboto24",4,1,color_white)
					
				stencil.Enable(false)
			end
			
			local desc = vgui.Create("DLabel", box)
			desc:Dock(TOP)
			desc:DockMargin(5,5,5,5)
			desc:SetText("")
			desc:SetTextColor(color_white)
			desc:SetExpensiveShadow(1,color_black)
			desc:SetFont("factRoboto22")
			for k,v in ipairs(benefits) do
				desc:SetText(desc:GetText().."• "..v.."\n")
			end
			desc:SizeToContents()
			
		end
		
	end
	
end
hook.Add("OnContextMenuOpen","fact_research",research.Open)
hook.Add("ContextMenuOpen","fact_research",function() return true end)
