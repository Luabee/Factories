

hook.Add("PreDrawTranslucentRenderables","drawGrid",function(skybox)
	if not skybox then
		-- for xoff = -2000, 2000, 100 do
			-- for yoff = -2000, 2000, 100 do
				-- local plypos = LocalPlayer():GetPos()
				-- local pos = plypos - Vector(xoff/2, yoff/2, 0)
				-- render.DrawLine(pos, pos + Vector(xoff/2, 0, 0), Color(0,0,0), true)
				-- render.DrawLine(pos, pos + Vector(0, yoff/2, 0), Color(0,0,0), true)
			-- end
		-- end
		
	end
end)
