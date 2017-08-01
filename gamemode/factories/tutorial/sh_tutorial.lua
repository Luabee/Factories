
hook.Add("ShowHelp","fact_opentut",function(ply)
	ply:ConCommand("fact_tutorial")
end)

if SERVER then
	for i=1, 10 do
		resource.AddFile("materials/factories/tut/tut"..i..".png")
	end
else
	local PANEL = {}
	PANEL.Stages = {}
	for i=1, 11 do
		PANEL.Stages[i] = Material("factories/tut/tut"..i..".png","unlitgeneric smooth")
	end
	
	local TUT
	function OpenTutorial()
		if IsValid(TUT) then TUT:Close() end

		TUT = vgui.Create("DFrame")
		TUT:SetSize(810,683)
		TUT:Center()
		TUT:SetTitle("Quickstart Guide")
		TUT:MakePopup()
		TUT:SetBackgroundBlur(true)
		TUT:DoModal(true)
		TUT.lblTitle:SetFont("factRoboto24")
		TUT.lblTitle:SetTextColor(color_white)
		TUT.lblTitle:SetContentAlignment(7)
		function TUT:Paint(w,h)
			surface.SetDrawColor(Color(0,0,0,220))
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(color_black)
			self:DrawOutlinedRect()
		end

		local tut = vgui.Create("fact_Tutorial",TUT)
		tut:Dock(FILL)	
		
	end
	concommand.Add("fact_tutorial",OpenTutorial)
	
	
	function PANEL:Init()
		
		self.stage = 1
		self.max = #self.Stages-1
		
		local img = vgui.Create("DImage",self)
		img:SetSize(800,600)
		img:SetMaterial(self.Stages[1])
		self.img = img
		
		local bot = vgui.Create("Panel",self)
		bot:SetTall(45)
		bot:Dock(BOTTOM)
		
		local prev = vgui.Create("DButton",bot)
		prev:Dock(LEFT)
		prev:SetWide(150)
		prev:SetText("Previous")
		prev:SetFont("factRoboto20")
		prev:SetTextColor(color_white)
		function prev.DoClick(btn)
			self.stage = math.max(self.stage-1,1)
			img:SetMaterial(self.Stages[self.stage])
			self.prog:SetFraction(self.stage/self.max)
		end
		self.prev = prev
		function prev:Paint(w,h)
			if self:IsHovered() then
				surface.SetDrawColor(Color(90,90,90))
			else
				surface.SetDrawColor(Color(70,70,70))
			end
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(color_black)
			self:DrawOutlinedRect()
		end
		
		local next = vgui.Create("DButton",bot)
		next:Dock(RIGHT)
		next:SetWide(150)
		next:SetText("Next")
		next:SetFont("factRoboto20")
		next:SetTextColor(color_white)
		function next.DoClick(btn)
			self.stage = math.min(self.stage+1,self.max)
			img:SetMaterial(self.Stages[self.stage])
			self.prog:SetFraction(self.stage/self.max)
		end
		function next:Paint(w,h)
			if self:IsHovered() then
				surface.SetDrawColor(Color(90,90,90))
			else
				surface.SetDrawColor(Color(70,70,70))
			end
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(color_black)
			self:DrawOutlinedRect()
		end
		self.next = next
		
		local prog = vgui.Create("DProgress",bot)
		prog:Dock(FILL)
		prog:DockMargin(5,5,5,5)
		prog:SetFraction(1/self.max)
		self.prog = prog
		function prog:Paint(w,h)
			surface.SetDrawColor(color_black)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(Color(0,100,220))
			surface.DrawRect(1, 1, (w-2) * self:GetFraction(), h-2)
		end
		
		
	end
	vgui.Register("fact_Tutorial",PANEL,"Panel")
	
	hook.Add("InitPostEntity","fact_tutorial",function() //Show firsttimers the tutorial.
		timer.Simple(4,function()
			if cookie.GetNumber("fact_tutorial",0) != 1 then
				cookie.Set("fact_tutorial",1)
				RunConsoleCommand("fact_tutorial")
			end
		end)
	end)

end