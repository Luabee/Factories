AddCSLuaFile()

ENT.Base = "base_fact_itemholder"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.BreakSpeed = .8
ENT.GridOffset = Vector(-48,0,-5)
ENT.Dimensions = {w=2,h=2}

function ENT:Initialize()
	
	
	self:SetupTables()
	
	self:SetModel("models/props_phx/construct/metal_wire1x2x2b.mdl") --frame
	-- ring models/hunter/misc/platehole2x2.mdl
	-- gear models/props_phx/gears/spur24.mdl
	
	self:SetupPreview()

	timer.Simple(.5,function()
		if IsValid(self) then
			self:UpdateInOut()
			for k,v in pairs(self:GetAdjacentEnts())do
				if v.IsItemHolder then
					v:UpdateInOut()
				end
			end
		end
	end)
	
	if ConVars.Server.collisions:GetBool() then
		self:PhysicsInit(SOLID_VPHYSICS)
		if SERVER then
			local phy = self:GetPhysicsObject()
			if IsValid(phy) then
				phy:EnableMotion(false)
			end
		end
	end
	
	self.Rot = 0
	
end

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
	self:NetworkVar("String",1,"Export")
end

function ENT.SetupPreview(self)
	
end
function ENT.PreDrawPreview(self)
	self:SetModelScale(1)
end
function ENT.PostDrawPreview(self)
	
	local oldpos = self:GetPos()
	local oldang = self:GetAngles()
	
	self:SetAngles(oldang)
	self:SetPos(oldpos + self:GetForward() * 48/2 + self:GetRight() * 48/2 + self:GetUp() * ((math.sin(CurTime()) + 1) * 16 + 8)) --ring
	-- self:SetModelScale(.5)
	self:SetModel("models/hunter/plates/platehole2x2.mdl")
	self:SetupBones()
	self:SetMaterial(research.LevelModelMats[self:GetLevel()])
	self:DrawModel()
	self:SetMaterial()
	
	if self.Rot then
		self.Rot = self.Rot + FrameTime()*10
	end
	self:SetModelScale(2)
	self:SetPos(oldpos + self:GetForward() * 48/2 + self:GetRight() * 48/2 + self:GetUp() * -5 ) --gear
	self:SetAngles(oldang + Angle(0,self.Rot or 0, 0))
	self:SetModel("models/props_phx/gears/spur24.mdl")
	self:SetupBones()
	self:DrawModel()
	
	self:SetModelScale(1)
	self:SetPos(oldpos) --reset
	self:SetAngles(oldang)
	self:SetModel("models/props_phx/construct/metal_wire1x2x2b.mdl")
	self:SetupBones()
	
end
function ENT:DrawCrafting()
	local oldpos = self:GetPos()
	local oldang = self:GetAngles()
	
	local item = items.List[self:GetExport()]
	if item then
		local progress = ((self.Progress or 0)-.5)*2
		local timeang = Angle(0,CurTime()*100,0)
		
		self:SetModel(item.Model)
		local ang = oldang + item.ConveyorAngle + timeang
		local off = -self:OBBCenter() - item.ConveyorOffset
		local min, max = self:GetRenderBounds()
		max.z = 0
		
		self:SetModelScale(item.ConveyorScale) --item
		self:SetPos(oldpos + ang:Forward()*off.x + ang:Right()*off.y + ang:Up()*off.z + Vector(48/2,-48/2,25)) 
		self:SetAngles(ang)
		local right = ang:Right()
		-- local right = timeang:Right()
		
		self:SetMaterial("models/wireframe",true)
		self:SetupBones()
		render.EnableClipping(true)
		render.PushCustomClipPlane(right,right:Dot(self:GetPos() + right * max * progress))
			self:DrawModel()
		render.PopCustomClipPlane()
		
		self:SetMaterial(item.Material)
		self:SetupBones()
		render.PushCustomClipPlane(-right,(-right):Dot(self:GetPos() + right *max * progress))
			self:DrawModel()
		render.PopCustomClipPlane()
		render.EnableClipping(false)
		
		self:SetMaterial()
		self:SetModelScale(1) --reset
		self:SetPos(oldpos)
		self:SetAngles(oldang)
		self:SetModel("models/props_phx/construct/metal_wire1x2x2b.mdl")
		self:SetupBones()
		
	end
	
end
function ENT:DrawTranslucent()
	self:PreDrawPreview()
	self:DrawModel()
	self:PostDrawPreview()
	self:DrawCrafting()
end


function ENT:Save(tbl)
	self:SellAll()
	if self.Rotates then
		tbl.yaw = self.Yaw
	end
	tbl.level = self:GetLevel()
	
	if self.GetImport then 
		tbl.item = self:GetImport() 
	elseif self.GetExport then
		tbl.item = self:GetExport()
	end
	
	
	return tbl
