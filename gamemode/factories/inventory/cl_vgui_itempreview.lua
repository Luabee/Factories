
local PNL = {}

function PNL:Init()
	self:SetFOV( 65 )
	self.rand = math.random(0,359)
end

function PNL:DrawModel()

	local curparent = self
	local rightx = self:GetWide()
	local leftx = 0
	local topy = 0
	local bottomy = self:GetTall()
	local previous = curparent
	while( curparent:GetParent() != nil ) do
		curparent = curparent:GetParent()
		local x, y = previous:GetPos()
		topy = math.Max( y, topy + y )
		leftx = math.Max( x, leftx + x )
		bottomy = math.Min( y + previous:GetTall(), bottomy + y )
		rightx = math.Min( x + previous:GetWide(), rightx + x )
		previous = curparent
	end
	render.SetScissorRect( leftx, topy, rightx, bottomy, true )

	local ret = self:PreDrawModel( self.Entity )
	if ( ret != false ) then
		
		if self.sent and self.sent.PreDrawPreview then
			self.sent.PreDrawPreview(self.Entity)
		end
	
		self.Entity:DrawModel()
		
		if self.sent and self.sent.PostDrawPreview then
			self.sent.PostDrawPreview(self.Entity)
		end
		
		self:PostDrawModel( self.Entity )
	end

	render.SetScissorRect( 0, 0, 0, 0, false )

end

function PNL:SetModel(m)
	if not m then
		self.Entity:Remove()
		return
	end
	self.BaseClass.SetModel(self,m)
	
	self:CenterCamera()
end

function PNL:SetEntity(class)
	if not class then
		self.entclass = nil
		self.sent = nil
		return
	end
	local sent = scripted_ents.GetStored(class)
	self.entclass = class
	if istable(sent) then 
		sent = sent.t
		self.sent = sent
		if sent.SetupPreview then
			sent.SetupPreview(self.Entity)
		end
	end
	self:CenterCamera()
	
end

function PNL:CenterCamera()
	local mn, mx = self.Entity:GetRenderBounds()
	if self.sent and self.sent.ModelScale then
		mn, mx = mn * self.sent.PreviewScale, mx * self.sent.PreviewScale
	end
	local size = 0
	size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
	size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
	size = math.max( size, math.abs(mn.z) + math.abs(mx.z) ) 
	self:SetCamPos( Vector( size, size, size ) )
	self:SetLookAt( (mn + mx)/2 )
end

function PNL:LayoutEntity(e)
	e:SetAngles(Angle(0, math.sin((RealTime() + self.rand)) * 30 ,0))
end

vgui.Register("ItemPreview",PNL,"DModelPanel")