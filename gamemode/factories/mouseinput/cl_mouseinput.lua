
mousein.Rotation = mousein.Rotation or 0
mousein.Breaking = false
mousein.BreakTarget = NULL

hook.Add("InitPostEntity","fact_createMI",function()
	if IsValid(g_MouseInput) then
		g_MouseInput:Remove()
	end

	g_MouseInput = vgui.Create("Panel")
	g_MouseInput:SetMouseInputEnabled(true)
	-- g_MouseInput:ParentToHUD()
	g_MouseInput:SetSize(ScrW(),ScrH())
	function g_MouseInput:OnMouseWheeled(delta)
		LocalPlayer().view.mousewheel = math.Clamp((LocalPlayer().view.mousewheel or 0) - delta*8, -200, 440)
		-- print(delta)
	end
	function g_MouseInput:OnMousePressed(mb)
		hook.Run("OnScreenClicked", mb)
		
		
	end
	function g_MouseInput:OnMouseReleased(mb)
		hook.Run("OnScreenReleased", mb)
		
		
	end
	
	mousein.Ghost = ClientsideModel("models/error.mdl", RENDERMODE_TRANSALPHA)
	mousein.Ghost:SetNoDraw(true)
end)

function GM:OnScreenClicked(mb)
	local ply = LocalPlayer()
	if mb == MOUSE_LEFT then
		if IsValid(g_InHand) then
			local item = g_InHand:GetItem()
			local vec = ply:GetMouseVector()
			-- debugoverlay.Box(grid.SnapTo(ply:GetFactory(),vec), Vector(-grid.Size/2, -grid.Size/2, -5), Vector(grid.Size/2, grid.Size/2, 5), 20, Color(255,255,0,100))
			
			
			local e = scripted_ents.GetStored(item.EntClass)
			if e then
				e = e.t
				local fac = ply:GetFactory()
				local gx, gy = vec:ToGrid(fac)
				local dim,floor = e.Dimensions or {w=1, h=1}, e.IsFloor
				local can = (floor and grid.CanPlaceFloor(fac,gx, gy, dim.w, dim.h)) or (not floor and grid.CanPlace(fac, gx, gy, dim.w, dim.h))
				
				if can then
							
					net.Start("fact_placeItem")
						net.WriteString(item.ClassName)
						net.WriteFloat(vec.x)
						net.WriteFloat(vec.y)
						net.WriteUInt(mousein.Rotation/90, 2)
					net.SendToServer()
					
					ply:RemoveInvItem(item)
				
					if e.IsFloor then
						grid.AddFloor(fac, gx, gy, dim.w, dim.h, mousein.Ghost)
					else
						grid.AddItem(fac, gx, gy, dim.w, dim.h, mousein.Ghost)
					end
				end
			end
			
		else
			local target = ply:GetHoveredEnt()
			if target.DoClick then
				target:DoClick()
			end
		end
	elseif mb == MOUSE_RIGHT then
		
		local target = ply:GetHoveredEnt()
		if IsValid(target) then
			if hook.Run("PlayerCanBreak",ply,target) != false then
				mousein.Breaking = target.BreakSpeed
				mousein.BreakTarget = target
			elseif !mousein.CantBreak then
				mousein.CantBreak = true
				notification.AddLegacy("You can't remove that object.",NOTIFY_ERROR,2)
			end
		end
	end
end
function GM:OnScreenReleased(mb)
	
	if mb == MOUSE_RIGHT then
		mousein.Breaking = false
		mousein.CantBreak = false
	end
	
end

function mousein.Break(target)
	if IsValid(target) then
		net.Start("fact_breakItem")
			net.WriteEntity(target)
		net.SendToServer()
		
		LocalPlayer():AddInvItem(target:GetItemClass())
		
		timer.Simple(0,function()
			target:SetNoDraw(true)
			target:SetSolid(SOLID_NONE)
		end)
	end
end

