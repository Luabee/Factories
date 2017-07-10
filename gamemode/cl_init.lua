
include( "shared.lua" )

loadGMFiles("cl_")


--[[---------------------------------------------------------
	Name: gamemode:HUDPaint()
	Desc: Use this section to paint your HUD
-----------------------------------------------------------]]
function GM:HUDPaint()
	
	-- hook.Run( "HUDDrawTargetID" )
	-- hook.Run( "HUDDrawPickupHistory" )
	-- hook.Run( "DrawDeathNotice", 0.85, 0.04 )

end

local no = {
	CHudHealth = true,
	CHudBattery = true,
}
hook.Add("HUDShouldDraw","fact_hudHide",function(h)
	if no[h] then
		return false
	end
end)

for i=12,48,2 do
	surface.CreateFont("factRoboto"..i,{
		font = "Roboto",
		size = i,
		weight = 500,
		extended=true,
	})
end

