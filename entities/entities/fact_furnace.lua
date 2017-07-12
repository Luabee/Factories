AddCSLuaFile()

ENT.Base = "base_fact_itemholder"
ENT.BreakSpeed = .8
ENT.GridOffset = Vector(0,0,38)
ENT.AngOffset = Angle(0,180,0)
ENT.Dimensions = {w=1,h=1}

function ENT:Initialize()
	
	
	self:SetupTables()
	self:SetDroppingOff(true)
	
	self:SetModel("models/props_c17/furniturefireplace001a.mdl") --frame
	-- ring models/hunter/misc/platehole2x2.mdl
	-- gear models/props_phx/gears/spur24.mdl
	
	-- if SERVER then self:EmitSound("ambient/fire/fire_big_loop1.wav", 60) end
	self:SetupPreview()

	if ConVars.Server.collisions:GetBool() then
		self:PhysicsInit(SOLID_VPHYSICS)
		if SERVER then
			local phy = self:GetPhysicsObject()
			if IsValid(phy) then
				phy:EnableMotion(false)
			end
		end
	end
	
	timer.Simple(.5,function()
		self:UpdateInOut()
		for k,v in pairs(self:GetAdjacentEnts())do
			if v.IsItemHolder then
				v:UpdateInOut()
			end
		end
	end)
	
end

-- function ENT:OnRemove()
	-- self.BaseClass.OnRemove(self)
	-- self:StopSound("ambient/fire/fire_big_loop1.wav")
-- end

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
	self:NetworkVar("String",1,"Export")
end

local mat = Matrix()
mat:Scale(Vector(1.83,1,1))
function ENT.SetupPreview(self)
	if CLIENT then 
		self:EnableMatrix("RenderMultiply",mat)
	end
end

function ENT:SetupIO(adjacent)
	
	//The inserters should handle this logic for us.
	
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
		if input:GetDroppingOff() or (not held or held.Quantity < recipe.ingredients[itemclass] * 2)  then --we can hold more.
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
				self:EmitSound("ambient/fire/ignite.wav", 50)
				self.Emitted = true
			end
			local vPoint = self:GetPos() + Vector( 28, -7, 38 )
			local effectdata = EffectData()
			effectdata:SetOrigin( vPoint )
			effectdata:SetScale( 1 )
			util.Effect( "MuzzleEffect", effectdata )
			
			local old = self.Progress or 0
			-- self.Progress = self.Progress + (FrameTime() / recipe.time)
			self.Progress = (CurTime() % recipe.time) / recipe.time
			if old > self.Progress then --we finished the product since the last frame.
				
				table.insert(self.Holding,items.Create(export))
				
				for class,quan in pairs(recipe.ingredients)do
					self.Using[class].Quantity = self.Using[class].Quantity - quan
				end
				
				self.Emitted = false
			end
			
		end
	end
	
end


function ENT:Save(tbl)
	self:SellAll()
	if self.Rotates then
		tbl.yaw = self.Yaw
	end
	
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
	
	if self.SetImport then 
		self:SetImport(tbl.item) 
	elseif self.SetExport then
		self:SetExport(tbl.item)
	end
	
	self.Receives = {}
	for k,v in pairs(items.List[tbl.item].Recipe.ingredients) do
		self.Receives[k] = true
	end
	self.Holding = {}
	self.Using = {}
	
end

if SERVER then
else
	function ENT:DoClick()
		local netmsg = "fact_assembler"
		
		self:ShowSelectionMenu("Furnace", function(self,item)
			return item.Recipe.madeIn == self:GetClass()
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
		end)
		
		
	end
end
