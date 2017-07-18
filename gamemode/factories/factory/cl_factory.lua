

timer.Create("fact_sync",600,0,function()
	LocalPlayer().FactorySync = true
	net.Start("fact_syncfactory")
	net.SendToServer()
end)
net.Receive("fact_syncfactory",function()
	local root = LocalPlayer():GetFactory().Root
	local fac = fact.Create(LocalPlayer())
	fac.Root = root
	LocalPlayer().FactorySync = false
end)

local startTime = RealTime()
hook.Add("HUDPaint","fact_sync",function()
	if GAMEMODE.Loading or LocalPlayer().FactorySync then
		
		draw.RoundedBox(0,0,0,ScrW(),ScrH(),Color(0,0,0,100))
		draw.RoundedBox(0,ScrW()/2-105,ScrH()/4-11,206,24,color_black)
		draw.RoundedBox(0,ScrW()/2-105+2,ScrH()/4-9,math.Clamp((RealTime()-startTime)/.8 * 210,0,210-8),20,Color(50,80,200))
		draw.SimpleText("Synchronizing Factory...","factRoboto20",ScrW()/2+1,ScrH()/4+1,color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.SimpleText("Synchronizing Factory...","factRoboto20",ScrW()/2,ScrH()/4,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		
	else
		startTime = RealTime()
	end
end)

hook.Add("RenderScreenspaceEffects","fact_sync",function()
	if fact.Loading or LocalPlayer().FactorySync then
		
		DrawMotionBlur(0, 1, 5)
		
	end
end)