ITEM.name = "Crystal"
ITEM.description = "A Lightsaber Crystal."
ITEM.category = "Crystals"
ITEM.model = "models/props_junk/garbage_glassbottle001a_chunk03.mdl"
ITEM.class = ""
ITEM.width = 1
ITEM.height = 1
ITEM.useSound = "items/ammo_pickup.wav"

-- Inventory drawing
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

	-- the item could have been dropped by someone else (i.e someone searching this player), so we find the real owner
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
-- checks the player's inventory to see if anything is already equipped to the right/left hand.
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
-- Adds an equip button to the item, which only appears when the item is not equipped and there is no crystal in the right hand.
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
            not IsHandOccupied(client, "equipRightCrystal") and -- Check if any crystal is equipped in the right hand
            hook.Run("CanPlayerEquipItem", client, item) != false
    end
}
-- Adds an equip button to the item, which only appears when the item is not equipped and there is no crystal in the left hand.
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
            not IsHandOccupied(client, "equipLeftCrystal") and -- Check if any crystal is equipped in the left hand
            hook.Run("CanPlayerEquipItem", client, item) != false
    end
}
-- equips whatever is in the ITEM.class field to the player's lscs right crystal slot
function ITEM:EquipR(client)
    client:lscsAddInventory(self.class, true)
	client:StripWeapon("weapon_lscs")
	if client:lscsIsValid() then
		client:Give("weapon_lscs")
		client:lscsCraftSaber()
	end
    client:EmitSound(self.useSound, 80)
    self:SetData("equip", true)
    self:SetData("equipRightCrystal", true)
    self:SetData("equipLeftCrystal", nil)
end
-- equips whatever is in the ITEM.class field to the player's lscs left crystal slot
function ITEM:EquipL(client)
    client:lscsAddInventory(self.class, false)
	client:StripWeapon("weapon_lscs")
	if client:lscsIsValid() then
		client:Give("weapon_lscs")
		client:lscsCraftSaber()
	end
    client:EmitSound(self.useSound, 80)
    self:SetData("equip", true)
    self:SetData("equipLeftCrystal", true)
    self:SetData("equipRightCrystal", nil)
end
-- Removes all instances of what is in the ITEM.class field from the player's lscs inventory
-- This does cause issues if you have two of the same thing equipped, working on getting this fixed.
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
    self:SetData("equipRightCrystal", nil)
    self:SetData("equipLeftCrystal", nil)
end
-- If the item is equipped when the player spawns, equips the item to appropriate slot the player's lscs inventory
function ITEM:OnLoadout()
    if (self:GetData("equipRightCrystal")) then
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
	if (self:GetData("equipLeftCrystal")) then
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