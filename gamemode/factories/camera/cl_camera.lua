
local plymeta = FindMetaTable("Player")

local scales = { --because aspect ratio defines util.AimVector for some reason
	[1.3] = 0,
	[1.7] = 12,
	[1.8] = 18,
}
function util.GetMouseVector()
	local ply = LocalPlayer()
	local scrscale = math.Round(ScrW()/ScrH(),1)
	return util.AimVector( ply.view.angles, ply.view.fov + (scales[scrscale] or 18) , gui.MouseX(), gui.MouseY(), ScrW(), ScrH() )
end

function plymeta:GetMouseVector()
	local ply = LocalPlayer()
	if not ply.view then return self:GetPos() end
	
	local toscr = util.GetMouseVector()
	local HitPos = util.IntersectRayWithPlane(ply.view.origin, toscr, ply:GetPos(), Vector(0,0,1))
	
	return HitPos or self:GetPos()
end

function plymeta:GetMouseTrace()
	local ply = LocalPlayer()
	if not ply.view then return {Hit = false, HitPos = self:GetPos(), Entity = NULL} end
	
	local toscr = util.GetMouseVector()
	local endpos = util.IntersectRayWithPlane(ply.view.origin, toscr, ply:GetPos()-Vector(0,0,4), Vector(0,0,1))
	local trace = util.TraceLine({start = ply.view.origin, endpos = endpos, filter=self})
	
	return trace
end

function plymeta:GetHoveredEnt()
	local fac = LocalPlayer():GetFactory()
	local x,y = LocalPlayer():GetMouseVector():ToGrid(fac)
	local target = ((fac.Grid[x] and fac.Grid[x][y] and IsValid(fac.Grid[x][y])) and fac.Grid[x][y] or (fac.Floors[x] and fac.Floors[x][y])) or NULL
	
	return target
end

--Set the camera above the player.
hook.Add("CalcView","fact_thirdperson",function( ply, pos, angles, fov, znear, zfar )
	
	gui.EnableScreenClicker(true)
	local view = ply.view or {}

	-- angles.p = 45
	-- view.angles = angles
	view.angles = Angle(45,0,0)
	view.origin = pos - view.angles:Forward()* (300 + (view.mousewheel or 0))
	view.fov = fov
	view.drawviewer = true
	
	-- view.ortho = {
		-- left = -400,
		-- top = -400,
		-- right = 400,
		-- bottom = 400,
	-- }
	
	ply.view = view
	
	return view
	
end)

--Rotate the player with the mouse pos
hook.Add("CreateMove","fact_aiming",function(cmd)
	local ply = LocalPlayer()
	if not ply.view then return end
	
	local HitPos = ply:GetMouseVector()
	
	-- debugoverlay.Box(HitPos, Vector(-4,-4,-4), Vector(4,4,4), FrameTime()+.02)
	
	local ang = (HitPos - (ply:GetPos() + Vector(0,0,64))):Angle()
	ang.p = 0
	
	cmd:SetMouseX(0)
	cmd:SetMouseY(0)
	cmd:SetViewAngles(ang)
	
end)

