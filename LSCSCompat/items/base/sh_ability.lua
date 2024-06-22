ITEM.name = "Ability"
ITEM.description = "A Force Ability."
ITEM.category = "Abilities"
ITEM.model = "models/lscs/holocron.mdl"
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
	-- If the player drops an ability they have equipped, unequip it and remove it from their LSCS inventory
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
-- Adds an unequip button to the item, which only appears when the item is equipped.
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
-- Adds an equip button to the item, which only appears when the item is not equipped.
ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	OnRun = function(item)
		item:Equip(item.player)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerEquipItem", client, item) != false
	end
}
-- Equips whatever is in the ITEM.class field to the player's lscs inventory
function ITEM:Equip(client)
	client:lscsAddInventory( self.class, true )
	client:EmitSound(self.useSound, 80)
	self:SetData("equip", true)
	
end
-- Removes all instances of what is in the ITEM.class field from the player's lscs inventory
function ITEM:Unequip(client)
	local lscsInventory = client:lscsGetInventory()
	
	for k,v in pairs( lscsInventory ) do
		if v == self.class then
			client:lscsRemoveItem( k )
			client:lscsBuildPlayerInfo()
		end
	end
	
	client:EmitSound(self.useSound, 80)
	self:SetData("equip", nil)
end
-- If the item is equipped when the player spawns, equips the item to the player's lscs inventory
function ITEM:OnLoadout()
	if (self:GetData("equip")) then
		local client = self.player
		local lscsInventory = client:lscsGetInventory()
		-- Only adds the item if the player does not already have it.
		-- This avoids having players gain multiple instances of an item on spawn. Or when the OnLoadout hook is called twice on character select.
		if not table.HasValue(lscsInventory, self.class) then
			client:lscsAddInventory( self.class, true )
		end
	end
end