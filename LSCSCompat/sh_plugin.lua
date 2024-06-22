PLUGIN.name = "LSCS Compatibility"
PLUGIN.author = "Solace"
PLUGIN.description = "Adds compatibility with LSCS."

if (SERVER) then
	function PLUGIN:PostPlayerLoadout(client)
		client:lscsSetMaxForce( ix.config.Get("BaseForcePoints") + (client:GetCharacter():GetAttribute("frc", 0) * ix.config.Get("ForceMultiplier")) )
		client:lscsSetForce( ix.config.Get("BaseForcePoints") + (client:GetCharacter():GetAttribute("frc", 0) * ix.config.Get("ForceMultiplier")) )
	end
	-- Wipes the character's lscs inventory after selecting a character, but before their Helix loadout is loaded.
	-- This prevents lscs inventories persisting between characters.
	function PLUGIN:PlayerLoadedCharacter(client, character, currentChar) 
		client:lscsWipeInventory(false)
	end
end
-- adds config for the force stat. 
ix.config.Add("ForceMultiplier", 1, "The force stat scale", nil, {
	data = {min = 0, max = 5.0, decimals = 1},
	category = "LSCS"
})

ix.config.Add("BaseForcePoints", 100, "The base amount of force points a character will have", nil, {
	data = {min = 0, max = 500.0, decimals = 0},
	category = "LSCS"
})