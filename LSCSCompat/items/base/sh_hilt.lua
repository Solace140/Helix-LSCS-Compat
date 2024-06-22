ITEM.name = "Hilt"
ITEM.description = "A Lightsaber Hilt."
ITEM.category = "Hilts"
ITEM.model = "models/lscs/weapons/katarn.mdl"
ITEM.class = ""
ITEM.width = 1
ITEM.height = 2
ITEM.useSound = "items/ammo_pickup.wav"
-- Check sh_crystal.lua for comments, it's all the same.
if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end

	function ITEM:PopulateTooltip(tooltip)
		if (self:GetData("equip")) then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end
	end
end

ITEM:Hook("drop", function(item)
	local inventory = ix.item.inventories[item.invID]

	if (!inventory) then
		return
	end

	local owner

	for client, character in ix.util.GetCharacters() do
		if (character:GetID() == inventory.owner) then
			owner = client
			break
		end
	end

	if (!IsValid(owner)) then
		return
	end

	if (item:GetData("equip")) then
		item:SetData("equip", nil)
		
		local lscsInventory = owner:lscsGetInventory()
		
		for k,v in pairs( lscsInventory ) do
			if v == item.class then
				owner:lscsRemoveItem( k )
				owner:lscsBuildPlayerInfo()
			end
		end
	end
end)

local function IsHandOccupied(client, hand)
    local inventory = client:GetCharacter():GetInventory():GetItems()
    if inventory then
        for _, item in pairs(inventory) do
            if item:GetData("equip") and item:GetData(hand) then
                return true
            end
        end
    end
    return false
end

ITEM.functions.EquipUn = {
    name = "Unequip",
    tip = "equipTip",
    icon = "icon16/cross.png",
    OnRun = function(item)
        item:Unequip(item.player, true)
        return false
    end,
    OnCanRun = function(item)
        local client = item.player

        return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
            hook.Run("CanPlayerUnequipItem", client, item) != false
    end
}

ITEM.functions.EquipRight = {
    name = "Equip Right",
    tip = "equipTip",
    icon = "icon16/tick.png",
    OnRun = function(item)
        item:EquipR(item.player)
        return false
    end,
    OnCanRun = function(item)
        local client = item.player

        return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
            not IsHandOccupied(client, "equipRightHilt") and
            hook.Run("CanPlayerEquipItem", client, item) != false
    end
}

ITEM.functions.EquipLeft = {
    name = "Equip Left",
    tip = "equipTip",
    icon = "icon16/tick.png",
    OnRun = function(item)
        item:EquipL(item.player)
        return false
    end,
    OnCanRun = function(item)
        local client = item.player

        return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
            not IsHandOccupied(client, "equipLeftHilt") and
            hook.Run("CanPlayerEquipItem", client, item) != false
    end
}

function ITEM:EquipR(client)
    client:lscsAddInventory(self.class, true)
	client:StripWeapon("weapon_lscs")
	if client:lscsIsValid() then
		client:Give("weapon_lscs")
		client:lscsCraftSaber()
	end
    client:EmitSound(self.useSound, 80)
    self:SetData("equip", true)
    self:SetData("equipRightHilt", true)
    self:SetData("equipLeftHilt", nil)
end

function ITEM:EquipL(client)
    client:lscsAddInventory(self.class, false)
	client:StripWeapon("weapon_lscs")
	if client:lscsIsValid() then
		client:Give("weapon_lscs")
		client:lscsCraftSaber()
	end
    client:EmitSound(self.useSound, 80)
    self:SetData("equip", true)
    self:SetData("equipLeftHilt", true)
    self:SetData("equipRightHilt", nil)
end

function ITEM:Unequip(client)
    local lscsInventory = client:lscsGetInventory()
    
    for k, v in pairs(lscsInventory) do
        if v == self.class then
            client:lscsRemoveItem(k)
            client:lscsBuildPlayerInfo()
        end
    end
	client:StripWeapon("weapon_lscs")
    if client:lscsIsValid() then
		client:Give("weapon_lscs")
		client:lscsCraftSaber()
	end
    client:EmitSound(self.useSound, 80)
    self:SetData("equip", nil)
    self:SetData("equipRightHilt", nil)
    self:SetData("equipLeftHilt", nil)
end

function ITEM:OnLoadout()
    if (self:GetData("equipRightHilt")) then
        local client = self.player
        local lscsInventory = client:lscsGetInventory()
        
        if not table.HasValue(lscsInventory, self.class) then
            client:lscsAddInventory(self.class, true)
			if client:lscsIsValid() then
				client:Give("weapon_lscs")
				client:lscsCraftSaber()
			end
        end
    end
	if (self:GetData("equipLeftHilt")) then
        local client = self.player
        local lscsInventory = client:lscsGetInventory()
        
        if not table.HasValue(lscsInventory, self.class) then
            client:lscsAddInventory(self.class, false)
			if client:lscsIsValid() then
				client:Give("weapon_lscs")
				client:lscsCraftSaber()
			end
        end
    end
end