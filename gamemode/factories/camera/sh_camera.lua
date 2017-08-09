
local plymeta = FindMetaTable("Player")


--Make the player move based on the camera not on the mouse
hook.Add("StartCommand","fact_aiming",function(ply,cmd)
	local ang = cmd:GetViewAngles()
	cmd:ClearMovement()
	local speed = ply:GetRunSpeed()
	local side, forward = 0,0
	
	if cmd:KeyDown(IN_MOVELEFT) then
		side = side - math.cos(math.rad(ang.y))*speed
		forward = forward + math.sin(math.rad(ang.y))*speed
	end
	if cmd:KeyDown(IN_MOVERIGHT) then
		side = side + math.cos(math.rad(ang.y))*speed
		forward = forward - math.sin(math.rad(ang.y))*speed
	end
	if cmd:KeyDown(IN_FORWARD) then
		side = side + math.sin(math.rad(ang.y))*speed
		forward = forward + math.cos(math.rad(ang.y))*speed
	end
	if cmd:KeyDown(IN_BACK) then
		side = side - math.sin(math.rad(ang.y))*speed
		forward = forward - math.cos(math.rad(ang.y))*speed
	end
	cmd:SetSideMove(side)
	cmd:SetForwardMove(forward)
	cmd:SetUpMove(0)
	
	cmd:RemoveKey(IN_DUCK)
	cmd:RemoveKey(IN_JUMP)
	
end)

local function limit(pos,vel,ft,min,max,d)
	if pos[d] + vel[d] * ft > max[d] then
		vel[d] = 0
		pos[d] = max[d]
	end
	if pos[d] + vel[d] * ft < min[d] then
		vel[d] = 0
		pos[d] = min[d]
	end
	return vel,pos
end
-- hook.Add("FinishMove","fact_nofalling",function(ply,mv)
	
	-- if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	
	-- local fac = ply:GetFactory()
	-- local min, max = fac.MinMax.min, fac.MinMax.max
	-- max.z = 100000
	-- local pos = mv:GetOrigin()
	-- local vel = mv:GetVelocity()
	-- local ft = FrameTime()
	
	-- vel,pos = limit(pos,vel,ft,min,max,"x")
	-- vel,pos = limit(pos,vel,ft,min,max,"y")
	-- vel,pos = limit(pos,vel,ft,min,max,"z")
	
	-- mv:SetVelocity(vel)
	-- mv:SetOrigin(pos + vel*ft)
	
	-- ply:SetVelocity(vel)
	-- ply:SetPos(mv:GetOrigin())
	
	
-- end)
