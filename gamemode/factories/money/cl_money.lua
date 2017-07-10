
money.incomes = money.incomes or {}

local bg = Color(0,0,0,200)
local col = Color(100,255,100)
hook.Add("HUDPaint","fact_drawmoney",function()
	local w,h = 200, 55
	draw.RoundedBoxEx(8,0,ScrH()-h,w,h,bg,false, true, false, false)
	
	local str = "$"..string.Comma(LocalPlayer():GetMoney())
	draw.SimpleText(str, "factRoboto44", w/2+1, ScrH()-h/2+1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(str, "factRoboto44", w/2, ScrH()-h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
end)

hook.Add("PostDrawTranslucentRenderables","fact_drawmoney",function(sky)
	local rt = RealTime()
	for k,v in pairs(money.incomes)do
		local source, amt, startTime = unpack(v)
		local dt = rt - startTime
		if dt > 3 then table.remove(money.incomes,k) continue end
		
		local pos = source + Vector(0, 0, dt*20)
		cam.Start3D2D(pos, Angle(0,-90,90), .3)
			draw.SimpleText("$"..string.Comma(amt), "factRoboto48", 1, 1, Color(0,0,0,Lerp(dt/3,255,0)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("$"..string.Comma(amt), "factRoboto48", 0, 0, amt > 0 and Color(80,255,80,Lerp(dt/3,255,0)) or Color(255,80,80,Lerp(dt/3,255,0)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
		
	end
	
end)
