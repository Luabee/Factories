
visit = visit or {}
local plymeta = FindMetaTable("Player")

PERMISSION_ALL = 3 --player can place and remove anything from the factory.
PERMISSION_BUILD = 2 --Player can only place new things in the factory.
PERMISSION_VIEW = 1 --player can only view the factory.]

visit.PermissionString = {
	[PERMISSION_ALL] = "Full Access",
	[PERMISSION_BUILD] = "Build Only",
	[PERMISSION_VIEW] = "View Only",
}

function plymeta:HasPermission(otherply, perm)
	local p = self:GetPermission(otherply)
	return p and p >= perm or false
end

function plymeta:GetVisiting()
	return self:GetNWEntity("fact_Visiting",NULL)
end

function plymeta:GetPermission(otherply)
	otherply.Visitors = otherply.Visitors or {}
	return (self == otherply and PERMISSION_ALL) or otherply.Visitors[self]
end

function plymeta:SetPermission(otherply, perm)
	otherply.Visitors[self] = perm
end