hook.Add("HUDPaint","fact_breaking",function()
	
	if mousein.Breaking and g_MouseInput:IsHovered() and input.IsMouseDown(MOUSE_RIGHT) then
		local fac = LocalPlayer():GetFactory()
		local x,y = LocalPlayer():GetMouseVector():ToGrid(fac)
		local target = ((fac.Grid[x] and fac.Grid[x][y] and IsValid(fac.Grid[x][y])) and fac.Grid[x][y] or (fac.Floors[x] and fac.Floors[x][y]))
		local can = hook.Run("PlayerCanBreak",LocalPlayer(),target) != false
		if IsValid(target) then
			if target.IsFactoryPart and target == mousein.BreakTarget and can then
			
				mousein.Breaking = mousein.Breaking - FrameTime()
				
				if mousein.Breaking <= 0 then
					mousein.Break(mousein.BreakTarget)
					mousein.BreakTarget = target
					mousein.Breaking = target.BreakSpeed
				end
				
			elseif target.IsFactoryPart then
				if !can then
					-- if !mousein.CantBreak then
						-- mousein.CantBreak = true
						-- notification.AddLegacy("You can't remove that object.",NOTIFY_ERROR,2)
					-- end
					return
				else
					mousein.BreakTarget = target
					mousein.Breaking = target.BreakSpeed
				end
				
			end
		else
			return
		end
		
		local w, h, sw, sh = 500, 10, ScrW(), ScrH()
		surface.SetDrawColor(color_black)
		surface.DrawRect(sw/2-w/2, sh-h-65, w, h)
		surface.SetDrawColor(Color(220,0,0))
		surface.DrawRect(sw/2-w/2+1, sh-h-65+1, (w-2) * (1 - mousein.Breaking/target.BreakSpeed), h-2)
		
	end
	
end)

local cancol, cantcol = Color(100/255,255/255,100/255), Color(255/255,100/255,100/255)
hook.Add("PostDrawTranslucentRenderables","fact_GhostPlacement",function(sky)
	if sky then return end
	local ply = LocalPlayer()
	
	
	//Draw Ghost
	local rot = mousein.Rotation
	local fac = ply:GetFactory()
	local vec = grid.SnapTo(fac, ply:GetMouseVector())
	local gridX, gridY = vec:ToGrid(fac)
	
	-- debugoverlay.Box(vec, Vector(-grid.Size/2, -grid.Size/2, -5), Vector(grid.Size/2, grid.Size/2, 5), FrameTime()+.01, Color(255,255,255,100))
	
	if IsValid(g_InHand) then
		local item = g_InHand:GetItem()
		local class = item.EntClass
		local e = scripted_ents.GetStored(class)
		if class and e then
			
			e = e.t
			if mousein.Ghost.class != item.ClassName then
				mousein.Ghost:Remove()
				mousein.Ghost = ClientsideModel(item.Model, RENDERMODE_OTHER)
				mousein.Ghost.GetLevel = function() return item.Level end
				mousein.Ghost:SetNoDraw(true)
				mousein.Ghost.class = item.ClassName
				if e.SetupPreview then
					e.SetupPreview(mousein.Ghost)
				end
			end
			
			local dim,floor = e.Dimensions or {w=1, h=1}, e.IsFloor
			local can = (floor and grid.CanPlaceFloor(fac,gridX, gridY, dim.w, dim.h)) or (not floor and grid.CanPlace(fac, gridX, gridY, dim.w, dim.h))
			
			render.SetColorModulation(can and cancol.r or cantcol.r, can and cancol.g or cantcol.g, can and cancol.b or cantcol.b)
			render.SetBlend(.75)
			
			local off = e.GridOffset or Vector(0,0,0)
			local ang = e.AngOffset or Angle(0,0.00001,0)
			if e.Rotates then
				ang = ang + Angle(0,mousein.Rotation,0)
			end
			local pos = vec + off
			
			mousein.Ghost:SetAngles(ang)
			mousein.Ghost:SetPos(pos)
			
			if e.PreDrawPreview then
				e.PreDrawPreview(mousein.Ghost)
			end
			
			mousein.Ghost:DrawModel()
			
			if e.PostDrawPreview then
				e.PostDrawPreview(mousein.Ghost)
			end
			
			render.SetBlend(0)
			render.SetColorModulation(255,255,255)
			
			if e.GetSelectionMat then
				local mat, rot = e:GetSelectionMat()
				rot = (rot or 0) + mousein.Rotation
				render.SetMaterial(mat)
				render.DrawQuadEasy(vec + Vector(-48*dim.w/2 + 48/2,-48*dim.h/2 + 48/2,2), Vector(0,0,1), 48*dim.w, 48*dim.h, Color(255,255,255,200), rot)
			end
			
		end
		
	elseif fac.Grid[gridX] then
		local target = fac.Grid[gridX][gridY]
		if IsValid(target) then
			if target.GetSelectionMat then
				local vec = grid.ToVector(fac,target:GetGridPos())
				local mat, rot = target:GetSelectionMat()
				local dim = target.Dimensions or {w=1,h=1}
				rot = (rot or 0)
				render.SetMaterial(mat)
				render.DrawQuadEasy(vec + Vector(-48*dim.w/2 + 48/2,-48*dim.h/2 + 48/2,2), Vector(0,0,1), 48*dim.w, 48*dim.h, Color(255,255,255,200), rot)
			end
			
		end
		
	end
end)

hook.Add("PlayerBindPress","fact_rotateItem",function(ply,key,down)
	if key == "+reload" and down then
		mousein.Rotation = (mousein.Rotation - 90) % 360
	end
end)