end
function ENT:Load(tbl)
	if self.Rotates then
		self.Yaw = tbl.yaw
	end
	self:SetLevel(tbl.level)
	
	if self.SetImport then 
		self:SetImport(tbl.item) 
	elseif self.SetExport then
		self:SetExport(tbl.item)
	end
	
	self.Receives = {}
	if tbl.item and items.List[tbl.item] then
		for k,v in pairs(items.List[tbl.item].Recipe.ingredients) do
			self.Receives[k] = true
		end
	end
	self.Holding = {}
	self.Using = {}
	
end

function ENT:GetSelectionMat()
	return Material("factories/selected.png", "unlitgeneric"), 0
end

function ENT:Think()
	
	local export = self:GetExport()
	local exitem = items.List[export]
	if exitem then
		local recipe = exitem.Recipe
		
		if #self.Holding < 5  then --make the product.
			self:Craft()
		end
		
		local requested = false
		for class,quan in pairs(recipe.ingredients)do
			local held = self.Using[class]
			if not held or held.Quantity < quan then --we need more.
				self:Request(class)
				requested = true
			end
		end
		if not requested then --we have what we need now ask for what we want.
			for class,quan in pairs(recipe.ingredients)do
				local held = self.Using[class]
				if not held or held.Quantity < quan * 2 then --we can hold more.
					self:Request(class)
				end
			end
		end
		
		
	end
	
	self:NextThink(CurTime())
	if CLIENT then
		self:SetNextClientThink(CurTime())
	end
	
	return true
	
end

function ENT:CanReceive(itemclass,input)
	local export = self:GetExport()
	local exitem = items.List[export]
	if exitem then
		local recipe = exitem.Recipe
		local held = self.Using[itemclass]
		if input:GetDroppingOff() or (not held or held.Quantity < recipe.ingredients[itemclass] * 2) then --we can hold more.
			return true
		end
	end
	return false
end

function ENT:OnReceive(item,input)
	table.RemoveByValue(self.Holding,item)
	local held = self.Using[item.ClassName]
	if held then
		held.Quantity = held.Quantity + item.Quantity
	else
		self.Using[item.ClassName] = item
	end
end

function ENT:Craft()
	local export = self:GetExport()
	local exitem = items.List[export]
	local recipe = exitem.Recipe
	if recipe then
		
		local have = true
		for part,quan in pairs(recipe.ingredients) do
			if !self.Using[part] or self.Using[part].Quantity < quan then
				have = false
				break
			end
		end
		
		if have then --if we have the ingredients
			
			if SERVER and IsFirstTimePredicted() and not self.Emitted then
				self:EmitSound("ambient/energy/weld"..math.random(1,2)..".wav", 50)
				self.Emitted = true
			end
			if CLIENT then
				local vPoint = self:GetPos() + Vector( 48/2, -48/2, 25 ) + VectorRand()*5
				local effectdata = EffectData()
				effectdata:SetOrigin( vPoint )
				effectdata:SetMagnitude( 1 )
				effectdata:SetScale( 1 )
				util.Effect( "ElectricSpark", effectdata )
			end
			
			local old = self.Progress or 0
			-- self.Progress = self.Progress + (FrameTime() / recipe.time)
			self.Progress = (CurTime() % recipe.time) / recipe.time
			if old > self.Progress then --we finished the product since the last frame.
				
				table.insert(self.Holding,items.Create(export))
				
				for class,quan in pairs(recipe.ingredients)do
					self.Using[class].Quantity = self.Using[class].Quantity - quan
					if self.Using[class].Quantity == 0 then
						self.Using[class] = nil
					end
				end
				
				self.Emitted = false
			end
			
		end
	end
	
end

if SERVER then
	util.AddNetworkString("fact_assembler")
	net.Receive("fact_assembler",function(len,ply)
		local class = net.ReadString()
		local imp = net.ReadEntity()
		if class == "" then return end
		if not items.List[class] then return end
		if !IsValid(imp) then return end
		
		if imp:GetMaker() != ply then return end
		imp:SetExport(class)
		imp.Receives = {}
		for k,v in pairs(items.List[class].Recipe.ingredients) do
			imp.Receives[k] = true
		end
		imp.Holding = {}
		imp.Using = {}
		imp.Progress = 0
	end)
else
	function ENT:DoClick()
		local netmsg = "fact_assembler"
		
		self:ShowSelectionMenu("Assembler", 
			function(self,item)
				if item.NeedsResearch then
					return item.Recipe.madeIn == self:GetClass() and item.Level <= self:GetLevel() and self:GetMaker():HasResearch(item.NeedsResearch,item.Level)
				else
					return item.Recipe.madeIn == self:GetClass() and item.Level <= self:GetLevel()
				end
			end,
			
			function(s)
				local class = s.Item and s.Item.ClassName or ""
				net.Start(netmsg)
					net.WriteString(class)
					net.WriteEntity(self)
				net.SendToServer()
				self:SetExport(class)
				self.Receives = {}
				if items.List[class] then
					for k,v in pairs(items.List[class].Recipe.ingredients) do
						self.Receives[k] = true
					end
				end
				self.Holding = {}
				self.Using = {}
				self.Progress = 0
			end
		)
		
		
	end
end
