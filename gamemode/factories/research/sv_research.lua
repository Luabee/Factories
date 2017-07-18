 
resource.AddFile("materials/factories/tech/tech_red.vmt")
resource.AddFile("materials/factories/tech/tech_green.vmt")
resource.AddFile("materials/factories/tech/tech_blue.vmt")
resource.AddFile("materials/factories/tech/tech_pink.vmt")
resource.AddFile("materials/factories/tech/tech_modelpink.vmt")
resource.AddFile("materials/factories/tech/tech_white.vtf")
resource.AddFile("materials/factories/lock.png")

util.AddNetworkString("fact_researchcat")
net.Receive("fact_researchcat",function(len,ply)
	ply:SetResearchCategory(net.ReadString())
end)