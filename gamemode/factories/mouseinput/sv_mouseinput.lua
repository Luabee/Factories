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
	if item then
		fact.PlaceObject(ply,item,gridX,gridY,rot)
		ply:RemoveInvItem(item)
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
