util.AddNetworkString("fact_placeItem")
util.AddNetworkString("fact_breakItem")

net.Receive("fact_placeItem",function(len,ply)
	
	local class = net.ReadString()
	local x = net.ReadFloat()
	local y = net.ReadFloat()
	local rot = net.ReadUInt(2) * 90
	local fac = ply:GetFactory()
	local vec = grid.SnapTo(fac, Vector(x,y,fac.Root.z))
	local gridX, gridY = vec:ToGrid(fac)
	
	local item = ply:GetInvItem(class)
	if item and item.EntClass then
		
		local e = scripted_ents.GetStored(item.EntClass)
		if e then e = e.t else return end
		local dim,floor = e.Dimensions or {w=1, h=1}, e.IsFloor
		local can = (floor and grid.CanPlaceFloor(fac,gridX, gridY, dim.w, dim.h)) or (not floor and grid.CanPlace(fac, gridX, gridY, dim.w, dim.h))
		
		if can then
			
			
			ply:RemoveInvItem(item)
			local ent = ents.Create(item.EntClass)
			ent:SetPos(vec + ent.GridOffset)
			local ang = ent.AngOffset-- - Angle(0,90,0)
			if ent.Rotates then
				ang = ang + Angle(0,rot,0)
			end
			ent:SetAngles(ang)
			table.insert(fac.Ents, ent)
			ent:SetMaker(ply)
			ent:SetGridPos(gridX, gridY)
			ent.Item = item
			ent:SetItemClass(class)
			ent:Spawn()
			sound.Play( ent:GetPlaceSound(), ent:GetPos(), 75, 100, 1 )
			
			-- debugoverlay.Box(vec, Vector(-grid.Size/2, -grid.Size/2, -5), Vector(grid.Size/2, grid.Size/2, 5), 20, Color(0,0,255,100))
			
			
			if floor then
				grid.AddFloor(fac,gridX, gridY, dim.w, dim.h, ent)
			else
				grid.AddItem(fac,gridX, gridY, dim.w, dim.h, ent)
			end
			
		end
		
		
	end
	
end)

net.Receive("fact_breakItem",function(len,ply)
	local ent = net.ReadEntity()
	
	if IsValid(ent) then
		-- if hook.Run("PlayerCanBreak", ply, target) != false then
			ply.LastBreak = ply.LastBreak or 0
			if CurTime() >= ply.LastBreak + ent.BreakSpeed - .1 then --never trust the client.
				ply.LastBreak = CurTime()
				
				
				ply:GiveInvItem(ent:GetItemClass())
				sound.Play( ent:GetBreakSound(), ent:GetPos(), 75, 100, 1 )
				
				local floor = ent.IsFloor
				ent:Remove()
							
				if floor then
					timer.Simple(.05,function()
						fact.RebuildWalls(ply:GetFactory())
					end)
				end
				
			end
		-- end
		
	end
	
end)
