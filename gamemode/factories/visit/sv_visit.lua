
visit = visit or {}
local plymeta = FindMetaTable("Player")

util.AddNetworkString("fact_visit")
util.AddNetworkString("fact_visit_invite")
util.AddNetworkString("fact_visit_invite_result")
util.AddNetworkString("fact_visit_kickout")
util.AddNetworkString("fact_visit_disconnect")
util.AddNetworkString("fact_setfactory")

hook.Add("PlayerInitialSpawn","fact_visitors",function(ply)
	ply.Visitors = {}
	net.Start("fact_visit")
		net.WriteEntity(ply)
		net.WriteBool(false)
	net.SendOmit(ply)
end)

hook.Add("PlayerDisconnected","fact_visitors",function(ply)
	for k,v in pairs(player.GetAll())do
		v.Visitors[ply] = nil
	end
	net.Start("fact_visit_disconnect")
		net.WriteEntity(ply)
	net.Broadcast()
	visit.KickAll(ply)
end)

net.Receive("fact_visit_kickout",function(l,ply)
	local owner = net.ReadEntity()
	local visitor = net.ReadEntity()
	if IsValid(visitor) then
		if ply == visitor or IsValid(owner) and owner.Visitors[visitor] then
			if ply != owner then
				visitor:ChatPrint(owner:Nick().." removed you from their factory.")
			else
				visitor:ChatPrint("You returned to your own factory.")
			end
			owner.Visitors[visitor] = nil
			visit.Sync(owner)
			fact.Create(visitor,true)
			visit.TeleportToFactory(visitor,visitor:LoadFactory())
		end
	end
end)

net.Receive("fact_visit",function(l,ply)
	ply.Visitors = net.ReadTable()
	visit.Sync(ply,true)
end)

function visit.Sync(ply,omit)
	net.Start("fact_visit")
		net.WriteEntity(ply)
		net.WriteBool(true)
		net.WriteTable(ply.Visitors)
	if omit then
		net.SendOmit(ply)
	else
		net.Broadcast()
	end
end

function visit.TeleportToFactory(ply,fac)
	ply.Factory = fac
	
	if ply != fac.Owner then
		ply:SetNWEntity("fact_Visiting", fac.Owner)
		ply:SetPos(fac.Owner:GetPos() + Vector(16,16,0))
	else
		ply:SetNWEntity("fact_Visiting", NULL)
	end
	net.Start("fact_setfactory")
		net.WriteEntity(ply)
		net.WriteTable(fac)
	net.Broadcast()
	fac.Owner:SyncFactory()
end

function visit.KickAll(ply)
	for k,v in pairs(ply.Visitors)do
		if IsValid(k) then
			ply.Visitors[k] = nil
			visit.Sync(ply)
			fact.Create(k,true)
			visit.TeleportToFactory(k,k:LoadFactory())
			ply:ChatPrint(ply:Nick().." removed you from their factory.")
		end
	end
end

function visit.SendInvite(ply,visitor,perm)
	if IsValid(visitor) and visitor != ply then
		visitor.visitInvites = visitor.visitInvites or {}
		visitor.visitInvites[ply] = perm
		net.Start("fact_visit_invite")
			net.WriteEntity(ply)
			net.WriteUInt(perm,3)
		net.Send(visitor)
	end
end
net.Receive("fact_visit_invite",function(l,ply)
	local visitor = net.ReadEntity()
	local perm = net.ReadUInt(3)
	visit.SendInvite(ply,visitor,perm)
end)
net.Receive("fact_visit_invite_result",function(l,visitor)
	local ply = net.ReadEntity()
	local result = net.ReadBool()
	if IsValid(ply) and IsValid(visitor) and visitor.visitInvites[ply] then
	
		if result then
			visit.KickAll(visitor)
			visitor:SetPermission(ply,visitor.visitInvites[ply])
			visit.Sync(ply)
			visitor:SaveFactory()
			visitor:RemoveFactory()
			visit.TeleportToFactory(visitor,ply:GetFactory())
			
			
			ply:ChatPrint(visitor:Nick().." accepted your invitation.")
		else
			ply:ChatPrint(visitor:Nick().." declined your invitation.")
		end
	end
	visitor.visitInvites[ply] = nil
end)

hook.Add("ShowTeam","fact_visit",function(ply)
	ply:ConCommand("fact_visit")
end)